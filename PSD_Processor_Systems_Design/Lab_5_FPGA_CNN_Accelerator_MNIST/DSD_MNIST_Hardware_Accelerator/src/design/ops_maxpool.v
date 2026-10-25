`timescale 1ns / 1ps

module ops_maxpool(
    input   CLK_IN,
    input   RESET,
    input MODULE_EN,
    
    input EXT_START_OF_COMPUTE,
    output reg EXT_END_OF_COMPUTE,

    input [13:0] IN_FMAP_BASEADDR,
    input [9:0] IN_FMAP_DIM_W,
    input [9:0] IN_FMAP_DIM_H,
    input [9:0] IN_FMAP_DIM_C,

    input [13:0] OUT_FMAP_BASEADDR,
    input [9:0] OUT_FMAP_DIM_W,
    input [9:0] OUT_FMAP_DIM_H,
    input [9:0] OUT_FMAP_DIM_C,

    input [7:0] POOL_KERNEL_SIZE,

    output reg BRAM_ena,
    output reg BRAM_wea,
    output reg [13:0] BRAM_addra,
    output reg [127:0] BRAM_dina,

    output reg BRAM_enb,
    output reg [13:0] BRAM_addrb,
    input [127:0] BRAM_doutb
    );
    
    wire CLK;
    assign CLK = CLK_IN;

    localparam AGU_PREP = 2'd0;
    localparam AGU_W0   = 2'd1;
    localparam AGU_W1   = 2'd2;

    reg running;
    reg [1:0] agu_phase;
    reg [9:0] x_out, y_out, c, pool_y;
    
    reg p1_valid, p2_valid, p3_valid, p4_valid;
    reg [9:0] p1_x_in, p2_x_in, p3_x_in, p4_x_in;
    reg p1_is_first_pool, p2_is_first_pool, p3_is_first_pool, p4_is_first_pool;
    reg p1_is_last_pool,  p2_is_last_pool,  p3_is_last_pool,  p4_is_last_pool;
    reg p1_is_last_x,     p2_is_last_x,     p3_is_last_x,     p4_is_last_x;
    reg p1_is_abs_last,   p2_is_abs_last,   p3_is_abs_last,   p4_is_abs_last;

    reg p5_valid, p6_valid, p7_valid;
    reg p5_is_first_pool, p6_is_first_pool;
    reg p5_is_last_pool,  p6_is_last_pool,  p7_is_last_pool;
    reg p5_is_last_x,     p6_is_last_x,     p7_is_last_x;
    reg p5_is_abs_last,   p6_is_abs_last,   p7_is_abs_last;

    reg [15:0] p0_reg, p1_pix_reg, p2_pix_reg, p3_pix_reg;

    reg [15:0] m01_reg, m23_reg;

    reg [15:0] updated_win_max_reg;

    reg [127:0] word0_reg;
    reg [15:0]  win_max;
    reg [127:0] out_buf;
    reg [3:0]   out_cnt;
    reg [13:0]  out_addr;

    reg [127:0] next_out_buf;

    wire [13:0] in_words_per_row;
    wire [13:0] in_words_per_chan;
    wire [9:0]  cur_x_in;
    wire [9:0]  cur_y_in;

    reg [13:0] reg_in_words_per_row;
    reg [13:0] reg_in_words_per_chan;

    reg [13:0] base_offset_reg;
    reg [9:0]  cur_x_in_reg;

    wire [13:0] word0_addr;
    wire [13:0] word1_addr;

    wire [255:0] concat_row;
    wire [4:0]   pixel_offset;
    wire [255:0] shifted_row;
    wire [15:0]  pixel_p0, pixel_p1, pixel_p2, pixel_p3;

    wire [15:0] row_max_comb;
    wire [15:0] updated_win_max_comb;

    always @(posedge CLK) begin
        base_offset_reg <= (c * reg_in_words_per_chan) + (cur_y_in * reg_in_words_per_row);
        cur_x_in_reg    <= cur_x_in;
    end

    always @(posedge CLK) begin
        if (RESET) begin
            running          <= 0;
            agu_phase        <= AGU_PREP;
            p1_valid         <= 0;
            p2_valid         <= 0;
            p3_valid         <= 0;
            p4_valid         <= 0;
            p5_valid         <= 0;
            p6_valid         <= 0;
            p7_valid         <= 0;
            BRAM_enb         <= 0;
            BRAM_ena         <= 0;
            BRAM_wea         <= 0;
            EXT_END_OF_COMPUTE <= 0;
        end else if (EXT_START_OF_COMPUTE) begin
            running          <= 1;
            agu_phase        <= AGU_PREP;
            EXT_END_OF_COMPUTE <= 0;
            x_out <= 0; y_out <= 0; c <= 0; pool_y <= 0;
            
            out_addr         <= OUT_FMAP_BASEADDR;
            out_cnt          <= 0;
            out_buf          <= 0;

            reg_in_words_per_row  <= in_words_per_row;
            reg_in_words_per_chan <= in_words_per_chan;
            
            p1_valid         <= 0;
            p4_valid         <= 0;
            p5_valid         <= 0;
            p6_valid         <= 0;
            p7_valid         <= 0;
            BRAM_enb         <= 1;
        end else begin

            if (running) begin
                case (agu_phase)

                AGU_PREP: begin
                    p1_valid  <= 0;
                    agu_phase <= AGU_W0;
                end

                AGU_W0: begin
                    BRAM_addrb       <= word0_addr;
                    p1_x_in          <= cur_x_in;
                    p1_is_first_pool <= (pool_y == 0);
                    p1_is_last_pool  <= (pool_y == POOL_KERNEL_SIZE - 1);
                    p1_is_last_x     <= (x_out == OUT_FMAP_DIM_W - 1);
                    p1_is_abs_last   <= (x_out == OUT_FMAP_DIM_W - 1) && 
                                        (y_out == OUT_FMAP_DIM_H - 1) && 
                                        (c == IN_FMAP_DIM_C - 1) && 
                                        (pool_y == POOL_KERNEL_SIZE - 1);
                    p1_valid         <= 1;
                    agu_phase        <= AGU_W1;
                end

                AGU_W1: begin
                    BRAM_addrb       <= word1_addr;
                    p1_valid         <= 0; 
                    
                    if (pool_y == POOL_KERNEL_SIZE - 1) begin
                        pool_y <= 0;
                        if (x_out == OUT_FMAP_DIM_W - 1) begin
                            x_out <= 0;
                            if (y_out == OUT_FMAP_DIM_H - 1) begin
                                y_out <= 0;
                                if (c == IN_FMAP_DIM_C - 1) begin
                                    running <= 0; 
                                end else begin
                                    c <= c + 1;
                                end
                            end else begin
                                y_out <= y_out + 1;
                            end
                        end else begin
                            x_out <= x_out + 1;
                        end
                    end else begin
                        pool_y <= pool_y + 1;
                    end
                    
                    agu_phase <= AGU_PREP;
                end

                default: agu_phase <= AGU_PREP;
                endcase
            end else begin
                p1_valid <= 0;
            end
            
            if (!EXT_START_OF_COMPUTE) begin
                BRAM_enb <= running | p1_valid | p2_valid | p3_valid;
            end
            
            p2_valid         <= p1_valid;
            p2_x_in          <= p1_x_in;
            p2_is_first_pool <= p1_is_first_pool;
            p2_is_last_pool  <= p1_is_last_pool;
            p2_is_last_x     <= p1_is_last_x;
            p2_is_abs_last   <= p1_is_abs_last;
            
            p3_valid         <= p2_valid;
            p3_x_in          <= p2_x_in;
            p3_is_first_pool <= p2_is_first_pool;
            p3_is_last_pool  <= p2_is_last_pool;
            p3_is_last_x     <= p2_is_last_x;
            p3_is_abs_last   <= p2_is_abs_last;
            
            if (p3_valid) begin
                word0_reg <= BRAM_doutb;
            end
            
            p4_valid         <= p3_valid;
            p4_x_in          <= p3_x_in;
            p4_is_first_pool <= p3_is_first_pool;
            p4_is_last_pool  <= p3_is_last_pool;
            p4_is_last_x     <= p3_is_last_x;
            p4_is_abs_last   <= p3_is_abs_last;

            if (p4_valid) begin
                p0_reg     <= pixel_p0;
                p1_pix_reg <= pixel_p1;
                p2_pix_reg <= pixel_p2;
                p3_pix_reg <= pixel_p3;
            end

            p5_valid         <= p4_valid;
            p5_is_first_pool <= p4_is_first_pool;
            p5_is_last_pool  <= p4_is_last_pool;
            p5_is_last_x     <= p4_is_last_x;
            p5_is_abs_last   <= p4_is_abs_last;

            if (p5_valid) begin
                m01_reg <= (p0_reg > p1_pix_reg) ? p0_reg : p1_pix_reg;
                m23_reg <= (p2_pix_reg > p3_pix_reg) ? p2_pix_reg : p3_pix_reg;
            end

            p6_valid         <= p5_valid;
            p6_is_first_pool <= p5_is_first_pool;
            p6_is_last_pool  <= p5_is_last_pool;
            p6_is_last_x     <= p5_is_last_x;
            p6_is_abs_last   <= p5_is_abs_last;

            if (p6_valid) begin
                win_max             <= updated_win_max_comb;
                updated_win_max_reg <= updated_win_max_comb;
            end

            p7_valid        <= p6_valid;
            p7_is_last_pool <= p6_is_last_pool;
            p7_is_last_x    <= p6_is_last_x;
            p7_is_abs_last  <= p6_is_abs_last;
            
            if (p7_valid) begin
                
                if (p7_is_last_pool) begin
                    out_buf <= next_out_buf;
                    
                    if (out_cnt == 7 || p7_is_last_x) begin
                        BRAM_wea   <= 1;
                        BRAM_ena   <= 1;
                        BRAM_addra <= out_addr;
                        BRAM_dina  <= next_out_buf; 
                        
                        out_addr   <= out_addr + 1;
                        out_cnt    <= 0;
                    end else begin
                        BRAM_wea <= 0;
                        BRAM_ena <= 0;
                        out_cnt  <= out_cnt + 1;
                    end
                end else begin
                    BRAM_wea <= 0;
                    BRAM_ena <= 0;
                end
                
                if (p7_is_abs_last) begin
                    EXT_END_OF_COMPUTE <= 1;
                end
                
            end else begin
                BRAM_wea <= 0;
                BRAM_ena <= 0;
                if (EXT_END_OF_COMPUTE) EXT_END_OF_COMPUTE <= 0;
            end
        end
    end

    assign in_words_per_row = (IN_FMAP_DIM_W[2:0] == 0) ? (IN_FMAP_DIM_W >> 3) : ((IN_FMAP_DIM_W >> 3) + 1);
    assign in_words_per_chan = in_words_per_row * IN_FMAP_DIM_H;

    assign cur_x_in = x_out * POOL_KERNEL_SIZE;
    assign cur_y_in = y_out * POOL_KERNEL_SIZE + pool_y;

    assign word0_addr = IN_FMAP_BASEADDR + base_offset_reg + (cur_x_in_reg >> 3);
    assign word1_addr = word0_addr + 1;

    assign concat_row   = {BRAM_doutb, word0_reg}; 
    assign pixel_offset = p4_x_in[2:0];
    assign shifted_row  = concat_row >> (pixel_offset * 16);

    assign pixel_p0 = shifted_row[15:0];
    assign pixel_p1 = (POOL_KERNEL_SIZE > 1) ? shifted_row[31:16]  : 16'h0000;
    assign pixel_p2 = (POOL_KERNEL_SIZE > 2) ? shifted_row[47:32]  : 16'h0000;
    assign pixel_p3 = (POOL_KERNEL_SIZE > 3) ? shifted_row[63:48]  : 16'h0000;

    assign row_max_comb = (m01_reg > m23_reg) ? m01_reg : m23_reg;
    assign updated_win_max_comb = (p6_is_first_pool) ? row_max_comb 
                                : ((row_max_comb > win_max) ? row_max_comb : win_max);

    always @(*) begin
        next_out_buf = out_buf;
        if (out_cnt == 0) next_out_buf = 128'd0; 
        next_out_buf[out_cnt * 16 +: 16] = updated_win_max_reg;
    end

endmodule