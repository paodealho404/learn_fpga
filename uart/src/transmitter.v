module transmitter (
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,
    input wire tx_start,
    output reg tx,
    output reg tx_busy
)

parameter integer CLK_FREQ = 24_000_000;
parameter integer BAUD_RATE = 115200;
localparam integer CYC_PER_BIT = CLK_FREQ / BAUD_RATE;

localparam [1:0] STATE_IDLE = 2'd0;
localparam [1:0] STATE_START = 2'd1;
localparam [1:0] STATE_DATA = 2'd2;
localparam [1:0] STATE_STOP = 2'd3;

reg [1:0] state;
reg [2:0] bit_index;
reg [15:0] clk_count;
reg [7:0] tx_shift_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= STATE_IDLE;
        tx <= 1'b1; // Idle state of UART is high
        tx_busy <= 1'b0;
        bit_index <= 3'd0;
        clk_count <= 16'd0;
        tx_shift_reg <= 8'd0;
    end else begin
        case (state)
        STATE_IDLE: begin end
        STATE_START: begin end
        STATE_DATA: begin end
        STATE_STOP: begin end
        default: state <= STATE_IDLE;
        endcase
    end
    
end

endmodule
