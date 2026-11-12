// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// Lab Exercise 3: 5-Stage Pipelined RISC-V Processor with Instruction Cache
// Basys 3 Top-Level Testbench (Behavioral & Post-Route Timing Simulation)
// ==============================================================================

`timescale 1ns / 1ps

module basys3_top_tb;

    reg        clk;
    reg        btnC;
    reg  [1:0] sw;
    wire [15:0] led;
    wire [6:0] seg;
    wire       dp;
    wire [3:0] an;

    basys3_top dut (
        .clk  (clk),
        .btnC (btnC),
        .sw   (sw),
        .led  (led),
        .seg  (seg),
        .dp   (dp),
        .an   (an)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk; // 100 MHz (10 ns period)

    initial begin
        btnC = 1'b1;
        sw   = 2'b00;
        #100; // Wait 100 ns for GSR in post-route timing simulation
        btnC = 1'b0;

        // Run 500 cycles (5000 ns)
        #5000;

        sw = 2'b00;
        #20;
        $display("POST-ROUTE / TOP SIM: sw=00 (Quotient)  led = 0x%04h (%0d) [Expected: 14]", led, led);
        if (led !== 16'd14) begin
            $display("FAIL: Quotient mismatch on LEDs!");
            $fatal(1);
        end

        sw = 2'b01;
        #20;
        $display("POST-ROUTE / TOP SIM: sw=01 (Remainder) led = 0x%04h (%0d) [Expected: 2]", led, led);
        if (led !== 16'd2) begin
            $display("FAIL: Remainder mismatch on LEDs!");
            $fatal(1);
        end

        $display("PASS: basys3_top verified (Quotient=14, Remainder=2)!");
        $finish;
    end

endmodule
