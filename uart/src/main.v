`include "receiver.v"
`include "transmitter.v"
`include "fifo.v"

module main (
    input  wire clk,
    input  wire rst_n,
    input  wire rx,
    output wire tx
);

    // UART echo with FIFO buffering

    // Receiver signals
    wire [7:0] rx_data;
    wire       rx_data_ready;

    // FIFO signals
    wire [7:0] fifo_read_data;
    wire       fifo_empty;
    wire       fifo_full;
    wire [4:0] fifo_count;
    reg        fifo_read_en;

    // Transmitter signals
    wire       tx_busy;
    reg        tx_start;
    reg  [7:0] tx_data;

    // ===== RECEIVER =====
    receiver uart_receiver (
        .clk       (clk),
        .rst_n     (rst_n),
        .rx        (rx),
        .data_out  (rx_data),
        .data_ready(rx_data_ready)
    );

    // ===== FIFO =====
    fifo buffer (
        .clk       (clk),
        .rst_n     (rst_n),
        // Write side: connected to receiver
        .write_en  (rx_data_ready),
        .write_data(rx_data),
        .write_full(fifo_full),
        // Read side: controlled by transmitter logic
        .read_en   (fifo_read_en),
        .read_data (fifo_read_data),
        .read_empty(fifo_empty),
        .count     (fifo_count)
    );

    // ===== TRANSMITTER =====
    transmitter uart_transmitter (
        .clk     (clk),
        .rst_n   (rst_n),
        .tx_start(tx_start),
        .data_in (tx_data),
        .tx      (tx),
        .busy    (tx_busy)
    );

    // ===== FIFO → TRANSMITTER CONTROL =====
    // Read from FIFO and start transmission when:
    // - FIFO has data (!fifo_empty)
    // - Transmitter is ready (!tx_busy)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_read_en <= 1'b0;
            tx_start     <= 1'b0;
            tx_data      <= 8'd0;
        end else begin
            // Default: no read, no transmit
            fifo_read_en <= 1'b0;
            tx_start     <= 1'b0;

            // If FIFO has data and transmitter is ready
            if (!fifo_empty && !tx_busy && !tx_start) begin
                fifo_read_en <= 1'b1;  // Request read from FIFO
                tx_data      <= fifo_read_data;  // Capture data
                tx_start     <= 1'b1;  // Start transmission
            end
        end
    end

    // ===== DEBUG: TX MONITOR =====
    wire [7:0] tx_captured;
    wire       tx_captured_ready;

    receiver tx_monitor (
        .clk       (clk),
        .rst_n     (rst_n),
        .rx        (tx),
        .data_out  (tx_captured),
        .data_ready(tx_captured_ready)
    );

    reg [7:0] last_tx_captured;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) last_tx_captured <= 8'd0;
        else if (tx_captured_ready) last_tx_captured <= tx_captured;
    end

endmodule

