// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// 32-bit Single Cycle RISC-V Processor (RV32I)
// Top-Level CPU Core Module
// ==============================================================================

`include "rv32i_defines.v"

module rv32i_cpu #(
    parameter MEM_INIT_FILE = "memory/restoring_div.mem"
)(
    input  wire        clk,
    input  wire        rst,

    // Debug Probes
    output wire [31:0] pc,
    output wire [31:0] instr,
    output wire [31:0] quotient,
    output wire [31:0] remainder,
    output wire [31:0] reg_x10,
    output wire [31:0] reg_x11
);

    // Control Signals
    wire        reg_write;
    wire        alu_src;
    wire [3:0]  alu_op;
    wire        mem_read;
    wire        mem_write;
    wire        is_branch;
    wire        is_jal;
    wire        is_jalr;
    wire        is_lui;
    wire [1:0]  wb_sel;

    // Memory Bus Signals
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;

    // 1. Control Unit
    control_unit u_control_unit (
        .opcode    (instr[6:0]),
        .funct3    (instr[14:12]),
        .funct7    (instr[31:25]),
        .reg_write (reg_write),
        .alu_src   (alu_src),
        .alu_op    (alu_op),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .is_branch (is_branch),
        .is_jal    (is_jal),
        .is_jalr   (is_jalr),
        .is_lui    (is_lui),
        .wb_sel    (wb_sel)
    );

    // 2. Datapath Unit
    datapath u_datapath (
        .clk        (clk),
        .rst        (rst),
        .instr      (instr),
        .pc         (pc),
        .reg_write  (reg_write),
        .alu_src    (alu_src),
        .alu_op     (alu_op),
        .is_branch  (is_branch),
        .is_jal     (is_jal),
        .is_jalr    (is_jalr),
        .is_lui     (is_lui),
        .wb_sel     (wb_sel),
        .data_addr  (data_addr),
        .data_wdata (data_wdata),
        .mem_rdata  (data_rdata),
        .debug_x10  (reg_x10),
        .debug_x11  (reg_x11)
    );

    // 3. 512-Word Distributed RAM Memory Unit
    mem_unit #(
        .MEM_INIT_FILE (MEM_INIT_FILE)
    ) u_mem_unit (
        .clk             (clk),
        .rst             (rst),
        .pc              (pc),
        .instr           (instr),
        .data_addr       (data_addr),
        .data_wdata      (data_wdata),
        .mem_read        (mem_read),
        .mem_write       (mem_write),
        .funct3          (instr[14:12]),
        .data_rdata      (data_rdata),
        .debug_quotient  (quotient),
        .debug_remainder (remainder)
    );

endmodule
