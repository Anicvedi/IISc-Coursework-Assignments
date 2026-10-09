// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// 32-bit Single Cycle RISC-V Processor (RV32I)
// Global Defines & Instruction Encodings
// ==============================================================================

`ifndef RV32I_DEFINES_V
`define RV32I_DEFINES_V

// RV32I Major Opcodes (instr[6:0])
`define OPCODE_R_TYPE   7'b0110011 // ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
`define OPCODE_I_TYPE   7'b0010011 // ADDI, SLLI, SLTI, SLTIU, XORI, SRLI, SRAI, ORI, ANDI
`define OPCODE_LOAD     7'b0000011 // LB, LH, LW, LBU, LHU
`define OPCODE_STORE    7'b0100011 // SB, SH, SW
`define OPCODE_BRANCH   7'b1100011 // BEQ, BNE, BLT, BGE, BLTU, BGEU
`define OPCODE_JAL      7'b1101111 // JAL
`define OPCODE_JALR     7'b1100111 // JALR
`define OPCODE_LUI      7'b0110111 // LUI
`define OPCODE_AUIPC    7'b0010111 // AUIPC

// Funct3 for Branches
`define FUNCT3_BEQ      3'b000
`define FUNCT3_BNE      3'b001
`define FUNCT3_BLT      3'b100
`define FUNCT3_BGE      3'b101
`define FUNCT3_BLTU     3'b110
`define FUNCT3_BGEU     3'b111

// Funct3 for Loads
`define FUNCT3_LB       3'b000
`define FUNCT3_LH       3'b001
`define FUNCT3_LW       3'b010
`define FUNCT3_LBU      3'b100
`define FUNCT3_LHU      3'b101

// Funct3 for Stores
`define FUNCT3_SB       3'b000
`define FUNCT3_SH       3'b001
`define FUNCT3_SW       3'b010

// ALU Operation Codes (alu_op[3:0])
`define ALU_ADD         4'd0
`define ALU_SUB         4'd1
`define ALU_SLL         4'd2
`define ALU_SLT         4'd3
`define ALU_SLTU        4'd4
`define ALU_XOR         4'd5
`define ALU_SRL         4'd6
`define ALU_SRA         4'd7
`define ALU_OR          4'd8
`define ALU_AND         4'd9
`define ALU_PASS_B      4'd10

// Writeback Source Select (wb_sel[1:0])
`define WB_ALU          2'b00
`define WB_MEM          2'b01
`define WB_PC4          2'b10
`define WB_LUI          2'b11

`endif
