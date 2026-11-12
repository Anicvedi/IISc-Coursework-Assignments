// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// 32-bit Single Cycle RISC-V Processor (RV32I)
// Immediate Generator Unit
// ==============================================================================

module imm_gen (
    input  wire [31:0] instr,
    output wire [31:0] imm_i,
    output wire [31:0] imm_s,
    output wire [31:0] imm_b,
    output wire [31:0] imm_u,
    output wire [31:0] imm_j
);

    // I-type immediate (12-bit signed)
    assign imm_i = {{20{instr[31]}}, instr[31:20]};

    // S-type immediate (12-bit signed: split fields)
    assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};

    // B-type immediate (13-bit signed: branch offset, LSB=0)
    assign imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

    // U-type immediate (20-bit upper: LUI, AUIPC)
    assign imm_u = {instr[31:12], 12'h000};

    // J-type immediate (21-bit signed: JAL target, LSB=0)
    assign imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

endmodule
