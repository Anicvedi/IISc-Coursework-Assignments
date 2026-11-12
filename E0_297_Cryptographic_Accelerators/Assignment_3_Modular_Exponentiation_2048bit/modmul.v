// =============================================================================
// Module      : modmul
// Description : Parameterized Simple Interleaved Modular Multiplier
//               Computes res = (A * B) mod P in N clock cycles.
//               Assumes 0 <= B < P and P is an N-bit modulus.
// =============================================================================

module modmul #(
    parameter N = 2048
)(
    input  wire         clock,
    input  wire         reset,      // active-low, synchronous
    input  wire         start,      // 1-cycle pulse to begin multiplication
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    input  wire [N-1:0] P,
    output reg          done,       // 1-cycle pulse when res is valid
    output reg  [N-1:0] res
);

    // State encoding
    localparam S_IDLE = 1'b0,
               S_RUN  = 1'b1;

    reg state;
    reg [N-1:0] a_reg;
    reg [N-1:0] b_reg;
    reg [N+1:0] acc;                // N+2 bits to hold up to 2*P + P < 4*P
    reg [$clog2(N):0] bit_cnt;      // counts N iterations (0 to N-1)

    // Precompute 2*P in N+2 bits
    wire [N+1:0] P_ext  = {2'b00, P};
    wire [N+1:0] P2_ext = {1'b0, P, 1'b0};

    // Combinational next-step interleaved modular reduction:
    // acc_shifted = 2 * acc + (a_reg[N-1] ? b_reg : 0)
    wire [N+1:0] add_term    = a_reg[N-1] ? {2'b00, b_reg} : {(N+2){1'b0}};
    wire [N+1:0] acc_shifted = {acc[N:0], 1'b0} + add_term;

    reg  [N+1:0] acc_next;
    always @(*) begin
        if (acc_shifted >= P2_ext)
            acc_next = acc_shifted - P2_ext;
        else if (acc_shifted >= P_ext)
            acc_next = acc_shifted - P_ext;
        else
            acc_next = acc_shifted;
    end

    always @(posedge clock) begin
        if (!reset) begin
            state   <= S_IDLE;
            a_reg   <= {N{1'b0}};
            b_reg   <= {N{1'b0}};
            acc     <= {(N+2){1'b0}};
            bit_cnt <= {($clog2(N)+1){1'b0}};
            done    <= 1'b0;
            res     <= {N{1'b0}};
        end else begin
            done <= 1'b0;

            case (state)
                S_IDLE: begin
                    if (start) begin
                        a_reg   <= A;
                        b_reg   <= B;
                        acc     <= {(N+2){1'b0}};
                        bit_cnt <= N - 1;
                        state   <= S_RUN;
                    end
                end

                S_RUN: begin
                    a_reg <= {a_reg[N-2:0], 1'b0};
                    if (bit_cnt == 0) begin
                        res   <= acc_next[N-1:0];
                        done  <= 1'b1;
                        state <= S_IDLE;
                    end else begin
                        acc     <= acc_next;
                        bit_cnt <= bit_cnt - 1'b1;
                    end
                end
            endcase
        end
    end

endmodule
