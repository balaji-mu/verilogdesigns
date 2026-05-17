// THIS TESTBENCH WAS AI GENERATED

`timescale 1ns/1ps

module asf_tb;

    // =========================================================
    // DUT Signals
    // =========================================================
    reg        wren, rden;
    reg  [7:0] wrdata;
    reg        clkA, clkB;
    reg        rstA, rstB;
    wire [7:0] rddata;
    wire       isfull, isempty;

    // =========================================================
    // DUT Instantiation
    // =========================================================
    asf dut (
        .wren    (wren),
        .wrdata  (wrdata),
        .clkA    (clkA),
        .isfull  (isfull),
        .rden    (rden),
        .clkB    (clkB),
        .rddata  (rddata),
        .isempty (isempty),
        .rstA    (rstA),
        .rstB    (rstB)
    );

    // =========================================================
    // Clock Generation
    // =========================================================
    initial clkA = 0;
    initial clkB = 0;
    always #5  clkA = ~clkA;   // 100 MHz
    always #7  clkB = ~clkB;   //  ~71 MHz

    // =========================================================
    // Scoreboard
    // =========================================================
    reg [7:0] expected_q [0:15];
    integer   eq_head, eq_tail;

    // =========================================================
    // Waveform Dump
    // =========================================================
    initial begin
        $dumpfile("asf_tb.vcd");
        $dumpvars(0, asf_tb);
    end

    // =========================================================
    // Timeout Watchdog
    // =========================================================
    initial begin
        #50000;
        $display("[TIMEOUT] Simulation exceeded time limit");
        $finish;
    end

    // =========================================================
    // Test Sequence
    // =========================================================
    integer idx;

    initial begin
        // Init
        wren    = 0;
        rden    = 0;
        wrdata  = 0;
        rstA    = 0;
        rstB    = 0;
        eq_head = 0;
        eq_tail = 0;

        // -----------------------------------------------
        // TEST 1 — Reset
        // -----------------------------------------------
        $display("\n--- TEST 1: Reset ---");
        #20;
        rstA = 1;
        rstB = 1;
        #20;
        if (isempty !== 1'b1)
            $display("[FAIL] isempty should be 1 after reset, got %b", isempty);
        else
            $display("[PASS] isempty=1 after reset");

        if (isfull !== 1'b0)
            $display("[FAIL] isfull should be 0 after reset, got %b", isfull);
        else
            $display("[PASS] isfull=0 after reset");

        // Let synchronizers settle
        repeat(6) @(posedge clkA);

        // -----------------------------------------------
        // TEST 2 — Write until full
        // -----------------------------------------------
        $display("\n--- TEST 2: Fill FIFO ---");

        // Write entry 1
        @(posedge clkA); #1;
        wren = 1; wrdata = 8'h11;
        @(posedge clkA); #1;
        wren = 0;
        expected_q[eq_tail] = 8'h11; eq_tail = eq_tail + 1;

        // Write entry 2
        @(posedge clkA); #1;
        wren = 1; wrdata = 8'h22;
        @(posedge clkA); #1;
        wren = 0;
        expected_q[eq_tail] = 8'h22; eq_tail = eq_tail + 1;

        // Write entry 3
        @(posedge clkA); #1;
        wren = 1; wrdata = 8'h33;
        @(posedge clkA); #1;
        wren = 0;
        expected_q[eq_tail] = 8'h33; eq_tail = eq_tail + 1;

        // Write entry 4
        @(posedge clkA); #1;
        wren = 1; wrdata = 8'h44;
        @(posedge clkA); #1;
        wren = 0;
        expected_q[eq_tail] = 8'h44; eq_tail = eq_tail + 1;

        // Wait for isfull to propagate through synchronizer
        repeat(8) @(posedge clkA);
        if (isfull)
            $display("[PASS] FIFO correctly shows full");
        else
            $display("[FAIL] FIFO should be full");

        // -----------------------------------------------
        // TEST 3 — Write when full (should be ignored)
        // -----------------------------------------------
        $display("\n--- TEST 3: Write when Full ---");
        @(posedge clkA); #1;
        wren = 1; wrdata = 8'hFF;
        @(posedge clkA); #1;
        wren = 0;
        repeat(4) @(posedge clkA);
        if (isfull)
            $display("[PASS] Still full after overflow attempt");
        else
            $display("[FAIL] Should still be full");

        // -----------------------------------------------
        // TEST 4 — Read all data
        // -----------------------------------------------
        $display("\n--- TEST 4: Drain FIFO ---");
        repeat(4) @(posedge clkB);

        // Read entry 1
        @(posedge clkB); #1;
        // Sample FIRST, then increment
        if (rddata !== expected_q[eq_head])
            $display("[FAIL] Expected 0x%0h Got 0x%0h", expected_q[eq_head], rddata);
        else
            $display("[PASS] Read 0x%0h correct", rddata);
        eq_head = eq_head + 1;
        rden = 1;                  // increment AFTER sampling
        @(posedge clkB); #1;
        rden = 0;

        // Read entry 2
        @(posedge clkB); #1;
        rden = 1;
        @(posedge clkB); #1;
        if (rddata !== expected_q[eq_head])
            $display("[FAIL] Expected 0x%0h Got 0x%0h", expected_q[eq_head], rddata);
        else
            $display("[PASS] Read 0x%0h correct", rddata);
        eq_head = eq_head + 1;
        rden = 0;

        // Read entry 3
        @(posedge clkB); #1;
        rden = 1;
        @(posedge clkB); #1;
        if (rddata !== expected_q[eq_head])
            $display("[FAIL] Expected 0x%0h Got 0x%0h", expected_q[eq_head], rddata);
        else
            $display("[PASS] Read 0x%0h correct", rddata);
        eq_head = eq_head + 1;
        rden = 0;

        // Read entry 4
        @(posedge clkB); #1;
        rden = 1;
        @(posedge clkB); #1;
        if (rddata !== expected_q[eq_head])
            $display("[FAIL] Expected 0x%0h Got 0x%0h", expected_q[eq_head], rddata);
        else
            $display("[PASS] Read 0x%0h correct", rddata);
        eq_head = eq_head + 1;
        rden = 0;

        // Wait for isempty to propagate
        repeat(8) @(posedge clkB);
        if (isempty)
            $display("[PASS] FIFO correctly shows empty");
        else
            $display("[FAIL] FIFO should be empty");

        // -----------------------------------------------
        // TEST 5 — Read when empty (should be ignored)
        // -----------------------------------------------
        $display("\n--- TEST 5: Read when Empty ---");
        @(posedge clkB); #1;
        rden = 1;
        @(posedge clkB); #1;
        rden = 0;
        repeat(4) @(posedge clkB);
        if (isempty)
            $display("[PASS] Still empty after underflow attempt");
        else
            $display("[FAIL] Should still be empty");

        // -----------------------------------------------
        // Done
        // -----------------------------------------------
        $display("\n--- Simulation Complete ---");
        #100;
        $finish;
    end

endmodule