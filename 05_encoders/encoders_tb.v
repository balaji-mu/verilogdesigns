// Testbench developed using Claude (claude.ai/code)
module encoder_tb;

    reg  [15:0] datain;
    wire [3:0]  dataout;

    encoder uut (
        .datain(datain),
        .dataout(dataout)
    );

    task check;
        input [15:0] in;
        input [3:0]  expected;
        begin
            datain = in;
            #10;
            if (dataout === expected)
                $display("PASS | datain=%b dataout=%0d", in, dataout);
            else
                $display("FAIL | datain=%b dataout=%0d (expected %0d)", in, dataout, expected);
        end
    endtask

    initial begin
        // zero input
        check(16'b0000000000000000, 4'd0);

        // single bit set
        check(16'b0000000000000001, 4'd0);   // bit 0
        check(16'b0000000000000010, 4'd1);   // bit 1
        check(16'b0000000000010000, 4'd4);   // bit 4
        check(16'b0000000100000000, 4'd8);   // bit 8
        check(16'b1000000000000000, 4'd15);  // bit 15

        // multiple bits set — highest index wins
        check(16'b0000000000000011, 4'd1);   // bits 0,1   → 1
        check(16'b0000000000001111, 4'd3);   // bits 0-3   → 3
        check(16'b1000000000000001, 4'd15);  // bits 0,15  → 15
        check(16'b0101000000000000, 4'd14);  // bits 12,14 → 14

        $finish;
    end

endmodule
