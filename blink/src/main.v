module main (
    input sys_clk,
    input sys_rst_n,
    output reg led
);

    reg [23:0] cnt;


    //  Timer
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) cnt <= 24'd0;
        else if (cnt < (24'd6000000)) cnt <= cnt + 1'b1;
        else cnt <= 24'd0;
    end
    //  LED Control
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) led <= 1'b1;
        else if (cnt == (24'd6000000)) led <= ~led;
    end

endmodule

