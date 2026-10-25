`timescale 1ns / 1ps

(* use_dsp = "yes" *)
module pe_element (
    input  wire        CLK,
    input  wire signed [15:0] ACT_IN,
    input  wire signed [15:0] WGT_IN,
    input  wire        COMPUTE_EN,
    output reg  signed [31:0] PRODUCT
);
    always @(posedge CLK) begin
        if (COMPUTE_EN)
            PRODUCT <= ACT_IN * WGT_IN;
    end
endmodule

module ops_convrelu #(
    parameter MAX_FMAP_DIM     = 32, 
    parameter MAX_KERNEL_WIDTH = 14, 
    parameter MIN_KERNEL_WIDTH = 2,  
    parameter MAX_OUT_WIDTH    = 28  
)(
    input  wire        CLK_IN,
    input  wire        RESET,
    input  wire        MODULE_EN,

    input  wire        EXT_START_OF_COMPUTE,
    output reg         EXT_END_OF_COMPUTE,

    input  wire [13:0] IN_FMAP_BASEADDR,
    input  wire [9:0]  IN_FMAP_DIM_H,
    input  wire [9:0]  IN_FMAP_DIM_W,
    input  wire [9:0]  IN_FMAP_DIM_C,

    input  wire [13:0] WEIGHT_BASEADDR,
    input  wire [9:0]  WEIGHT_DIM_H,
    input  wire [9:0]  WEIGHT_DIM_W,
    input  wire [9:0]  WEIGHT_DIM_C,
    input  wire [3:0]  NUM_FILTERS,

    input  wire [13:0] OUT_FMAP_BASEADDR,
    input  wire [9:0]  OUT_FMAP_DIM_H,
    input  wire [9:0]  OUT_FMAP_DIM_W,
    input  wire [9:0]  OUT_FMAP_DIM_C,

    input  wire [7:0]  STRIDE,
    input  wire        RELU_EN,

    output reg         BRAM_act_ENA,
    output reg         BRAM_act_WEA,
    output reg  [13:0] BRAM_act_ADDRA,
    output reg  [127:0] BRAM_act_DINA,

    output reg         BRAM_act_ENB,
    output reg  [13:0] BRAM_act_ADDRB,
    input  wire [127:0] BRAM_act_DOUTB,
    
    output reg         BRAM_wgt_ENA,
    output wire        BRAM_wgt_WEA,      
    output reg  [13:0] BRAM_wgt_ADDRA,  
    output wire [15:0] BRAM_wgt_DINA,    
    input  wire [15:0] BRAM_wgt_DOUTA 
);

    wire CLK;
    assign CLK = CLK_IN;

    assign BRAM_wgt_WEA  = 1'b0;
    assign BRAM_wgt_DINA = 16'd0;

    localparam NUM_PE_ROWS = MAX_OUT_WIDTH * MAX_KERNEL_WIDTH;

    localparam BRAM_LATENCY = 2;

    localparam S_IDLE       = 4'd0,
               S_INIT_FILT  = 4'd1,
               S_LOAD       = 4'd2,
               S_COMPUTE    = 4'd3,
               S_PIPE_DRAIN = 4'd4,
               S_CHAN_INC   = 4'd5,
               S_WRITE_INIT = 4'd6,
               S_WRITE      = 4'd7,
               S_WRITE_FLUSH= 4'd8,
               S_FILT_INC   = 4'd9,
               S_DONE       = 4'd10;

    localparam AL_CLEAR   = 3'd0,
               AL_ADDR    = 3'd1,
               AL_WAIT    = 3'd2,
               AL_CAPTURE = 3'd3,
               AL_BCAST   = 3'd4,
               AL_DONE    = 3'd5;

    localparam WL_ADDR    = 3'd0,
               WL_WAIT    = 3'd1,
               WL_CAPTURE = 3'd2,
               WL_BCAST   = 3'd3,
               WL_DONE    = 3'd4;

    wire [13:0] words_per_act_row;
    assign words_per_act_row = (IN_FMAP_DIM_W[2:0] == 0)
                                ? {4'd0, IN_FMAP_DIM_W[9:3]}
                                : ({4'd0, IN_FMAP_DIM_W[9:3]} + 14'd1);

    wire [13:0] words_per_act_chan;
    assign words_per_act_chan = words_per_act_row * IN_FMAP_DIM_H;

    wire [13:0] words_per_out_row;
    assign words_per_out_row = (OUT_FMAP_DIM_W[2:0] == 0)
                                ? {4'd0, OUT_FMAP_DIM_W[9:3]}
                                : ({4'd0, OUT_FMAP_DIM_W[9:3]} + 14'd1);

    wire [13:0] words_per_out_chan;
    assign words_per_out_chan = words_per_out_row * OUT_FMAP_DIM_H;

    wire [13:0] wgts_per_chan;
    assign wgts_per_chan = WEIGHT_DIM_H * WEIGHT_DIM_W;

    wire [13:0] wgts_per_filt;
    assign wgts_per_filt = wgts_per_chan * WEIGHT_DIM_C;

    reg signed [15:0] wgt_spad  [0:NUM_PE_ROWS-1][0:MAX_KERNEL_WIDTH-1];
    reg signed [15:0] act_spad  [0:NUM_PE_ROWS-1][0:MAX_FMAP_DIM-1];

    reg signed [15:0] line_act_buf [0:MAX_FMAP_DIM-1];
    reg signed [15:0] line_wgt_buf [0:MAX_KERNEL_WIDTH-1];

    reg signed [31:0] psum [0:MAX_OUT_WIDTH-1][0:MAX_OUT_WIDTH-1];

    wire signed [31:0] pe_product [0:NUM_PE_ROWS-1][0:MAX_KERNEL_WIDTH-1];
    reg compute_en;

    genvar gr, gk;
    generate
        for (gr = 0; gr < NUM_PE_ROWS; gr = gr + 1) begin : gen_pe_rows
            for (gk = 0; gk < MAX_KERNEL_WIDTH; gk = gk + 1) begin : gen_pe_cols
                pe_element u_pe (
                    .CLK        (CLK),
                    .ACT_IN     (act_spad[gr][gk]),
                    .WGT_IN     (wgt_spad[gr][gk]),
                    .COMPUTE_EN (compute_en),
                    .PRODUCT    (pe_product[gr][gk])
                );
            end
        end
    endgenerate

    wire signed [31:0] row_psum [0:NUM_PE_ROWS-1];

    generate
        for (gr = 0; gr < NUM_PE_ROWS; gr = gr + 1) begin : gen_hsum
            reg signed [31:0] hsum_comb;
            integer hi;
            always @(*) begin
                hsum_comb = 32'sd0;
                for (hi = 0; hi < MAX_KERNEL_WIDTH; hi = hi + 1)
                    hsum_comb = hsum_comb + pe_product[gr][hi];
            end
            assign row_psum[gr] = hsum_comb;
        end
    endgenerate

    wire signed [31:0] col_out [0:MAX_OUT_WIDTH-1];

    generate
        for (gr = 0; gr < MAX_OUT_WIDTH; gr = gr + 1) begin : gen_vsum
            reg signed [31:0] vsum_comb;
            integer vi;
            always @(*) begin
                vsum_comb = 32'sd0;
                for (vi = 0; vi < MAX_KERNEL_WIDTH; vi = vi + 1)
                    vsum_comb = vsum_comb + row_psum[gr * MAX_KERNEL_WIDTH + vi];
            end
            assign col_out[gr] = vsum_comb;
        end
    endgenerate

    reg [3:0]  state;

    reg [3:0]  cur_filt;
    reg [9:0]  cur_chan;
    reg        first_chan;

    reg [2:0]  al_state;
    reg [3:0]  al_word;
    reg [1:0]  al_wait;
    reg [13:0] al_addr;

    reg [2:0]  wl_state;
    reg [9:0]  wl_kw;
    reg [1:0]  wl_wait;
    reg [13:0] wl_addr;

    reg [9:0]  shift_count;
    reg [9:0]  max_shift;
    reg        s0_valid;
    reg [7:0]  s0_stride_cnt;
    reg        s0_capture;

    reg        s1_valid;
    reg        s1_capture;
    reg [9:0]  s1_ow;

    reg        s2_valid;
    reg        s2_capture;
    reg [9:0]  s2_ow;
    reg signed [31:0] col_out_reg [0:MAX_OUT_WIDTH-1];

    reg [1:0]  drain_cnt;

    reg [9:0]  wr_oh;
    reg [9:0]  wr_ow;
    reg [3:0]  wr_pack_cnt;
    reg [127:0] wr_buf;
    reg [13:0] wr_addr;

    reg [13:0] reg_words_per_act_chan;
    reg [13:0] reg_wgts_per_chan;
    reg [13:0] reg_wgts_per_filt;
    reg [13:0] reg_words_per_out_chan;

    reg [13:0] al_chan_base;
    reg [13:0] wl_chan_base;
    reg [13:0] wl_filt_base;
    reg [13:0] wr_filt_base;

    wire signed [15:0] trunc_val;
    assign trunc_val = psum[wr_oh][wr_ow][25:10];

    wire [15:0] relu_val;
    assign relu_val = (RELU_EN && trunc_val[15]) ? 16'd0 : trunc_val;

    integer ri, ki, wi, oi, oj;

    always @(posedge CLK) begin
        if (RESET) begin
            state            <= S_IDLE;
            EXT_END_OF_COMPUTE <= 0;
            compute_en       <= 0;
            BRAM_act_ENA     <= 0;
            BRAM_act_WEA     <= 0;
            BRAM_act_ENB     <= 0;
            BRAM_wgt_ENA     <= 0;
            s0_valid         <= 0;
            s1_valid         <= 0;
            s2_valid         <= 0;
        end else begin

            BRAM_act_ENA <= 0;
            BRAM_act_WEA <= 0;
            BRAM_act_ENB <= 0;
            BRAM_wgt_ENA <= 0;

            case (state)

            S_IDLE: begin
                EXT_END_OF_COMPUTE <= 0;
                if (EXT_START_OF_COMPUTE) begin
                    cur_filt <= 0;
                    reg_words_per_act_chan <= words_per_act_chan;
                    reg_wgts_per_chan      <= wgts_per_chan;
                    reg_wgts_per_filt     <= wgts_per_filt;
                    reg_words_per_out_chan <= words_per_out_chan;
                    wl_filt_base <= WEIGHT_BASEADDR;
                    wr_filt_base <= OUT_FMAP_BASEADDR;
                    state    <= S_INIT_FILT;
                end
            end

            default: state <= S_IDLE;

            endcase
        end
    end

endmodule