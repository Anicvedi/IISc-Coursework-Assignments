// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// 32-bit Single Cycle RISC-V Processor (RV32I)
// Single-Cycle Datapath
// ==============================================================================

`include "rv32i_defines.v"

module datapath (
    input  wire        clk,
    input  wire        rst,

    // Instruction input from MemUnit
    input  wire [31:0] instr,
    output reg  [31:0] pc,

    // Control signals from ControlUnit
    input  wire        reg_write,
    input  wire        alu_src,
    input  wire [3:0]  alu_op,
    input  wire        is_branch,
    input  wire        is_jal,
    input  wire        is_jalr,
    input  wire        is_lui,
    input  wire [1:0]  wb_sel,

    // Data Memory interface to MemUnit
    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    input  wire [31:0] mem_rdata,

    // Debug probes
    output wire [31:0] debug_x10,
    output wire [31:0] debug_x11
);

    // Instruction field breakdown
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [6:0] funct7 = instr[31:25];

    // 1. Immediate Generator
    wire [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
    imm_gen u_imm_gen (
        .instr (instr),
        .imm_i (imm_i),
        .imm_s (imm_s),
        .imm_b (imm_b),
        .imm_u (imm_u),
        .imm_j (imm_j)
    );

    // Selected immediate for ALU input B
    wire [31:0] imm_for_alu = (opcode == `OPCODE_STORE) ? imm_s : imm_i;

    // 2. Register File
    wire [31:0] rdata1, rdata2;
    reg  [31:0] reg_wdata;

    reg_file u_reg_file (
        .clk    (clk),
        .rst    (rst),
        .raddr1 (rs1),
        .raddr2 (rs2),
        .waddr  (rd),
        .wdata  (reg_wdata),
        .we     (reg_write),
        .rdata1 (rdata1),
        .rdata2 (rdata2),
        .x10    (debug_x10),
        .x11    (debug_x11)
    );

    // 3. Branch Condition Evaluator
    wire branch_condition_met;
    branch_unit u_branch_unit (
        .funct3      (funct3),
        .a           (rdata1),
        .b           (rdata2),
        .take_branch (branch_condition_met)
    );

    wire take_branch = is_branch && branch_condition_met;

    // 4. ALU Operands and Core
    wire [31:0] alu_in_a = rdata1;
    wire [31:0] alu_in_b = (alu_src) ? imm_for_alu : rdata2;
    wire [31:0] alu_result;
    wire        alu_zero;

    alu u_alu (
        .a      (alu_in_a),
        .b      (alu_in_b),
        .alu_op (alu_op),
        .result (alu_result),
        .zero   (alu_zero)
    );

    // Data memory address & write data
    assign data_addr  = alu_result;
    assign data_wdata = rdata2;

    // 5. Writeback Multiplexer
    wire [31:0] pc_plus_4 = pc + 32'd4;

    always @(*) begin
        case (wb_sel)
            `WB_ALU: reg_wdata = alu_result;
            `WB_MEM: reg_wdata = mem_rdata;
            `WB_PC4: reg_wdata = pc_plus_4;
            `WB_LUI: reg_wdata = imm_u;
            default: reg_wdata = alu_result;
        endcase
    end

    // 6. Next PC Logic (Single Cycle)
    wire [31:0] pc_branch = pc + imm_b;
    wire [31:0] pc_jal    = pc + imm_j;
    wire [31:0] pc_jalr   = (rdata1 + imm_i) & ~32'd1;

    reg [31:0] next_pc;
    always @(*) begin
        if (is_jalr) begin
            next_pc = pc_jalr;
        end else if (is_jal) begin
            next_pc = pc_jal;
        end else if (take_branch) begin
            next_pc = pc_branch;
        end else begin
            next_pc = pc_plus_4;
        end
    end

    // PC Register update
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'h00000000;
        end else begin
            pc <= next_pc;
        end
    end

endmodule
