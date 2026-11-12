// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// 32-bit Single Cycle RISC-V Processor (RV32I)
// Branch Condition Evaluation Unit
// ==============================================================================

`include "rv32i_defines.v"

module branch_unit (
    input  wire [2:0]  funct3,
    input  wire [31:0] a,
    input  wire [31:0] b,
    output reg         take_branch
);

    always @(*) begin
        case (funct3)
            `FUNCT3_BEQ:  take_branch = (a == b);
            `FUNCT3_BNE:  take_branch = (a != b);
            `FUNCT3_BLT:  take_branch = ($signed(a) < $signed(b));
            `FUNCT3_BGE:  take_branch = ($signed(a) >= $signed(b));
            `FUNCT3_BLTU: take_branch = (a < b);
            `FUNCT3_BGEU: take_branch = (a >= b);
            default:      take_branch = 1'b0;
        endcase
    end

endmodule
