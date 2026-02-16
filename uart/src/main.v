`include "receiver.v"
`include "transmitter.v"

module main (
    input  wire clk,
    input  wire rst_n,
    input  wire rx,
    output wire tx
);

    //Simple UART echo sample

    wire [7:0] data_buffer;
    wire       data_ready;
    wire       tx_busy;
    wire [7:0] tx_captured;
    wire       tx_captured_ready;


    receiver uart_receiver (
        .clk       (clk),
        .rst_n     (rst_n),
        .rx        (rx),
        .data_out  (data_buffer),
        .data_ready(data_ready)
    );


    transmitter uart_transmitter (
        .clk     (clk),
        .rst_n   (rst_n),
        .tx_start(data_ready),
        .data_in (data_buffer),
        .tx      (tx),
        .busy    (tx_busy)
    );

    // Monitor de TX - captura o que foi transmitido

    receiver tx_monitor (
        .clk       (clk),
        .rst_n     (rst_n),
        .rx        (tx),                // conecta ao TX!
        .data_out  (tx_captured),
        .data_ready(tx_captured_ready)
    );

    // Buffer de debug - armazena último byte capturado do TX
    reg [7:0] last_tx_captured;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) last_tx_captured <= 8'd0;
        else if (tx_captured_ready) last_tx_captured <= tx_captured;
    end

endmodule

