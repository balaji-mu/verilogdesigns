module barrelshifter_tb;

    reg  [31:0] datain;
    reg  [4:0]  shiftamt;
    reg  [2:0]  operation;
    wire [31:0] dataout;

    integer pass_count, fail_count, test_num;

    barrelshifter dut (
        .datain(datain),
        .shiftamt(shiftamt),
        .operation(operation),
        .dataout(dataout)
    );

    task apply_and_check;
        input [2:0]  op;
        input [31:0] din;
        input [4:0]  samt;
        input [31:0] expected;
        begin
            operation = op;
            datain    = din;
            shiftamt  = samt;
            #10;
            test_num = test_num + 1;
            if (dataout === expected) begin
                $display("PASS [%0d] op=%0d  data=0x%h  shift=%2d  out=0x%h",
                          test_num, op, din, samt, dataout);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL [%0d] op=%0d  data=0x%h  shift=%2d  expected=0x%h  got=0x%h",
                          test_num, op, din, samt, expected, dataout);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("barrelshifter.vcd");
        $dumpvars(0, barrelshifter_tb);

        pass_count = 0;
        fail_count = 0;
        test_num   = 0;

        // -------------------------------------------------------
        // Rotate Right (op=0)
        // -------------------------------------------------------
        $display("\n--- Rotate Right (op=0) ---");
        apply_and_check(3'd0, 32'hABCD1234, 5'd0,  32'hABCD1234); // no shift
        apply_and_check(3'd0, 32'hABCD1234, 5'd4,  32'h4ABCD123);
        apply_and_check(3'd0, 32'hABCD1234, 5'd16, 32'h1234ABCD);
        apply_and_check(3'd0, 32'hABCD1234, 5'd31, 32'h579A2469); // same as ROL 1
        apply_and_check(3'd0, 32'h00000001, 5'd1,  32'h80000000); // LSB wraps to MSB
        apply_and_check(3'd0, 32'h80000000, 5'd1,  32'h40000000);
        apply_and_check(3'd0, 32'hFFFFFFFF, 5'd16, 32'hFFFFFFFF);
        apply_and_check(3'd0, 32'h00000000, 5'd15, 32'h00000000);

        // -------------------------------------------------------
        // Rotate Left (op=1)
        // -------------------------------------------------------
        $display("\n--- Rotate Left (op=1) ---");
        apply_and_check(3'd1, 32'hABCD1234, 5'd0,  32'hABCD1234); // no shift
        apply_and_check(3'd1, 32'hABCD1234, 5'd4,  32'hBCD1234A);
        apply_and_check(3'd1, 32'hABCD1234, 5'd16, 32'h1234ABCD);
        apply_and_check(3'd1, 32'hABCD1234, 5'd31, 32'h55E6891A); // same as ROR 1
        apply_and_check(3'd1, 32'h80000000, 5'd1,  32'h00000001); // MSB wraps to LSB
        apply_and_check(3'd1, 32'h00000001, 5'd1,  32'h00000002);
        apply_and_check(3'd1, 32'hFFFFFFFF, 5'd16, 32'hFFFFFFFF);
        apply_and_check(3'd1, 32'h00000000, 5'd15, 32'h00000000);

        // -------------------------------------------------------
        // Logical Left Shift (op=2)
        // -------------------------------------------------------
        $display("\n--- Logical Left Shift (op=2) ---");
        apply_and_check(3'd2, 32'hABCD1234, 5'd0,  32'hABCD1234); // no shift
        apply_and_check(3'd2, 32'hABCD1234, 5'd4,  32'hBCD12340);
        apply_and_check(3'd2, 32'hABCD1234, 5'd16, 32'h12340000);
        apply_and_check(3'd2, 32'hABCD1234, 5'd31, 32'h00000000); // bit[0]=0, all lost
        apply_and_check(3'd2, 32'h00000001, 5'd1,  32'h00000002);
        apply_and_check(3'd2, 32'hFFFFFFFF, 5'd1,  32'hFFFFFFFE);
        apply_and_check(3'd2, 32'h80000000, 5'd1,  32'h00000000); // MSB shifts out
        apply_and_check(3'd2, 32'h00000000, 5'd16, 32'h00000000);

        // -------------------------------------------------------
        // Logical Right Shift (op=3)
        // -------------------------------------------------------
        $display("\n--- Logical Right Shift (op=3) ---");
        apply_and_check(3'd3, 32'hABCD1234, 5'd0,  32'hABCD1234); // no shift
        apply_and_check(3'd3, 32'hABCD1234, 5'd4,  32'h0ABCD123);
        apply_and_check(3'd3, 32'hABCD1234, 5'd16, 32'h0000ABCD);
        apply_and_check(3'd3, 32'hABCD1234, 5'd31, 32'h00000001); // only MSB remains
        apply_and_check(3'd3, 32'h80000000, 5'd1,  32'h40000000); // MSB becomes 0 (logical)
        apply_and_check(3'd3, 32'hFFFFFFFF, 5'd1,  32'h7FFFFFFF);
        apply_and_check(3'd3, 32'h00000001, 5'd1,  32'h00000000);
        apply_and_check(3'd3, 32'h00000000, 5'd16, 32'h00000000);

        // -------------------------------------------------------
        // Default / undefined operations (op=5,6,7) → expect 0
        // -------------------------------------------------------
        $display("\n--- Default: undefined ops (op=5,6,7) ---");
        apply_and_check(3'd5, 32'hABCD1234, 5'd4,  32'h00000000);
        apply_and_check(3'd6, 32'hABCD1234, 5'd4,  32'h00000000);
        apply_and_check(3'd7, 32'hFFFFFFFF, 5'd0,  32'h00000000);

        $display("\n=== Results: %0d passed, %0d failed out of %0d tests ===",
                  pass_count, fail_count, test_num);
        $finish;
    end

endmodule
