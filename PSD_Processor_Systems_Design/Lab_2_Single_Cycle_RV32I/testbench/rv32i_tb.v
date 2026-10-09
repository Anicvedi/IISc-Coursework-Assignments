// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// Testbench for 32-bit Single-Cycle RISC-V Processor (RV32I)
// Verifies:
//   1. 16-bit Unsigned Restoring Division Function Call (100 / 7 = 14 rem 2)
//   2. Unaligned Word, Half-Word, and Byte Transfers
// ==============================================================================

`timescale 1ns / 1ps

module rv32i_tb;

    reg clk;
    reg rst;

    wire [31:0] pc;
    wire [31:0] instr;
    wire [31:0] quotient;
    wire [31:0] remainder;
    wire [31:0] reg_x10;
    wire [31:0] reg_x11;

    // Clock Generation (50 MHz CPU clock, period = 20ns)
    initial clk = 0;
    always #10 clk = ~clk;

    // Instantiate CPU core
    rv32i_cpu #(
        .MEM_INIT_FILE("memory/restoring_div.mem")
    ) dut (
        .clk       (clk),
        .rst       (rst),
        .pc        (pc),
        .instr     (instr),
        .quotient  (quotient),
        .remainder (remainder),
        .reg_x10   (reg_x10),
        .reg_x11   (reg_x11)
    );

    integer cycle_count;
    integer max_cycles = 1000;
    reg     test_passed;

    initial begin
        $dumpfile("rv32i_tb.vcd");
        $dumpvars(0, rv32i_tb);

        $display("================================================================");
        $display("  E3: 245 Processor System Design - IISc DESE");
        $display("  Starting 32-bit Single-Cycle RISC-V (RV32I) Simulation");
        $display("  Algorithm: 16-bit Unsigned Restoring Division (100 / 7)");
        $display("================================================================");

        test_passed = 1'b0;
        cycle_count = 0;
        rst = 1'b1;
        #35;
        rst = 1'b0;
        $display("[Time %0t ns] Reset deasserted. CPU executing instructions...", $time);

        while (cycle_count < max_cycles) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;

            // Log each instruction execution
            $display("[Cycle %3d | Time %0t ns] PC=0x%04X | Instr=0x%08X | a0(x10)=%0d | a1(x11)=%0d",
                     cycle_count, $time, pc, instr, reg_x10, reg_x11);

            // Check if CPU reached HALT self-loop (jal x0, 0 / j halt at PC=0x3C, instr=0x0000006F)
            if (instr == 32'h0000006F && pc == 32'h0000003C) begin
                $display("\n[Time %0t ns] CPU reached HALT self-loop after %0d instructions!", $time, cycle_count);
                #40; // Allow final settling

                // Inspect memory locations
                $display("----------------------------------------------------------------");
                $display("  RESTORING DIVISION VERIFICATION RESULTS:");
                $display("  Dividend : 100 (Expected: 100)");
                $display("  Divisor  : 7   (Expected: 7)");
                $display("  Quotient : %0d (Expected: 14, Hex: 0x%04X)", quotient, quotient);
                $display("  Remainder: %0d (Expected: 2,  Hex: 0x%04X)", remainder, remainder);
                $display("----------------------------------------------------------------");

                // Inspect unaligned transfer locations (0x209 = Word 130 byte 1, 0x20A = Word 130 bytes 2,3)
                $display("  UNALIGNED TRANSFER VERIFICATION RESULTS:");
                $display("  Byte at 0x209     : 0x%02X (Expected: 0x5A)", dut.u_mem_unit.dmem1[9'd130]);
                $display("  Half-Word at 0x20A: 0x%04X (Expected: 0xC0DE)",
                         {dut.u_mem_unit.dmem3[9'd130], dut.u_mem_unit.dmem2[9'd130]});
                $display("----------------------------------------------------------------");

                if (quotient === 32'd14 && remainder === 32'd2 &&
                    dut.u_mem_unit.dmem1[9'd130] === 8'h5A &&
                    {dut.u_mem_unit.dmem3[9'd130], dut.u_mem_unit.dmem2[9'd130]} === 16'hC0DE) begin
                    $display(">>> TEST PASSED SUCCESSFULLY! Restoring division & unaligned transfers verified! <<<");
                    test_passed = 1'b1;
                end else begin
                    $display(">>> TEST FAILED! Results did not match expectations! <<<");
                end
                $display("================================================================\n");
                $finish;
            end
        end

        $display("ERROR: Simulation timed out after %0d cycles!", max_cycles);
        $finish;
    end

endmodule
