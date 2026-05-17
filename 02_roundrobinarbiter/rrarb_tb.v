`timescale 1ns/1ps

module rrarb_tb;
    reg [3:0] req;
    reg clk;
    reg rst;
    wire [1:0] gnt;

    rrarb dut(
        .req    (req),
        .clk    (clk),
        .rst    (rst),
        .gnt    (gnt)
    );

    initial clk = 0;
    initial rst = 1;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("rrarb_tb.vcd");
        $dumpvars(0, rrarb_tb);
        #1000;
        $finish;
    end

    // TEST
    initial begin
        #5 rst = 0;
        #5 rst = 1;
        #14 req = 4'b1110;
    end
endmodule