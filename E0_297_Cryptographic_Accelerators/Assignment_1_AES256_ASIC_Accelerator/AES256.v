// =============================================================================
// Course: E0 297: Cryptographic Hardware Accelerators, IISc Bangalore
// Assignment: Design Assignment 1 - Iterative AES-256 Encryption Core
// Student: Anirudh Chaturvedi (SR No. 25850, M.Tech VLSI, Dept. of ECE)
// Reference: E0 297 Lectures 5 & 6 (Prof. Utsav Banerjee, IISc)
//            NIST FIPS 197 Standard
// =============================================================================
// Architectural Architecture: Iterative (Round-Based) AES-256
// - 14 rounds + initial key addition (Round 0)
// - Computes 1 full AES round per clock cycle across 128-bit state
// - 20 S-Box instances: 16 for SubBytes state transform + 4 for KeyExpansion
// - On-the-fly rolling key schedule with 256-bit key register
// - Parameterized S-Box selection:
//     SBOX_TYPE = 0 : Look-Up Table (AES_SBox_LUT)
//     SBOX_TYPE = 1 : Canright Composite-Field GF(((2^2)^2)^2) (AES_SBox_Canright)
// =============================================================================

module AES256 (
    input  wire         clock,
    input  wire         write,
    input  wire         reset,   // active-low, synchronous
    input  wire         start,
    output reg          ready,
    input  wire [127:0] ptxt,    // 128-bit plaintext
    input  wire [255:0] key,     // 256-bit key
    output reg  [127:0] ctxt     // 128-bit ciphertext
);

    parameter SBOX_TYPE = 0; // 0 for LUT, 1 for Canright

    // FSM States (IDLE -> RUN [Rounds 1..14] -> DONE)
    localparam IDLE = 2'd0, RUN = 2'd1, DONE = 2'd2;
    reg [1:0] state;
    reg [3:0] round_cnt;
    
    // Datapath registers
    reg [127:0] state_reg;
    reg [255:0] key_reg;
    
    // -------------------------------------------------------------------------
    // 1. SubBytes Transformation 
    // Non-linear byte substitution: 16 parallel S-Box instances across 4x4 state
    // -------------------------------------------------------------------------
    wire [127:0] state_subbytes;
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : subbytes_gen
            SBoxWrapper #(
                .SBOX_TYPE(SBOX_TYPE)
            ) sbox_state (
                .in(state_reg[i*8 +: 8]),
                .out(state_subbytes[i*8 +: 8])
            );
        end
    endgenerate

    // -------------------------------------------------------------------------
    // 2. ShiftRows Transformation 
    // -------------------------------------------------------------------------
    wire [127:0] state_shiftrows;
    assign state_shiftrows[127:96] = {state_subbytes[127:120], state_subbytes[87:80], state_subbytes[47:40], state_subbytes[7:0]};
    assign state_shiftrows[95:64]  = {state_subbytes[95:88],   state_subbytes[55:48], state_subbytes[15:8],  state_subbytes[103:96]};
    assign state_shiftrows[63:32]  = {state_subbytes[63:56],   state_subbytes[23:16], state_subbytes[111:104], state_subbytes[71:64]};
    assign state_shiftrows[31:0]   = {state_subbytes[31:24],   state_subbytes[119:112], state_subbytes[79:72], state_subbytes[39:32]};

    // -------------------------------------------------------------------------
    // 3. MixColumns Transformation (Lecture 5, Slides 10-14)
    // Polynomial multiplication in GF(2^8) modulo m(x) = x^8 + x^4 + x^3 + x + 1
    // -------------------------------------------------------------------------
    function [7:0] xtime;
        input [7:0] b;
        begin
            xtime = (b[7]) ? ((b << 1) ^ 8'h1b) : (b << 1);
        end
    endfunction

    function [31:0] mix_col;
        input [31:0] col;
        reg [7:0] a0, a1, a2, a3;
        reg [7:0] r0, r1, r2, r3;
        begin
            a0 = col[31:24];
            a1 = col[23:16];
            a2 = col[15:8];
            a3 = col[7:0];
            r0 = xtime(a0) ^ xtime(a1) ^ a1 ^ a2 ^ a3;
            r1 = a0 ^ xtime(a1) ^ xtime(a2) ^ a2 ^ a3;
            r2 = a0 ^ a1 ^ xtime(a2) ^ xtime(a3) ^ a3;
            r3 = xtime(a0) ^ a0 ^ a1 ^ a2 ^ xtime(a3);
            mix_col = {r0, r1, r2, r3};
        end
    endfunction

    wire [127:0] state_mixcols;
    assign state_mixcols[127:96] = mix_col(state_shiftrows[127:96]);
    assign state_mixcols[95:64]  = mix_col(state_shiftrows[95:64]);
    assign state_mixcols[63:32]  = mix_col(state_shiftrows[63:32]);
    assign state_mixcols[31:0]   = mix_col(state_shiftrows[31:0]);

    // -------------------------------------------------------------------------
    // 4. AddRoundKey Transformation 
    // Bitwise XOR between state and 128-bit round key.
    // -------------------------------------------------------------------------
    wire [127:0] round_data = (round_cnt == 14) ? state_shiftrows : state_mixcols;
    wire [127:0] state_addroundkey = round_data ^ key_reg[127:0];

    // -------------------------------------------------------------------------
    // 5. Key Expansion for AES-256 
    // RotWord, SubWord, Rcon on odd rounds; SubWord only on even rounds
    // -------------------------------------------------------------------------
    reg [7:0] rcon;
    always @(*) begin
        case (round_cnt)
            4'd1:  rcon = 8'h01;
            4'd3:  rcon = 8'h02;
            4'd5:  rcon = 8'h04;
            4'd7:  rcon = 8'h08;
            4'd9:  rcon = 8'h10;
            4'd11: rcon = 8'h20;
            4'd13: rcon = 8'h40;
            default: rcon = 8'h00;
        endcase
    end

    wire [31:0] prev_word = key_reg[31:0];
    wire [31:0] temp_in;
    // RotWord for odd rounds; direct word for even rounds
    assign temp_in = (round_cnt[0] == 1'b1) ? {prev_word[23:0], prev_word[31:24]} : prev_word;

    // SubWord: 4 parallel S-Box instances
    wire [31:0] temp_out;
    SBoxWrapper #(.SBOX_TYPE(SBOX_TYPE)) sbox_k0 (.in(temp_in[31:24]), .out(temp_out[31:24]));
    SBoxWrapper #(.SBOX_TYPE(SBOX_TYPE)) sbox_k1 (.in(temp_in[23:16]), .out(temp_out[23:16]));
    SBoxWrapper #(.SBOX_TYPE(SBOX_TYPE)) sbox_k2 (.in(temp_in[15:8]),  .out(temp_out[15:8]));
    SBoxWrapper #(.SBOX_TYPE(SBOX_TYPE)) sbox_k3 (.in(temp_in[7:0]),   .out(temp_out[7:0]));

    wire [31:0] w0_next, w1_next, w2_next, w3_next;
    assign w0_next = key_reg[255:224] ^ temp_out ^ {rcon, 24'h0};
    assign w1_next = key_reg[223:192] ^ w0_next;
    assign w2_next = key_reg[191:160] ^ w1_next;
    assign w3_next = key_reg[159:128] ^ w2_next;

    wire [127:0] next_round_key = {w0_next, w1_next, w2_next, w3_next};

    // -------------------------------------------------------------------------
    // 6. FSM Controller & Sequential Register Updates
    // -------------------------------------------------------------------------
    always @(posedge clock) begin
        if (!reset) begin
            state <= IDLE;
            round_cnt <= 0;
            ready <= 0;
            ctxt <= 0;
            state_reg <= 0;
            key_reg <= 0;
        end else begin
            ready <= 0;
            
            case (state)
                IDLE: begin
                    if (start) begin
                        // Round 0: Initial AddRoundKey (ptxt ^ key[255:128])
                        state_reg <= (write ? ptxt : state_reg) ^ (write ? key[255:128] : key_reg[255:128]);
                        if (write) key_reg <= key;
                        round_cnt <= 1;
                        state <= RUN;
                    end else if (write) begin
                        state_reg <= ptxt;
                        key_reg <= key;
                    end
                end
                
                RUN: begin
                    state_reg <= state_addroundkey;
                    key_reg <= {key_reg[127:0], next_round_key};
                    
                    if (round_cnt == 14) begin
                        state <= DONE;
                    end else begin
                        round_cnt <= round_cnt + 1;
                    end
                end
                
                DONE: begin
                    ready <= 1;
                    ctxt <= state_reg;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule

// =============================================================================
// S-Box Wrapper Module (Elaboration-time parameter selection)
// - SBOX_TYPE = 0 : 256-entry Look-Up Table (AES_SBox_LUT)
// - SBOX_TYPE = 1 : Composite-Field Tower GF(((2^2)^2)^2) (AES_SBox_Canright)
// =============================================================================
module SBoxWrapper (
    input  [7:0] in,
    output [7:0] out
);
    parameter SBOX_TYPE = 0; // 0: LUT, 1: Canright

    generate
        if (SBOX_TYPE == 0) begin : lut_sbox
            AES_SBox_LUT sbox_inst (.in(in), .out(out));
        end else begin : canright_sbox
            AES_SBox_Canright sbox_inst (.in(in), .out(out));
        end
    endgenerate

endmodule