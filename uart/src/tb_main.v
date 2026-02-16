`timescale 1ns / 1ps
`include "main.v"

module tb_main;
    reg  clk;
    reg  rst_n;
    reg  rx;
    wire tx;

    main dut (
        .clk  (clk),
        .rst_n(rst_n),
        .rx   (rx),
        .tx   (tx)
    );


    localparam real CLK_FREQ = 24_000_000;  // 24 MHz
    localparam real CLK_PERIOD = 1e9 / CLK_FREQ;  // Clock period in nanoseconds

    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;  // Generate clock signal


    initial begin
        rst_n = 0;
        rx    = 1;  // Idle state of UART is high
        #(CLK_PERIOD * 5);  // Hold reset for a few clock cycles

        rst_n = 1;  // Release reset
    end

    localparam real BAUDRATE = 115200;
    localparam real BIT_PERIOD = 1e9 / BAUDRATE;  // Bit period in nanoseconds


    task send_byte(input [7:0] byte);
        integer i;
        begin
            // Start bit
            rx = 0;
            #(BIT_PERIOD);

            for (i = 0; i < 8; i = i + 1) begin
                rx = byte[i];  // Send LSB first
                #(BIT_PERIOD);
            end

            // Stop bit
            rx = 1;
            #(BIT_PERIOD);
        end
    endtask

    initial begin
        $dumpfile("tb_main.vcd");
        $dumpvars(0, tb_main);

        #(BIT_PERIOD * 2);  // Wait for the system to stabilize
        send_byte(8'h55);  // Send a test byte (0x55)
        #(BIT_PERIOD * (1+8+1) * 2);  // Wait for the byte to be processed
        send_byte(8'hAA);  // Send another test byte (0xAA)
        #(BIT_PERIOD * (1+8+1) * 2);  // Wait for the byte to be processed
        $finish;  // End the simulation
    end


endmodule
