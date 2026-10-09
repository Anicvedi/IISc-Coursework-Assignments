// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// 32-bit Single Cycle RISC-V Processor (RV32I)
// Main Control & ALU Decode Unit (Single-Cycle Combinational)
// ==============================================================================

`include "rv32i_defines.v"

module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        reg_write,
    output reg        alu_src,     // 0: rdata2, 1: immediate
    output reg  [3:0] alu_op,
    output reg        mem_read,
    output reg        mem_write,
    output reg        is_branch,
    output reg        is_jal,
    output reg        is_jalr,
    output reg        is_lui,
    output reg  [1:0] wb_sel       // 00: ALU, 01: MEM, 10: PC+4, 11: LUI
);

    always @(*) begin
        // Default values
        reg_write = 1'b0;
        alu_src   = 1'b0;
        alu_op    = `ALU_ADD;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        is_branch = 1'b0;
        is_jal    = 1'b0;
        is_jalr   = 1'b0;
        is_lui    = 1'b0;
        wb_sel    = `WB_ALU;

        case (opcode)
            `OPCODE_R_TYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                wb_sel    = `WB_ALU;
                case (funct3)
                    3'b000: alu_op = (funct7[5]) ? `ALU_SUB : `ALU_ADD;
                    3'b001: alu_op = `ALU_SLL;
                    3'b010: alu_op = `ALU_SLT;
                    3'b011: alu_op = `ALU_SLTU;
                    3'b100: alu_op = `ALU_XOR;
                    3'b101: alu_op = (funct7[5]) ? `ALU_SRA : `ALU_SRL;
                    3'b110: alu_op = `ALU_OR;
                    3'b111: alu_op = `ALU_AND;
                    default: alu_op = `ALU_ADD;
                endcase
            end

            `OPCODE_I_TYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1; // use immediate
                wb_sel    = `WB_ALU;
                case (funct3)
                    3'b000: alu_op = `ALU_ADD; // ADDI
                    3'b001: alu_op = `ALU_SLL; // SLLI
                    3'b010: alu_op = `ALU_SLT; // SLTI
                    3'b011: alu_op = `ALU_SLTU;// SLTIU
                    3'b100: alu_op = `ALU_XOR; // XORI
                    3'b101: alu_op = (funct7[5]) ? `ALU_SRA : `ALU_SRL; // SRLI / SRAI
                    3'b110: alu_op = `ALU_OR;  // ORI
                    3'b111: alu_op = `ALU_AND; // ANDI
                    default: alu_op = `ALU_ADD;
                endcase
            end

            `OPCODE_LOAD: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;       // Address = rs1 + imm
                alu_op    = `ALU_ADD;
                mem_read  = 1'b1;
                wb_sel    = `WB_MEM;    // Load data from memory
            end

            `OPCODE_STORE: begin
                reg_write = 1'b0;
                alu_src   = 1'b1;       // Address = rs1 + imm
                alu_op    = `ALU_ADD;
                mem_write = 1'b1;
            end

            `OPCODE_BRANCH: begin
                is_branch = 1'b1;
                alu_src   = 1'b0;
                alu_op    = `ALU_SUB;   // Compare operands
            end

            `OPCODE_JAL: begin
                reg_write = 1'b1;
                is_jal    = 1'b1;
                wb_sel    = `WB_PC4;    // rd = PC + 4
            end

            `OPCODE_JALR: begin
                reg_write = 1'b1;
                is_jalr   = 1'b1;
                alu_src   = 1'b1;
                alu_op    = `ALU_ADD;   // target = rs1 + imm
                wb_sel    = `WB_PC4;    // rd = PC + 4
            end

            `OPCODE_LUI: begin
                reg_write = 1'b1;
                is_lui    = 1'b1;
                wb_sel    = `WB_LUI;    // rd = imm_u
            end

            default: begin
                // Default NOP behavior
            end
        endcase
    end

endmodule
