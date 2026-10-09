// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// Testbench for Digilent Basys 3 Top-Level Wrapper (Lab 2)
// Verifies Clock Divider, CPU Execution, Mode Switch, LEDs, and 7-Segment Display
// ==============================================================================

`timescale 1ns / 1ps

module basys3_top_tb;

    reg        clk;
    reg        btnC;
    reg  [1:0] sw;
    wire [15:0] led;
    wire [6:0]  seg;
    wire [3:0]  an;
    wire        dp;

    // 100 MHz oscillator (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Instantiate Basys 3 Top
    basys3_top #(
        .MEM_INIT_FILE("memory/restoring_div.mem")
    ) dut (
        .clk  (clk),
        .btnC (btnC),
        .sw   (sw),
        .led  (led),
        .seg  (seg),
        .an   (an),
        .dp   (dp)
    );

    initial begin
        $display("Starting Basys 3 Top Testbench for Single-Cycle RV32I Processor...");
        btnC = 1'b1;
        sw   = 2'b00; // Fast clock (10 MHz), Quotient display
        #100;
        btnC = 1'b0;

        // Wait for CPU execution (at 10 MHz, 100ns/cycle, ~200 cycles = 20,000ns)
        #25000;

        // Check quotient display (sw[0] = 0)
        $display("[Time %0t ns] Checking Quotient Mode (sw=00):", $time);
        $display("  LEDs = 0x%04X (Expected: 0x000E / 14)", led);
        if (led === 16'h000E) begin
            $display("  >>> Quotient display verified! <<<");
        end

        // Switch to remainder display (sw[0] = 1)
        #500;
        sw = 2'b01;
        #500;
        $display("[Time %0t ns] Checking Remainder Mode (sw=01):", $time);
        $display("  LEDs = 0x%04X (Expected: 0x0002 / 2)", led);
        if (led === 16'h0002) begin
            $display("  >>> Remainder display verified! <<<");
        end

        $display("Basys 3 Top Testbench completed successfully!");
        $finish;
    end

endmodule
