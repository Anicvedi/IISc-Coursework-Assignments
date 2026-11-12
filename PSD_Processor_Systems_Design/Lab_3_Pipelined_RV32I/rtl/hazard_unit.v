// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// Lab Exercise 3: 5-Stage Pipelined RISC-V Processor with Instruction Cache
// Hazard Detection & Stall/Flush Control Unit
// ==============================================================================

module hazard_unit (
    input  wire       icache_stall,
    input  wire       ex_redirect,      // Taken branch, JAL, or JALR in EX
    input  wire       id_ex_mem_read,   // Load instruction in EX
    input  wire [4:0] id_ex_rd,
    input  wire [4:0] if_id_rs1,
    input  wire [4:0] if_id_rs2,
    output wire       stall_if,
    output wire       stall_id,
    output wire       stall_ex,
    output wire       stall_mem,
    output wire       stall_wb,
    output wire       flush_if_id,
    output wire       flush_id_ex,
    output wire       load_use_stall
);

    assign load_use_stall = id_ex_mem_read && (id_ex_rd != 5'd0) &&
                            ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)) &&
                            !ex_redirect;

    // I-Cache miss stalls the entire pipeline cleanly
    assign stall_if  = icache_stall || load_use_stall;
    assign stall_id  = icache_stall || load_use_stall;
    assign stall_ex  = icache_stall;
    assign stall_mem = icache_stall;
    assign stall_wb  = icache_stall;

    // Flush wrong-path instructions on branch/jump redirect, or insert bubble on load-use
    assign flush_if_id = !icache_stall && ex_redirect;
    assign flush_id_ex = !icache_stall && (ex_redirect || load_use_stall);

endmodule
