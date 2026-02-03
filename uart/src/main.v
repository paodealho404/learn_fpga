`include "receiver.v"
module main (
    input  wire clk,
    input  wire rst_n,
    input  wire rx,
    output wire tx
);

    //Simple UART echo sample

    wire [7:0] data_buffer;
    wire       data_ready;

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
        .tx      (tx)
    );


endmodule

