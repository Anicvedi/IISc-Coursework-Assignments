// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// Lab Exercise 3: 5-Stage Pipelined RISC-V Processor with Instruction Cache
// Behavioral Testbench
// ==============================================================================

`timescale 1ns / 1ps

module rv32i_pipeline_tb;

    reg clk;
    reg rst;

    wire [31:0] pc_out;
    wire [31:0] quot_out;
    wire [31:0] rem_out;
    wire        icache_stall_out;
    wire        load_use_stall_out;
    wire        ex_redirect_out;
    wire        fwd_active_out;

    rv32i_pipeline_cpu #(
        .MEM_FILE("Academics/PSD/Lab3/memory/restoring_div.mem")
    ) dut (
        .clk                (clk),
        .rst                (rst),
        .pc_out             (pc_out),
        .quot_out           (quot_out),
        .rem_out            (rem_out),
        .icache_stall_out   (icache_stall_out),
        .load_use_stall_out (load_use_stall_out),
        .ex_redirect_out    (ex_redirect_out),
        .fwd_active_out     (fwd_active_out)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk; // 100 MHz

    integer cyc;
    integer icache_miss_cycles = 0;
    integer icache_misses      = 0;
    integer load_use_stalls    = 0;
    integer branch_flushes     = 0;
    integer fwd_events         = 0;
    reg     prev_icache_stall  = 0;

    wire [31:0] mem_0x208 = {dut.u_data_mem.bank3[9'h082], dut.u_data_mem.bank2[9'h082], dut.u_data_mem.bank1[9'h082], dut.u_data_mem.bank0[9'h082]};
    wire [31:0] mem_0x20C = {dut.u_data_mem.bank3[9'h083], dut.u_data_mem.bank2[9'h083], dut.u_data_mem.bank1[9'h083], dut.u_data_mem.bank0[9'h083]};
    wire [31:0] mem_0x210 = {dut.u_data_mem.bank3[9'h084], dut.u_data_mem.bank2[9'h084], dut.u_data_mem.bank1[9'h084], dut.u_data_mem.bank0[9'h084]};

    initial begin
        $dumpfile("Academics/PSD/Lab3/reports/rv32i_pipeline_tb.vcd");
        $dumpvars(0, rv32i_pipeline_tb);

        rst = 1'b1;
        #25;
        rst = 1'b0;

        for (cyc = 0; cyc < 500; cyc = cyc + 1) begin
            @(posedge clk);
            if (icache_stall_out)
                icache_miss_cycles = icache_miss_cycles + 1;
            if (icache_stall_out && !prev_icache_stall)
                icache_misses = icache_misses + 1;
            prev_icache_stall = icache_stall_out;

            if (load_use_stall_out && !icache_stall_out)
                load_use_stalls = load_use_stalls + 1;
            if (ex_redirect_out && !icache_stall_out)
                branch_flushes = branch_flushes + 1;
            if (fwd_active_out && !icache_stall_out)
                fwd_events = fwd_events + 1;
        end

        $display("============================================================");
        $display("Lab 3 Behavioral Simulation Results (100 / 7 Restoring Div)");
        $display("============================================================");
        $display("Quotient  MEM[0x200] = %0d (0x%08h) [Expected: 14]", quot_out, quot_out);
        $display("Remainder MEM[0x204] = %0d (0x%08h) [Expected: 2]",  rem_out, rem_out);
        $display("Unaligned MEM[0x208] = 0x%08h [Expected: 0xC0DE5A00]", mem_0x208);
        $display("Unaligned MEM[0x210] = 0x%08h [Expected: 0x00C0DE5B]", mem_0x210);
        $display("Final PC             = 0x%08h", pc_out);
        $display("------------------------------------------------------------");
        $display("I-Cache Misses       = %0d (Total stall cycles: %0d)", icache_misses, icache_miss_cycles);
        $display("Load-Use Stalls      = %0d", load_use_stalls);
        $display("Branch/Jump Flushes  = %0d", branch_flushes);
        $display("Forwarding Events    = %0d", fwd_events);
        $display("============================================================");

        if (quot_out !== 32'd14 || rem_out !== 32'd2 || mem_0x208 !== 32'hC0DE5A00 || mem_0x210 !== 32'h00C0DE5B) begin
            $display("FAIL: Output mismatch!");
            $fatal(1);
        end
        if (icache_misses == 0 || load_use_stalls == 0 || branch_flushes == 0 || fwd_events == 0) begin
            $display("FAIL: Missing expected pipeline/cache events!");
            $fatal(1);
        end
        $display("PASS: All functional, hazard, forwarding, and I-Cache checks passed!");
        $finish;
    end

endmodule
