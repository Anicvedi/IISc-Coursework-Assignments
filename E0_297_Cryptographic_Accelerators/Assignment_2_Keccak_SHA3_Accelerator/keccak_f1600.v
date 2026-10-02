`timescale 1ns/1ps

module keccak_f1600 (
    input  wire        clock,
    input  wire        reset,           // active-low, synchronous
    input  wire        write,
    input  wire        start,
    output reg         ready,
    input  wire [4:0]  word_addr,       // 5-bit word address (0 to 24)
    input  wire [63:0] word_data_in,    // 64-bit input word 
    output reg  [63:0] word_data_out    // 64-bit output word
);

    // =========================================================================
    // FSM State Definitions
    // =========================================================================
    localparam [1:0] S_IDLE = 2'd0,
                     S_RUN  = 2'd1,
                     S_DONE = 2'd2;

    reg [1:0] state;
    reg [4:0] round_cnt; // 0 to 23

    // =========================================================================
    // 1600-bit Internal State Registers (25 words of 64 bits each)
    // Word i (0..24) corresponds to lane (x = i % 5, y = i / 5)
    // =========================================================================
    reg [63:0] state_reg [0:24];

    // =========================================================================
    // Asynchronous Read Output
    // =========================================================================
    always @(*) begin
        if (word_addr < 5'd25)
            word_data_out = state_reg[word_addr];
        else
            word_data_out = 64'd0;
    end

    // =========================================================================
    // 64-bit Left Circular Rotation Function
    // =========================================================================
    function [63:0] rot64;
        input [63:0] in;
        input [5:0]  shift;
        begin
            if (shift == 6'd0)
                rot64 = in;
            else
                rot64 = (in << shift) | (in >> (64 - shift));
        end
    endfunction

    // =========================================================================
    // Round Constants (RC) Function for 24 Rounds
    // =========================================================================
    function [63:0] get_rc;
        input [4:0] r;
        begin
            case (r)
                5'd0:  get_rc = 64'h0000000000000001;
                5'd1:  get_rc = 64'h0000000000008082;
                5'd2:  get_rc = 64'h800000000000808A;
                5'd3:  get_rc = 64'h8000000080008000;
                5'd4:  get_rc = 64'h000000000000808B;
                5'd5:  get_rc = 64'h0000000080000001;
                5'd6:  get_rc = 64'h8000000080008081;
                5'd7:  get_rc = 64'h8000000000008009;
                5'd8:  get_rc = 64'h000000000000008A;
                5'd9:  get_rc = 64'h0000000000000088;
                5'd10: get_rc = 64'h0000000080008009;
                5'd11: get_rc = 64'h000000008000000A;
                5'd12: get_rc = 64'h000000008000808B;
                5'd13: get_rc = 64'h800000000000008B;
                5'd14: get_rc = 64'h8000000000008089;
                5'd15: get_rc = 64'h8000000000008003;
                5'd16: get_rc = 64'h8000000000008002;
                5'd17: get_rc = 64'h8000000000000080;
                5'd18: get_rc = 64'h000000000000800A;
                5'd19: get_rc = 64'h800000008000000A;
                5'd20: get_rc = 64'h8000000080008081;
                5'd21: get_rc = 64'h8000000000008080;
                5'd22: get_rc = 64'h0000000080000001;
                5'd23: get_rc = 64'h8000000080008008;
                default: get_rc = 64'h0000000000000000;
            endcase
        end
    endfunction

    // =========================================================================
    // Step Mappings: 5x5 Lane 2D Array Representation
    // =========================================================================
    wire [63:0] A [0:4][0:4];
    genvar gx, gy;
    generate
        for (gy = 0; gy < 5; gy = gy + 1) begin : map_in_y
            for (gx = 0; gx < 5; gx = gx + 1) begin : map_in_x
                assign A[gx][gy] = state_reg[5*gy + gx];
            end
        end
    endgenerate

    // -------------------------------------------------------------------------
    // 1. Theta Step
    // -------------------------------------------------------------------------
    wire [63:0] C [0:4];
    wire [63:0] D [0:4];
    wire [63:0] A_theta [0:4][0:4];

    assign C[0] = A[0][0] ^ A[0][1] ^ A[0][2] ^ A[0][3] ^ A[0][4];
    assign C[1] = A[1][0] ^ A[1][1] ^ A[1][2] ^ A[1][3] ^ A[1][4];
    assign C[2] = A[2][0] ^ A[2][1] ^ A[2][2] ^ A[2][3] ^ A[2][4];
    assign C[3] = A[3][0] ^ A[3][1] ^ A[3][2] ^ A[3][3] ^ A[3][4];
    assign C[4] = A[4][0] ^ A[4][1] ^ A[4][2] ^ A[4][3] ^ A[4][4];

    assign D[0] = C[4] ^ {C[1][62:0], C[1][63]};
    assign D[1] = C[0] ^ {C[2][62:0], C[2][63]};
    assign D[2] = C[1] ^ {C[3][62:0], C[3][63]};
    assign D[3] = C[2] ^ {C[4][62:0], C[4][63]};
    assign D[4] = C[3] ^ {C[0][62:0], C[0][63]};

    generate
        for (gx = 0; gx < 5; gx = gx + 1) begin : gen_theta_x
            for (gy = 0; gy < 5; gy = gy + 1) begin : gen_theta_y
                assign A_theta[gx][gy] = A[gx][gy] ^ D[gx];
            end
        end
    endgenerate

    // -------------------------------------------------------------------------
    // 2. Rho and Pi Steps (Combined Bit-level / Lane Permutation)
    // -------------------------------------------------------------------------
    wire [63:0] B [0:4][0:4];

    // Lane (x, y) maps to B[y][(2x + 3y) % 5] with rotation RHO[x][y]
    // x = 0
    assign B[0][0] = rot64(A_theta[0][0], 6'd0);
    assign B[1][3] = rot64(A_theta[0][1], 6'd36);
    assign B[2][1] = rot64(A_theta[0][2], 6'd3);
    assign B[3][4] = rot64(A_theta[0][3], 6'd41);
    assign B[4][2] = rot64(A_theta[0][4], 6'd18);

    // x = 1
    assign B[0][2] = rot64(A_theta[1][0], 6'd1);
    assign B[1][0] = rot64(A_theta[1][1], 6'd44);
    assign B[2][3] = rot64(A_theta[1][2], 6'd10);
    assign B[3][1] = rot64(A_theta[1][3], 6'd45);
    assign B[4][4] = rot64(A_theta[1][4], 6'd2);

    // x = 2
    assign B[0][4] = rot64(A_theta[2][0], 6'd62);
    assign B[1][2] = rot64(A_theta[2][1], 6'd6);
    assign B[2][0] = rot64(A_theta[2][2], 6'd43);
    assign B[3][3] = rot64(A_theta[2][3], 6'd15);
    assign B[4][1] = rot64(A_theta[2][4], 6'd61);

    // x = 3
    assign B[0][1] = rot64(A_theta[3][0], 6'd28);
    assign B[1][4] = rot64(A_theta[3][1], 6'd55);
    assign B[2][2] = rot64(A_theta[3][2], 6'd25);
    assign B[3][0] = rot64(A_theta[3][3], 6'd21);
    assign B[4][3] = rot64(A_theta[3][4], 6'd56);

    // x = 4
    assign B[0][3] = rot64(A_theta[4][0], 6'd27);
    assign B[1][1] = rot64(A_theta[4][1], 6'd20);
    assign B[2][4] = rot64(A_theta[4][2], 6'd39);
    assign B[3][2] = rot64(A_theta[4][3], 6'd8);
    assign B[4][0] = rot64(A_theta[4][4], 6'd14);

    // -------------------------------------------------------------------------
    // 3. Chi Step (Non-linear Layer)
    // -------------------------------------------------------------------------
    wire [63:0] A_chi [0:4][0:4];
    generate
        for (gx = 0; gx < 5; gx = gx + 1) begin : gen_chi_x
            for (gy = 0; gy < 5; gy = gy + 1) begin : gen_chi_y
                assign A_chi[gx][gy] = B[gx][gy] ^ ((~B[(gx + 1) % 5][gy]) & B[(gx + 2) % 5][gy]);
            end
        end
    endgenerate

    // -------------------------------------------------------------------------
    // 4. Iota Step (Add Round Constant to Lane (0, 0))
    // -------------------------------------------------------------------------
    wire [63:0] rc = get_rc(round_cnt);
    wire [63:0] next_lane [0:4][0:4];

    generate
        for (gx = 0; gx < 5; gx = gx + 1) begin : gen_iota_x
            for (gy = 0; gy < 5; gy = gy + 1) begin : gen_iota_y
                if (gx == 0 && gy == 0) begin : gen_iota_00
                    assign next_lane[0][0] = A_chi[0][0] ^ rc;
                end else begin : gen_iota_other
                    assign next_lane[gx][gy] = A_chi[gx][gy];
                end
            end
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Map 5x5 Next Lanes back to 25 Next State Words
    // -------------------------------------------------------------------------
    wire [63:0] next_state [0:24];
    generate
        for (gy = 0; gy < 5; gy = gy + 1) begin : map_out_y
            for (gx = 0; gx < 5; gx = gx + 1) begin : map_out_x
                assign next_state[5*gy + gx] = next_lane[gx][gy];
            end
        end
    endgenerate

    // =========================================================================
    // Synchronous Sequential Logic: State Registers
    // Each word has dedicated enable and load path for maximum synthesizability
    // =========================================================================
    genvar w;
    generate
        for (w = 0; w < 25; w = w + 1) begin : gen_state_reg
            always @(posedge clock) begin
                if (!reset) begin
                    state_reg[w] <= 64'd0;
                end else begin
                    if (state == S_RUN) begin
                        state_reg[w] <= next_state[w];
                    end else if (state == S_IDLE && write && (word_addr == w[4:0])) begin
                        state_reg[w] <= word_data_in;
                    end
                end
            end
        end
    endgenerate

    // =========================================================================
    // Synchronous Sequential Logic: FSM & Control
    // =========================================================================
    always @(posedge clock) begin
        if (!reset) begin
            state     <= S_IDLE;
            round_cnt <= 5'd0;
            ready     <= 1'b0;
        end else begin
            case (state)
                S_IDLE: begin
                    ready <= 1'b0;
                    if (start) begin
                        round_cnt <= 5'd0;
                        state     <= S_RUN;
                    end
                end

                S_RUN: begin
                    ready <= 1'b0;
                    if (round_cnt == 5'd23) begin
                        state <= S_DONE;
                    end else begin
                        round_cnt <= round_cnt + 5'd1;
                    end
                end

                S_DONE: begin
                    ready <= 1'b1;
                    state <= S_IDLE;
                end

                default: begin
                    state <= S_IDLE;
                    ready <= 1'b0;
                end
            endcase
        end
    end

endmodule
