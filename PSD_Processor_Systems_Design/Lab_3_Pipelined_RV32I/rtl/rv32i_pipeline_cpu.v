// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// Lab Exercise 3: 5-Stage Pipelined RISC-V Processor with Instruction Cache
// Top-Level CPU Core (IF -> ID -> EX -> MEM -> WB)
// ==============================================================================

`include "rv32i_defines.v"

module rv32i_pipeline_cpu #(
    parameter MEM_FILE = "restoring_div.mem"
)(
    input  wire        clk,
    input  wire        rst,
    // Debug / Board interface
    output wire [31:0] pc_out,
    output wire [31:0] quot_out,
    output wire [31:0] rem_out,
    output wire        icache_stall_out,
    output wire        load_use_stall_out,
    output wire        ex_redirect_out,
    output wire        fwd_active_out
);

    // ==========================================================================
    // 1. IF Stage: PC, Instruction Cache, Block RAM Main Instruction Memory
    // ==========================================================================
    reg  [31:0] pc;
    wire [31:0] pc_plus4 = pc + 32'd4;
    wire [31:0] if_instr;
    wire        icache_stall;
    wire        icache_miss_pulse;
    wire [8:0]  bram_addr;
    wire [31:0] bram_rdata;

    wire        stall_if, stall_id, stall_ex, stall_mem, stall_wb;
    wire        flush_if_id, flush_id_ex;
    wire        load_use_stall;
    wire        ex_redirect;
    wire [31:0] ex_target;

    assign pc_out             = pc;
    assign icache_stall_out   = icache_stall;
    assign load_use_stall_out = load_use_stall;
    assign ex_redirect_out    = ex_redirect;

    instr_bram #(
        .MEM_FILE(MEM_FILE)
    ) u_instr_bram (
        .clk   (clk),
        .addr  (bram_addr),
        .rdata (bram_rdata)
    );

    icache u_icache (
        .clk        (clk),
        .rst        (rst),
        .pc         (pc),
        .instr      (if_instr),
        .stall      (icache_stall),
        .miss_pulse (icache_miss_pulse),
        .bram_addr  (bram_addr),
        .bram_rdata (bram_rdata)
    );

    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'd0;
        end else if (!icache_stall && ex_redirect) begin
            pc <= ex_target;
        end else if (!stall_if) begin
            pc <= pc_plus4;
        end
    end

    // ==========================================================================
    // IF / ID Pipeline Register
    // ==========================================================================
    reg [31:0] if_id_pc;
    reg [31:0] if_id_pc_plus4;
    reg [31:0] if_id_instr;

    always @(posedge clk) begin
        if (rst || flush_if_id) begin
            if_id_pc       <= 32'd0;
            if_id_pc_plus4 <= 32'd0;
            if_id_instr    <= 32'h00000013; // NOP
        end else if (!stall_id) begin
            if_id_pc       <= pc;
            if_id_pc_plus4 <= pc_plus4;
            if_id_instr    <= if_instr;
        end
    end

    // ==========================================================================
    // 2. ID Stage: Decode, Immediate Generation, Register File Read
    // ==========================================================================
    wire [6:0]  id_opcode = if_id_instr[6:0];
    wire [4:0]  id_rs1    = if_id_instr[19:15];
    wire [4:0]  id_rs2    = if_id_instr[24:20];
    wire [4:0]  id_rd     = if_id_instr[11:7];
    wire [2:0]  id_funct3 = if_id_instr[14:12];
    wire [6:0]  id_funct7 = if_id_instr[31:25];

    wire        id_reg_write, id_mem_read, id_mem_write;
    wire        id_branch, id_jal, id_jalr, id_lui, id_alu_src_b;
    wire [1:0]  id_wb_sel;
    wire [3:0]  id_alu_op;
    wire [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
    reg  [31:0] id_imm;
    wire [31:0] id_rdata1, id_rdata2;

    // WB signals declared here for reg_file connection
    reg         mem_wb_reg_write;
    reg  [4:0]  mem_wb_rd;
    reg  [31:0] wb_wdata;

    control_unit u_ctrl (
        .opcode    (id_opcode),
        .funct3    (id_funct3),
        .funct7    (id_funct7),
        .reg_write (id_reg_write),
        .alu_src   (id_alu_src_b),
        .alu_op    (id_alu_op),
        .mem_read  (id_mem_read),
        .mem_write (id_mem_write),
        .is_branch (id_branch),
        .is_jal    (id_jal),
        .is_jalr   (id_jalr),
        .is_lui    (id_lui),
        .wb_sel    (id_wb_sel)
    );

    imm_gen u_imm_gen (
        .instr (if_id_instr),
        .imm_i (imm_i),
        .imm_s (imm_s),
        .imm_b (imm_b),
        .imm_u (imm_u),
        .imm_j (imm_j)
    );

    always @(*) begin
        if (id_mem_write)      id_imm = imm_s;
        else if (id_branch)    id_imm = imm_b;
        else if (id_jal)       id_imm = imm_j;
        else if (id_lui)       id_imm = imm_u;
        else                   id_imm = imm_i;
    end

    reg_file u_reg_file (
        .clk    (clk),
        .rst    (rst),
        .we     (mem_wb_reg_write && !stall_wb),
        .raddr1 (id_rs1),
        .raddr2 (id_rs2),
        .waddr  (mem_wb_rd),
        .wdata  (wb_wdata),
        .rdata1 (id_rdata1),
        .rdata2 (id_rdata2)
    );

    // ==========================================================================
    // ID / EX Pipeline Register
    // ==========================================================================
    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_pc_plus4;
    reg [31:0] id_ex_rdata1;
    reg [31:0] id_ex_rdata2;
    reg [31:0] id_ex_imm;
    reg [4:0]  id_ex_rs1;
    reg [4:0]  id_ex_rs2;
    reg [4:0]  id_ex_rd;
    reg [2:0]  id_ex_funct3;
    reg [3:0]  id_ex_alu_op;
    reg        id_ex_alu_src_b;
    reg        id_ex_mem_read;
    reg        id_ex_mem_write;
    reg        id_ex_reg_write;
    reg [1:0]  id_ex_wb_sel;
    reg        id_ex_branch;
    reg        id_ex_jal;
    reg        id_ex_jalr;

    always @(posedge clk) begin
        if (rst || flush_id_ex) begin
            id_ex_pc        <= 32'd0;
            id_ex_pc_plus4  <= 32'd0;
            id_ex_rdata1    <= 32'd0;
            id_ex_rdata2    <= 32'd0;
            id_ex_imm       <= 32'd0;
            id_ex_rs1       <= 5'd0;
            id_ex_rs2       <= 5'd0;
            id_ex_rd        <= 5'd0;
            id_ex_funct3    <= 3'd0;
            id_ex_alu_op    <= `ALU_ADD;
            id_ex_alu_src_b <= 1'b0;
            id_ex_mem_read  <= 1'b0;
            id_ex_mem_write <= 1'b0;
            id_ex_reg_write <= 1'b0;
            id_ex_wb_sel    <= `WB_ALU;
            id_ex_branch    <= 1'b0;
            id_ex_jal       <= 1'b0;
            id_ex_jalr      <= 1'b0;
        end else if (!stall_ex) begin
            id_ex_pc        <= if_id_pc;
            id_ex_pc_plus4  <= if_id_pc_plus4;
            id_ex_rdata1    <= id_rdata1;
            id_ex_rdata2    <= id_rdata2;
            id_ex_imm       <= id_imm;
            id_ex_rs1       <= id_rs1;
            id_ex_rs2       <= id_rs2;
            id_ex_rd        <= id_rd;
            id_ex_funct3    <= id_funct3;
            id_ex_alu_op    <= id_alu_op;
            id_ex_alu_src_b <= id_alu_src_b;
            id_ex_mem_read  <= id_mem_read;
            id_ex_mem_write <= id_mem_write;
            id_ex_reg_write <= id_reg_write;
            id_ex_wb_sel    <= id_wb_sel;
            id_ex_branch    <= id_branch;
            id_ex_jal       <= id_jal;
            id_ex_jalr      <= id_jalr;
        end
    end

    // ==========================================================================
    // 3. EX Stage: Forwarding Muxes, ALU, Branch Unit, Target Address
    // ==========================================================================
    reg         ex_mem_reg_write;
    reg  [4:0]  ex_mem_rd;
    reg  [31:0] ex_mem_fwd_data;

    wire [1:0]  fwd_a, fwd_b;
    assign fwd_active_out = (fwd_a != 2'b00) || (fwd_b != 2'b00);

    forwarding_unit u_fwd (
        .id_ex_rs1        (id_ex_rs1),
        .id_ex_rs2        (id_ex_rs2),
        .ex_mem_rd        (ex_mem_rd),
        .ex_mem_reg_write (ex_mem_reg_write),
        .mem_wb_rd        (mem_wb_rd),
        .mem_wb_reg_write (mem_wb_reg_write),
        .fwd_a            (fwd_a),
        .fwd_b            (fwd_b)
    );

    reg [31:0] ex_op_a_fwd, ex_op_b_fwd;
    always @(*) begin
        case (fwd_a)
            2'b10:   ex_op_a_fwd = ex_mem_fwd_data;
            2'b01:   ex_op_a_fwd = wb_wdata;
            default: ex_op_a_fwd = id_ex_rdata1;
        endcase

        case (fwd_b)
            2'b10:   ex_op_b_fwd = ex_mem_fwd_data;
            2'b01:   ex_op_b_fwd = wb_wdata;
            default: ex_op_b_fwd = id_ex_rdata2;
        endcase
    end

    wire [31:0] alu_b = id_ex_alu_src_b ? id_ex_imm : ex_op_b_fwd;
    wire [31:0] ex_alu_result;
    wire        ex_branch_cond;

    alu u_alu (
        .a      (ex_op_a_fwd),
        .b      (alu_b),
        .alu_op (id_ex_alu_op),
        .result (ex_alu_result)
    );

    branch_unit u_branch (
        .funct3      (id_ex_funct3),
        .a           (ex_op_a_fwd),
        .b           (ex_op_b_fwd),
        .take_branch (ex_branch_cond)
    );

    assign ex_redirect = (id_ex_branch && ex_branch_cond) || id_ex_jal || id_ex_jalr;
    assign ex_target   = id_ex_jalr ? ((ex_op_a_fwd + id_ex_imm) & ~32'd1)
                                    : (id_ex_pc + id_ex_imm);

    // Value produced by EX stage for forwarding (ALU, PC+4 for JAL/JALR, or Imm for LUI)
    reg [31:0] ex_result_for_fwd;
    always @(*) begin
        case (id_ex_wb_sel)
            `WB_PC4: ex_result_for_fwd = id_ex_pc_plus4;
            `WB_LUI: ex_result_for_fwd = id_ex_imm;
            default: ex_result_for_fwd = ex_alu_result;
        endcase
    end

    // Hazard Unit
    hazard_unit u_hazard (
        .icache_stall   (icache_stall),
        .ex_redirect    (ex_redirect),
        .id_ex_mem_read (id_ex_mem_read),
        .id_ex_rd       (id_ex_rd),
        .if_id_rs1      (id_rs1),
        .if_id_rs2      (id_rs2),
        .stall_if       (stall_if),
        .stall_id       (stall_id),
        .stall_ex       (stall_ex),
        .stall_mem      (stall_mem),
        .stall_wb       (stall_wb),
        .flush_if_id    (flush_if_id),
        .flush_id_ex    (flush_id_ex),
        .load_use_stall (load_use_stall)
    );

    // ==========================================================================
    // EX / MEM Pipeline Register
    // ==========================================================================
    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_store_data;
    reg [31:0] ex_mem_pc_plus4;
    reg [31:0] ex_mem_imm;
    reg [2:0]  ex_mem_funct3;
    reg        ex_mem_mem_read;
    reg        ex_mem_mem_write;
    reg [1:0]  ex_mem_wb_sel;

    always @(posedge clk) begin
        if (rst) begin
            ex_mem_alu_result <= 32'd0;
            ex_mem_store_data <= 32'd0;
            ex_mem_pc_plus4   <= 32'd0;
            ex_mem_imm        <= 32'd0;
            ex_mem_fwd_data   <= 32'd0;
            ex_mem_rd         <= 5'd0;
            ex_mem_funct3     <= 3'd0;
            ex_mem_mem_read   <= 1'b0;
            ex_mem_mem_write  <= 1'b0;
            ex_mem_reg_write  <= 1'b0;
            ex_mem_wb_sel     <= `WB_ALU;
        end else if (!stall_mem) begin
            ex_mem_alu_result <= ex_alu_result;
            ex_mem_store_data <= ex_op_b_fwd;
            ex_mem_pc_plus4   <= id_ex_pc_plus4;
            ex_mem_imm        <= id_ex_imm;
            ex_mem_fwd_data   <= ex_result_for_fwd;
            ex_mem_rd         <= id_ex_rd;
            ex_mem_funct3     <= id_ex_funct3;
            ex_mem_mem_read   <= id_ex_mem_read;
            ex_mem_mem_write  <= id_ex_mem_write;
            ex_mem_reg_write  <= id_ex_reg_write;
            ex_mem_wb_sel     <= id_ex_wb_sel;
        end
    end

    // ==========================================================================
    // 4. MEM Stage: Unaligned Data Memory Access
    // ==========================================================================
    wire [31:0] mem_rdata;

    data_mem u_data_mem (
        .clk       (clk),
        .mem_read  (ex_mem_mem_read),
        .mem_write (ex_mem_mem_write && !stall_mem),
        .funct3    (ex_mem_funct3),
        .addr      (ex_mem_alu_result),
        .wdata     (ex_mem_store_data),
        .rdata     (mem_rdata),
        .dbg_quot  (quot_out),
        .dbg_rem   (rem_out)
    );

    // ==========================================================================
    // MEM / WB Pipeline Register
    // ==========================================================================
    reg [31:0] mem_wb_alu_result;
    reg [31:0] mem_wb_mem_rdata;
    reg [31:0] mem_wb_pc_plus4;
    reg [31:0] mem_wb_imm;
    reg [1:0]  mem_wb_wb_sel;

    always @(posedge clk) begin
        if (rst) begin
            mem_wb_alu_result <= 32'd0;
            mem_wb_mem_rdata  <= 32'd0;
            mem_wb_pc_plus4   <= 32'd0;
            mem_wb_imm        <= 32'd0;
            mem_wb_rd         <= 5'd0;
            mem_wb_reg_write  <= 1'b0;
            mem_wb_wb_sel     <= `WB_ALU;
        end else if (!stall_wb) begin
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_mem_rdata  <= mem_rdata;
            mem_wb_pc_plus4   <= ex_mem_pc_plus4;
            mem_wb_imm        <= ex_mem_imm;
            mem_wb_rd         <= ex_mem_rd;
            mem_wb_reg_write  <= ex_mem_reg_write;
            mem_wb_wb_sel     <= ex_mem_wb_sel;
        end
    end

    // ==========================================================================
    // 5. WB Stage: Writeback Multiplexer
    // ==========================================================================
    always @(*) begin
        case (mem_wb_wb_sel)
            `WB_ALU: wb_wdata = mem_wb_alu_result;
            `WB_MEM: wb_wdata = mem_wb_mem_rdata;
            `WB_PC4: wb_wdata = mem_wb_pc_plus4;
            `WB_LUI: wb_wdata = mem_wb_imm;
            default: wb_wdata = mem_wb_alu_result;
        endcase
    end

endmodule
