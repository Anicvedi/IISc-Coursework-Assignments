// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// Lab Exercise 3: 5-Stage Pipelined RISC-V Processor with Instruction Cache
// Direct-Mapped Instruction Cache (16 lines x 4 words/block = 64 words)
// Word-by-word sequential fill from Block RAM on cache miss
// ==============================================================================

module icache (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc,
    output wire [31:0] instr,
    output wire        stall,
    output wire        miss_pulse,
    // Interface to Main Instruction Memory (Block RAM)
    output reg  [8:0]  bram_addr,
    input  wire [31:0] bram_rdata
);

    localparam NUM_LINES = 16;
    localparam IC_IDLE   = 1'b0;
    localparam IC_FILL   = 1'b1;

    reg        state;
    reg [31:0] miss_pc;
    reg [1:0]  fill_cnt;

    // Cache storage: 16 lines, 4 words per line
    reg        valid_arr [0:NUM_LINES-1];
    reg [23:0] tag_arr   [0:NUM_LINES-1];
    reg [31:0] data_arr  [0:NUM_LINES-1][0:3];

    // Address decomposition for current PC
    wire [1:0]  word_off = pc[3:2];
    wire [3:0]  index    = pc[7:4];
    wire [23:0] tag      = pc[31:8];

    // Address decomposition for missed PC
    wire [3:0]  miss_idx = miss_pc[7:4];
    wire [23:0] miss_tag = miss_pc[31:8];

    wire cache_hit = (state == IC_IDLE) && valid_arr[index] && (tag_arr[index] == tag);

    assign instr      = cache_hit ? data_arr[index][word_off] : 32'h00000013; // NOP on miss
    assign stall      = !cache_hit;
    assign miss_pulse = (state == IC_IDLE) && !cache_hit;

    // Next BRAM address:
    // In IC_IDLE on miss, request word 0 of the 4-word block.
    // In IC_FILL, request word (fill_cnt + 1) while latching word (fill_cnt).
    wire [1:0] next_word = fill_cnt + 2'd1;
    always @(*) begin
        if (state == IC_IDLE)
            bram_addr = {pc[10:4], 2'b00};
        else
            bram_addr = {miss_pc[10:4], next_word};
    end

    integer i, w;
    always @(posedge clk) begin
        if (rst) begin
            state    <= IC_IDLE;
            miss_pc  <= 32'd0;
            fill_cnt <= 2'd0;
            for (i = 0; i < NUM_LINES; i = i + 1) begin
                valid_arr[i] <= 1'b0;
                tag_arr[i]   <= 24'd0;
                for (w = 0; w < 4; w = w + 1)
                    data_arr[i][w] <= 32'h00000013;
            end
        end else begin
            case (state)
                IC_IDLE: begin
                    if (!cache_hit) begin
                        miss_pc  <= pc;
                        fill_cnt <= 2'd0;
                        state    <= IC_FILL;
                    end
                end

                IC_FILL: begin
                    data_arr[miss_idx][fill_cnt] <= bram_rdata;
                    if (fill_cnt == 2'd3) begin
                        valid_arr[miss_idx] <= 1'b1;
                        tag_arr[miss_idx]   <= miss_tag;
                        state               <= IC_IDLE;
                    end else begin
                        fill_cnt <= fill_cnt + 2'd1;
                    end
                end
            endcase
        end
    end

endmodule
