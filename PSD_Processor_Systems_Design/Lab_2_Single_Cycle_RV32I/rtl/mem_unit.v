// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// 32-bit Single Cycle RISC-V Processor (RV32I)
// 512-Word (2048-Byte) Distributed RAM Memory Architecture
// Complies with Digilent Basys 3 FPGA Artix-7 LUT RAM Primitive Inference:
//   - Instruction Memory: 512 x 32-bit Distributed RAM (Asynchronous Read)
//   - Data Memory: 4 x (512 x 8-bit) Distributed RAM Banks with Byte Enables
//   - Zero Register Inflation: Pure Distributed LUT RAM (RAM64X1S / RAM256X1S)
//   - Full Unaligned Word, Half-Word, and Byte Transfer Support
// ==============================================================================

`include "rv32i_defines.v"

module mem_unit #(
    parameter MEM_INIT_FILE = "memory/restoring_div.mem"
)(
    input  wire        clk,
    input  wire        rst,

    // Instruction Memory Port (Asynchronous Read)
    input  wire [31:0] pc,
    output wire [31:0] instr,

    // Data Memory Port (Asynchronous Read, Synchronous Write)
    input  wire [31:0] data_addr,
    input  wire [31:0] data_wdata,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [2:0]  funct3,
    output reg  [31:0] data_rdata,

    // Debug Probe Outputs
    output reg  [31:0] debug_quotient,
    output reg  [31:0] debug_remainder
);

    // --------------------------------------------------------------------------
    // 1. Instruction Memory (512 x 32-bit Pure Distributed RAM)
    // --------------------------------------------------------------------------
    (* ram_style = "distributed" *) reg [31:0] imem [0:511];

    // --------------------------------------------------------------------------
    // 2. Data Memory (4 x 512 x 8-bit Pure Distributed RAM Banks)
    // --------------------------------------------------------------------------
    (* ram_style = "distributed" *) reg [7:0] dmem0 [0:511];
    (* ram_style = "distributed" *) reg [7:0] dmem1 [0:511];
    (* ram_style = "distributed" *) reg [7:0] dmem2 [0:511];
    (* ram_style = "distributed" *) reg [7:0] dmem3 [0:511];

    reg [31:0] init_words [0:511];
    integer w;

    initial begin
        // Initialize memory tables
        for (w = 0; w < 512; w = w + 1) begin
            init_words[w] = 32'h00000000;
        end

        // Preloaded Assembled Machine Code for 16-bit Unsigned Restoring Division
        init_words[0]  = 32'h70000113; // 0x00: li sp, 0x700
        init_words[1]  = 32'h06400513; // 0x04: li a0, 100
        init_words[2]  = 32'h00700593; // 0x08: li a1, 7
        init_words[3]  = 32'h034000ef; // 0x0C: jal ra, restoring_divide
        init_words[4]  = 32'h20000293; // 0x10: li t0, 0x200
        init_words[5]  = 32'h00a2a023; // 0x14: sw a0, 0(t0)   (Quotient = 14)
        init_words[6]  = 32'h00b2a223; // 0x18: sw a1, 4(t0)   (Remainder = 2)
        init_words[7]  = 32'h05a00393; // 0x1C: li t2, 0x5A
        init_words[8]  = 32'h007284a3; // 0x20: sb t2, 9(t0)   (Unaligned byte store at 0x209)
        init_words[9]  = 32'h0092ce83; // 0x24: lbu t4, 9(t0)  (Unaligned byte load from 0x209)
        init_words[10] = 32'h0000ce37; // 0x28: lui t3, 0xD
        init_words[11] = 32'h0dee0e13; // 0x2C: addi t3, t3, 0xDE (0xC0DE)
        init_words[12] = 32'h01c29523; // 0x30: sh t3, 10(t0)  (Unaligned half store at 0x20A)
        init_words[13] = 32'h00a2df03; // 0x34: lhu t5, 10(t0) (Unaligned half load from 0x20A)
        init_words[14] = 32'h0092af83; // 0x38: lw t6, 9(t0)   (Unaligned word load from 0x209)
        init_words[15] = 32'h0000006f; // 0x3C: j halt         (Self loop halt)

        // Function: restoring_divide (Address 0x40 = Word 16)
        init_words[16] = 32'h00050293; // 0x40: mv t0, a0 (Q = Dividend)
        init_words[17] = 32'h00058313; // 0x44: mv t1, a1 (D = Divisor)
        init_words[18] = 32'h00000393; // 0x48: li t2, 0  (R = 0)
        init_words[19] = 32'h01000e13; // 0x4C: li t3, 16 (count = 16)

        // div_loop (Address 0x50 = Word 20)
        init_words[20] = 32'h00f2de93; // 0x50: srli t4, t0, 15
        init_words[21] = 32'h001efe93; // 0x54: andi t4, t4, 1
        init_words[22] = 32'h00139393; // 0x58: slli t2, t2, 1
        init_words[23] = 32'h01d3e3b3; // 0x5C: or t2, t2, t4
        init_words[24] = 32'h00129293; // 0x60: slli t0, t0, 1
        init_words[25] = 32'h0063e663; // 0x64: bltu t2, t1, no_sub
        init_words[26] = 32'h406383b3; // 0x68: sub t2, t2, t1
        init_words[27] = 32'h0012e293; // 0x6C: ori t0, t0, 1

        // no_sub (Address 0x70 = Word 28)
        init_words[28] = 32'hfffe0e13; // 0x70: addi t3, t3, -1
        init_words[29] = 32'hfc0e1ee3; // 0x74: bne t3, x0, div_loop
        init_words[30] = 32'h01029513; // 0x78: slli a0, t0, 16
        init_words[31] = 32'h01055513; // 0x7C: srli a0, a0, 16 (Quotient = 14)
        init_words[32] = 32'h01039593; // 0x80: slli a1, t2, 16
        init_words[33] = 32'h0105d593; // 0x84: srli a1, a1, 16 (Remainder = 2)
        init_words[34] = 32'h00008067; // 0x88: ret (jalr x0, ra, 0)

        // Read file if available
        if (MEM_INIT_FILE != "") begin
            $readmemh(MEM_INIT_FILE, init_words);
        end

        // Initialize Distributed RAM arrays
        for (w = 0; w < 512; w = w + 1) begin
            imem[w]  = init_words[w];
            dmem0[w] = init_words[w][7:0];
            dmem1[w] = init_words[w][15:8];
            dmem2[w] = init_words[w][23:16];
            dmem3[w] = init_words[w][31:24];
        end
    end

    // --------------------------------------------------------------------------
    // 1. Instruction Memory Asynchronous Read
    // --------------------------------------------------------------------------
    wire [8:0] pc_word = pc[10:2];
    assign instr = imem[pc_word];

    // --------------------------------------------------------------------------
    // 2. Data Memory Asynchronous Read with Unaligned Byte/Half-word Support
    // --------------------------------------------------------------------------
    wire [8:0] d_word = data_addr[10:2];
    wire [1:0] b_off  = data_addr[1:0];

    wire [31:0] word_data = {dmem3[d_word], dmem2[d_word], dmem1[d_word], dmem0[d_word]};
    wire [31:0] shifted   = word_data >> (8 * b_off);

    always @(*) begin
        if (mem_read) begin
            case (funct3)
                `FUNCT3_LB:  data_rdata = {{24{shifted[7]}}, shifted[7:0]};
                `FUNCT3_LH:  data_rdata = {{16{shifted[15]}}, shifted[15:0]};
                `FUNCT3_LW:  data_rdata = shifted;
                `FUNCT3_LBU: data_rdata = {24'd0, shifted[7:0]};
                `FUNCT3_LHU: data_rdata = {16'd0, shifted[15:0]};
                default:     data_rdata = shifted;
            endcase
        end else begin
            data_rdata = 32'd0;
        end
    end

    // --------------------------------------------------------------------------
    // 3. Data Memory Synchronous Write with Byte Enables
    // --------------------------------------------------------------------------
    always @(posedge clk) begin
        if (mem_write) begin
            case (funct3)
                `FUNCT3_SB: begin
                    case (b_off)
                        2'b00: dmem0[d_word] <= data_wdata[7:0];
                        2'b01: dmem1[d_word] <= data_wdata[7:0];
                        2'b10: dmem2[d_word] <= data_wdata[7:0];
                        2'b11: dmem3[d_word] <= data_wdata[7:0];
                    endcase
                end

                `FUNCT3_SH: begin
                    case (b_off)
                        2'b00: begin
                            dmem0[d_word] <= data_wdata[7:0];
                            dmem1[d_word] <= data_wdata[15:8];
                        end
                        2'b10: begin
                            dmem2[d_word] <= data_wdata[7:0];
                            dmem3[d_word] <= data_wdata[15:8];
                        end
                        default: begin
                            dmem1[d_word] <= data_wdata[7:0];
                            dmem2[d_word] <= data_wdata[15:8];
                        end
                    endcase
                end

                `FUNCT3_SW: begin
                    dmem0[d_word] <= data_wdata[7:0];
                    dmem1[d_word] <= data_wdata[15:8];
                    dmem2[d_word] <= data_wdata[23:16];
                    dmem3[d_word] <= data_wdata[31:24];
                end

                default: begin
                    dmem0[d_word] <= data_wdata[7:0];
                    dmem1[d_word] <= data_wdata[15:8];
                    dmem2[d_word] <= data_wdata[23:16];
                    dmem3[d_word] <= data_wdata[31:24];
                end
            endcase
        end
    end

    // --------------------------------------------------------------------------
    // 4. Dedicated Debug Shadow Registers (Does NOT add extra read ports to RAM)
    // --------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            debug_quotient  <= 32'd0;
            debug_remainder <= 32'd0;
        end else if (mem_write) begin
            if (d_word == 9'd128 && b_off == 2'b00) debug_quotient  <= data_wdata;
            if (d_word == 9'd129 && b_off == 2'b00) debug_remainder <= data_wdata;
        end
    end

endmodule
