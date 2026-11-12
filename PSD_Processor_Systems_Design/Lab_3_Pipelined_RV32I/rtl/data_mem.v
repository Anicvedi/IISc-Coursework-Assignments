// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// Lab Exercise 3: 5-Stage Pipelined RISC-V Processor with Instruction Cache
// Data Memory (4 x 512x8-bit Distributed RAM Banks) with Unaligned B/H/W Support
// ==============================================================================

`include "rv32i_defines.v"

module data_mem (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [2:0]  funct3,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,
    // Debug / Display outputs for Basys3 LEDs & 7-seg (MEM[0x200], MEM[0x204])
    output reg  [31:0] dbg_quot,
    output reg  [31:0] dbg_rem
);

    // 4 byte-wide Distributed RAM banks (512 words = 2048 bytes total)
    (* ram_style = "distributed" *) reg [7:0] bank0 [0:511];
    (* ram_style = "distributed" *) reg [7:0] bank1 [0:511];
    (* ram_style = "distributed" *) reg [7:0] bank2 [0:511];
    (* ram_style = "distributed" *) reg [7:0] bank3 [0:511];

    integer i;
    initial begin
        for (i = 0; i < 512; i = i + 1) begin
            bank0[i] = 8'h00;
            bank1[i] = 8'h00;
            bank2[i] = 8'h00;
            bank3[i] = 8'h00;
        end
        dbg_quot = 32'd0;
        dbg_rem  = 32'd0;
    end

    wire [8:0] word_idx = addr[10:2];
    wire [8:0] next_idx = word_idx + 9'd1;
    wire [1:0] byte_off = addr[1:0];

    // Single address per bank for both unaligned read & write
    wire [8:0] idx0 = (byte_off == 2'd0) ? word_idx : next_idx;
    wire [8:0] idx1 = (byte_off <= 2'd1) ? word_idx : next_idx;
    wire [8:0] idx2 = (byte_off <= 2'd2) ? word_idx : next_idx;
    wire [8:0] idx3 = word_idx;

    // Determine which logical byte (b0, b1, b2, b3) maps to each bank and write enables
    reg       we0, we1, we2, we3;
    reg [7:0] wd0, wd1, wd2, wd3;

    always @(*) begin
        we0 = 1'b0; we1 = 1'b0; we2 = 1'b0; we3 = 1'b0;
        wd0 = 8'd0; wd1 = 8'd0; wd2 = 8'd0; wd3 = 8'd0;
        if (mem_write) begin
            case (byte_off)
                2'd0: begin
                    case (funct3)
                        `FUNCT3_SB: begin we0 = 1'b1; wd0 = wdata[7:0]; end
                        `FUNCT3_SH: begin we0 = 1'b1; we1 = 1'b1; wd0 = wdata[7:0]; wd1 = wdata[15:8]; end
                        `FUNCT3_SW: begin we0 = 1'b1; we1 = 1'b1; we2 = 1'b1; we3 = 1'b1;
                                          wd0 = wdata[7:0]; wd1 = wdata[15:8]; wd2 = wdata[23:16]; wd3 = wdata[31:24]; end
                        default: ;
                    endcase
                end
                2'd1: begin
                    case (funct3)
                        `FUNCT3_SB: begin we1 = 1'b1; wd1 = wdata[7:0]; end
                        `FUNCT3_SH: begin we1 = 1'b1; we2 = 1'b1; wd1 = wdata[7:0]; wd2 = wdata[15:8]; end
                        `FUNCT3_SW: begin we1 = 1'b1; we2 = 1'b1; we3 = 1'b1; we0 = 1'b1;
                                          wd1 = wdata[7:0]; wd2 = wdata[15:8]; wd3 = wdata[23:16]; wd0 = wdata[31:24]; end
                        default: ;
                    endcase
                end
                2'd2: begin
                    case (funct3)
                        `FUNCT3_SB: begin we2 = 1'b1; wd2 = wdata[7:0]; end
                        `FUNCT3_SH: begin we2 = 1'b1; we3 = 1'b1; wd2 = wdata[7:0]; wd3 = wdata[15:8]; end
                        `FUNCT3_SW: begin we2 = 1'b1; we3 = 1'b1; we0 = 1'b1; we1 = 1'b1;
                                          wd2 = wdata[7:0]; wd3 = wdata[15:8]; wd0 = wdata[23:16]; wd1 = wdata[31:24]; end
                        default: ;
                    endcase
                end
                2'd3: begin
                    case (funct3)
                        `FUNCT3_SB: begin we3 = 1'b1; wd3 = wdata[7:0]; end
                        `FUNCT3_SH: begin we3 = 1'b1; we0 = 1'b1; wd3 = wdata[7:0]; wd0 = wdata[15:8]; end
                        `FUNCT3_SW: begin we3 = 1'b1; we0 = 1'b1; we1 = 1'b1; we2 = 1'b1;
                                          wd3 = wdata[7:0]; wd0 = wdata[15:8]; wd1 = wdata[23:16]; wd2 = wdata[31:24]; end
                        default: ;
                    endcase
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (we0) bank0[idx0] <= wd0;
        if (we1) bank1[idx1] <= wd1;
        if (we2) bank2[idx2] <= wd2;
        if (we3) bank3[idx3] <= wd3;

        // Capture Quotient (0x200) and Remainder (0x204) for Basys3 display
        if (mem_write && (funct3 == `FUNCT3_SW) && (byte_off == 2'd0)) begin
            if (word_idx == 9'h080) dbg_quot <= wdata;
            if (word_idx == 9'h081) dbg_rem  <= wdata;
        end
    end

    // Asynchronous Distributed RAM read from the 4 banks
    wire [7:0] r0 = bank0[idx0];
    wire [7:0] r1 = bank1[idx1];
    wire [7:0] r2 = bank2[idx2];
    wire [7:0] r3 = bank3[idx3];

    reg [7:0] b0, b1, b2, b3;
    always @(*) begin
        case (byte_off)
            2'd0: begin b0 = r0; b1 = r1; b2 = r2; b3 = r3; end
            2'd1: begin b0 = r1; b1 = r2; b2 = r3; b3 = r0; end
            2'd2: begin b0 = r2; b1 = r3; b2 = r0; b3 = r1; end
            2'd3: begin b0 = r3; b1 = r0; b2 = r1; b3 = r2; end
        endcase
    end

    always @(*) begin
        if (!mem_read) begin
            rdata = 32'd0;
        end else begin
            case (funct3)
                `FUNCT3_LB:  rdata = {{24{b0[7]}}, b0};
                `FUNCT3_LH:  rdata = {{16{b1[7]}}, b1, b0};
                `FUNCT3_LW:  rdata = {b3, b2, b1, b0};
                `FUNCT3_LBU: rdata = {24'd0, b0};
                `FUNCT3_LHU: rdata = {16'd0, b1, b0};
                default:     rdata = 32'd0;
            endcase
        end
    end

endmodule
