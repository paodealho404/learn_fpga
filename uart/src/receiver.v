module receiver (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,
    output reg  [7:0] data_out,
    output reg        data_ready
);

    parameter integer CLK_FREQ = 27_000_000;
    parameter integer BAUD_RATE = 115200;

    localparam integer CYC_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam integer HALF_CYC_PER_BIT = CYC_PER_BIT / 2;

    reg [1:0] rx_sync;

    // Trying to reduce metastability
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync <= 2'b11;
        end else begin
            rx_sync <= {rx_sync[0], rx};
        end
    end


    // Receiver state machine
    localparam [1:0] STATE_IDLE = 2'd0;
    localparam [1:0] STATE_START = 2'd1;
    localparam [1:0] STATE_DATA = 2'd2;
    localparam [1:0] STATE_STOP = 2'd3;

    reg [ 1:0] state;
    reg [ 2:0] bit_index;
    reg [15:0] clk_count;
    reg [ 7:0] rx_shift_reg;


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= STATE_IDLE;
            data_out     <= 8'd0;
            data_ready   <= 1'b0;
            bit_index    <= 3'd0;
            clk_count    <= 16'd0;
            rx_shift_reg <= 8'd0;
        end else begin
            data_ready <= 1'b0;

            case (state)
                STATE_IDLE: begin
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;

                    if (rx_sync[1] == 1'b0) begin
                        state <= STATE_START;
                    end
                end

                STATE_START: begin
                    if (clk_count < HALF_CYC_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        if (rx_sync[1] == 1'b0) begin
                            clk_count <= 16'd0;
                            state     <= STATE_DATA;
                        end else begin
                            state <= STATE_IDLE;
                        end
                    end
                end

                STATE_DATA: begin
                    if (clk_count < CYC_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count               <= 16'd0;
                        rx_shift_reg[bit_index] <= rx_sync[1];
                        if (bit_index < 3'd7) begin
                            bit_index <= bit_index + 1'b1;
                        end else begin
                            bit_index <= 3'd0;
                            state     <= STATE_STOP;
                        end
                    end
                end

                STATE_STOP: begin
                    if (clk_count < CYC_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 16'd0;
                        if (rx_sync[1] == 1'b1) begin
                            data_out   <= rx_shift_reg;
                            data_ready <= 1'b1;
                        end
                        state <= STATE_IDLE;
                    end
                end

                default: begin
                    state <= STATE_IDLE;
                end

            endcase
        end
    end





endmodule
