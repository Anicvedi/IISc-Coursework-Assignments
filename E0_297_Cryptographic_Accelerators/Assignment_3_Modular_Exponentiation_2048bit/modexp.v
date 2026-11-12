module modexp #(
    parameter N = 2048                  // 2048 (the testbench can override it)
)(
    input  wire         clock,
    input  wire         write,
    input  wire         reset,         // active-low, synchronous
    input  wire         start,
    output reg          ready,
    input  wire [N-1:0] inp,           // N-bit input (base)
    input  wire [N-1:0] exp,           // N-bit exponent
    output reg  [N-1:0] modexp_out     // N-bit modexp_out = inp^exp mod P
);

    // ------------------------------------------------------------------
    // Fixed modulus P 
    //   N = 2048  : RSA-2048 (RSA Factoring Challenge number, 617 decimal digits).
    // ------------------------------------------------------------------
    localparam [N-1:0] P = 
            {
            64'hc7970ceedcc3b075, 64'h4490201a7aa613cd, 64'h73911081c790f5f1, 64'ha8726f463550bb5b,
            64'h7ff0db8e1ea1189e, 64'hc72f93d1650011bd, 64'h721aeeacc2acde32, 64'ha04107f0648c2813,
            64'ha31f5b0b7765ff8b, 64'h44b4b6ffc93384b6, 64'h46eb09c7cf5e8592, 64'hd40ea33c80039f35,
            64'hb4f14a04b51f7bfd, 64'h781be4d1673164ba, 64'h8eb991c2c4d730bb, 64'hbe35f592bdef524a,
            64'hf7e8daefd26c66fc, 64'h02c479af89d64d37, 64'h3f442709439de66c, 64'heb955f3ea37d5159,
            64'hf6135809f85334b5, 64'hcb1813addc80cd05, 64'h609f10ac6a95ad65, 64'h872c909525bdad32,
            64'hbc729592642920f2, 64'h4c61dc5b3c3b7923, 64'he56b16a4d9d373d8, 64'h721f24a3fc0f1b31,
            64'h31f55615172866bc, 64'hcc30f95054c824e7, 64'h33a5eb6817f7bc16, 64'h399d48c6361cc7e5};

    // ------------------------------------------------------------------
    // Internal Registers & FSM States
    // ------------------------------------------------------------------
    localparam [2:0] S_IDLE     = 3'd0,
                     S_SQ_START = 3'd1,
                     S_SQ_WAIT  = 3'd2,
                     S_MUL_WAIT = 3'd3,
                     S_DONE     = 3'd4;

    reg [2:0] state;
    reg [N-1:0] inp_reg;
    reg [N-1:0] exp_reg;
    reg [N-1:0] base;
    reg [N-1:0] res;
    reg [N-1:0] exp_shift;
    reg [$clog2(N):0] exp_cnt;

    // Interleaved Modular Multiplier interface
    reg          mul_start;
    reg  [N-1:0] mul_A;
    reg  [N-1:0] mul_B;
    wire         mul_done;
    wire [N-1:0] mul_res;

    modmul #(.N(N)) u_modmul (
        .clock (clock),
        .reset (reset),
        .start (mul_start),
        .A     (mul_A),
        .B     (mul_B),
        .P     (P),
        .done  (mul_done),
        .res   (mul_res)
    );

    always @(posedge clock) begin
        if (!reset) begin
            state      <= S_IDLE;
            ready      <= 1'b0;
            modexp_out <= {N{1'b0}};
            inp_reg    <= {N{1'b0}};
            exp_reg    <= {N{1'b0}};
            base       <= {N{1'b0}};
            res        <= {N{1'b0}};
            exp_shift  <= {N{1'b0}};
            exp_cnt    <= {($clog2(N)+1){1'b0}};
            mul_start  <= 1'b0;
            mul_A      <= {N{1'b0}};
            mul_B      <= {N{1'b0}};
        end else begin
            ready     <= 1'b0;
            mul_start <= 1'b0;

            // Latch inputs whenever write pulse is asserted
            if (write) begin
                inp_reg <= inp;
                exp_reg <= exp;
            end

            case (state)
                S_IDLE: begin
                    if (start) begin
                        res       <= {{(N-1){1'b0}}, 1'b1};
                        base      <= (inp_reg >= P) ? (inp_reg - P) : inp_reg;
                        exp_shift <= exp_reg;
                        exp_cnt   <= N - 1;
                        state     <= S_SQ_START;
                    end
                end

                S_SQ_START: begin
                    mul_A     <= res;
                    mul_B     <= res;
                    mul_start <= 1'b1;
                    state     <= S_SQ_WAIT;
                end

                S_SQ_WAIT: begin
                    if (mul_done) begin
                        res <= mul_res;
                        if (exp_shift[N-1]) begin
                            mul_A     <= mul_res;
                            mul_B     <= base;
                            mul_start <= 1'b1;
                            state     <= S_MUL_WAIT;
                        end else if (exp_cnt == 0) begin
                            modexp_out <= mul_res;
                            ready      <= 1'b1;
                            state      <= S_DONE;
                        end else begin
                            exp_shift <= {exp_shift[N-2:0], 1'b0};
                            exp_cnt   <= exp_cnt - 1'b1;
                            state     <= S_SQ_START;
                        end
                    end
                end

                S_MUL_WAIT: begin
                    if (mul_done) begin
                        res <= mul_res;
                        if (exp_cnt == 0) begin
                            modexp_out <= mul_res;
                            ready      <= 1'b1;
                            state      <= S_DONE;
                        end else begin
                            exp_shift <= {exp_shift[N-2:0], 1'b0};
                            exp_cnt   <= exp_cnt - 1'b1;
                            state     <= S_SQ_START;
                        end
                    end
                end

                S_DONE: begin
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
