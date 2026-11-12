// =============================================================================
// Testbench      : modexp_tb
// DUT            : modexp
// Purpose        : Automatically apply all (inp, exp) test vectors from
//                   inp_2048.txt / exp_2048.txt to the modexp DUT, wait for the
//                   DUT to assert "ready", compare the resulting "modexp_out" against
//                   the expected modexp_out in modexp_out_2048.txt, and report a final
//                   PASS/FAIL summary.
//
// File formats   : inp_2048.txt        -> one 2048-bit inp per line, hex, no "0x"
//                  exp_2048.txt        -> one 2048-bit exp per line, hex, no "0x"
//                  modexp_out_2048.txt -> one 2048-bit modexp_out per line, hex, no "0x"
//                  Line N in each file corresponds to the same test case.
//
// DUT handshake:
//   1. reset is ACTIVE-LOW and SYNCHRONOUS.
//   2. inp / exp are loaded into the DUT on the posedge of clock where
//      "write" is high. "write" is a single-cycle pulse, and inp/exp are
//      held stable for that entire cycle (they are actually held stable
//      from the moment they are read from file until the next vector is
//      read, i.e., across write/start/wait/check).
//   3. "start" is a single-cycle pulse; the DUT begins exponentiation on the
//      posedge of clock where start is high.
//   4. "ready" is high for exactly ONE clock cycle when "modexp_out" is valid.
//      The TB samples "modexp_out" on that same cycle.
// =============================================================================

`timescale 1ns/1ps

module modexp_tb;

    // 2048-bit modular exponentiation
    parameter N = 2048;

    // -------------------------------------------------------------------
    // DUT interface signals
    // -------------------------------------------------------------------
    reg          clock;
    reg          write;
    reg          reset;        // active-low, synchronous
    reg          start;
    wire         ready;
    reg  [N-1:0] inp;          // input (base)
    reg  [N-1:0] exp;          // exponent
    wire [N-1:0] modexp_out;   // modexp_out

    // -------------------------------------------------------------------
    // File handles / read-status variables
    // -------------------------------------------------------------------
    integer fd_in1, fd_in2, fd_out;
    integer st1, st2, st3;              // $fscanf return codes

    // -------------------------------------------------------------------
    // Used for summary 
    // -------------------------------------------------------------------
    reg  [N-1:0] rd_inp, rd_exp;      // blocking-read staging regs 
    reg  [N-1:0] expected_out;
    reg  [N-1:0] captured_out;
    integer total_count;
    integer pass_count;
    integer fail_count;
    integer test_num;

    reg  [3:0] rst_cnt;
    localparam RESET_CYCLES = 4;   // hold reset (active-low) for this many edges

    // -------------------------------------------------------------------
    // FSM state encoding
    // -------------------------------------------------------------------
    localparam S_INIT      = 4'd0,  // idle right after reset deasserts
               S_READ_VEC  = 4'd1,  // read one line from each file
               S_WRITE     = 4'd2,  // pulse "write" for one cycle
               S_START     = 4'd3,  // pulse "start" for one cycle
               S_WAIT_RDY  = 4'd4,  // wait for "ready" (with timeout)
               S_TIMEOUT   = 4'd5,  // ready never arrived -> record FAIL
               S_CHECK     = 4'd6,  // compare captured_out vs expected_out
               S_SUMMARY   = 4'd7;  // print final report and $finish

    reg [3:0] state;

    // Timeout guard for S_WAIT_RDY
    // Scales with N^2 (a modexp built from an N-cycle modular multiplier needs
    // about 2*N*N cycles); allows 8*N*N, and never less than 1,000,000.
    reg [31:0] timeout_cnt;
    localparam [31:0] TIMEOUT_LIMIT = (8*N*N > 1000000) ? (8*N*N) : 1000000;

    // -------------------------------------------------------------------
    // Print an N-bit value in hex (same text as $write("%h", v)), 64 bits at a
    // time, so that very wide values also work in tools that limit the width
    // of a single $display argument.  (N must be a multiple of 64.)
    // -------------------------------------------------------------------
    task print_hex;
        input [N-1:0] v;
        integer k;
        begin
            for (k = N/64 - 1; k >= 0; k = k - 1)
                $write("%h", v[k*64 +: 64]);
        end
    endtask

    // -------------------------------------------------------------------
    // Instantiate the DUT
    // -------------------------------------------------------------------
    modexp #(.N(N)) u_DUT (
        .clock (clock),
        .write (write),
        .reset (reset),
        .start (start),
        .ready (ready),
        .inp   (inp),
        .exp   (exp),
        .modexp_out  (modexp_out)
    );

    // -------------------------------------------------------------------
    // Clock generation
    // -------------------------------------------------------------------
    initial clock = 1'b0;
    always #5 clock = ~clock;   // 10 ns period, 100 MHz
	
    // -------------------------------------------------------------------
    // File opening and error checking
    // -------------------------------------------------------------------
    initial begin
        fd_in1 = $fopen("inp_2048.txt", "r");
        fd_in2 = $fopen("exp_2048.txt", "r");
        fd_out = $fopen("modexp_out_2048.txt", "r");

        if (fd_in1 == 0) begin
            $display("ERROR: Could not open inp.txt");
            $finish;
        end
        if (fd_in2 == 0) begin
            $display("ERROR: Could not open exp.txt");
            $finish;
        end
        if (fd_out == 0) begin
            $display("ERROR: Could not open modexp_out.txt");
            $finish;
        end

        $display("========================================================");
        $display(" Starting modexp automated verification, N = %0d bits", N);
        $display("========================================================");
    end

    // -------------------------------------------------------------------
    // Active-low synchronous reset generator
    //   Holds reset = 0 (asserted) for RESET_CYCLES clock edges, then
    //   deasserts it (reset = 1) for the remainder of simulation.
    // -------------------------------------------------------------------
    initial begin
        reset   = 1'b0;   // assert reset at time 0
        rst_cnt = 4'd0;
    end

    always @(posedge clock) begin
        if (rst_cnt < RESET_CYCLES) begin
            reset   <= 1'b0;
            rst_cnt <= rst_cnt + 1'b1;
        end
        else begin
            reset <= 1'b1;
        end
    end

    // -------------------------------------------------------------------
    // Main FSM: drives write/start, reads vectors, checks
    // results, and produces the final summary.
    // -------------------------------------------------------------------
    always @(posedge clock) begin
        if (!reset) begin
            // Synchronous reset
            state        <= S_INIT;
            write        <= 1'b0;
            start        <= 1'b0;
            inp          <= {N{1'b0}};
            exp          <= {N{1'b0}};
            total_count  <= 0;
            pass_count   <= 0;
            fail_count   <= 0;
            test_num     <= 0;
            timeout_cnt  <= 0;
            captured_out <= {N{1'b0}};
        end
        else begin
            case (state)

                S_INIT: begin
                    write <= 1'b0;
                    start <= 1'b0;
                    state <= S_READ_VEC;
                end

                // -------------------------------------------------------
                // Read the next test vector. If any file has run out of
                // data, all vectors have been consumed -> go to summary.
                // -------------------------------------------------------
                S_READ_VEC: begin
                    write <= 1'b0;
                    start <= 1'b0;

                    st1 = $fscanf(fd_in1, " %h", rd_inp);
                    st2 = $fscanf(fd_in2, " %h", rd_exp);
                    st3 = $fscanf(fd_out, " %h", expected_out);

                    if (st1 != 1 || st2 != 1 || st3 != 1) begin
                        state <= S_SUMMARY;
                    end
                    else begin
                        inp         <= rd_inp;
                        exp         <= rd_exp;
                        test_num    <= test_num + 1;
                        total_count <= total_count + 1;
                        state       <= S_WRITE;
                    end
                end

                // -------------------------------------------------------
                // Pulse "write" for exactly one cycle. inp/exp are
                // already stable (set in S_READ_VEC and unchanged
                // since), so the DUT samples valid data on this edge.
                // -------------------------------------------------------
                S_WRITE: begin
                    write <= 1'b1;
                    start <= 1'b0;
                    state <= S_START;
                end

                // -------------------------------------------------------
                // Pulse "start" for exactly one cycle to start the
                // exponentation.
                // -------------------------------------------------------
                S_START: begin
                    write       <= 1'b0;
                    start       <= 1'b1;
                    timeout_cnt <= 0;
                    state       <= S_WAIT_RDY;
                end

                // -------------------------------------------------------
                // Wait for "ready". Since "ready" is only high for one
                // cycle, capture "modexp_out" on the very cycle it is seen.
                // -------------------------------------------------------
                S_WAIT_RDY: begin
                    write <= 1'b0;
                    start <= 1'b0;

                    if (ready) begin
                        captured_out <= modexp_out;
                        state        <= S_CHECK;
                    end
                    else if (timeout_cnt >= TIMEOUT_LIMIT) begin
                        state <= S_TIMEOUT;
                    end
                    else begin
                        timeout_cnt <= timeout_cnt + 1'b1;
                    end
                end

                // -------------------------------------------------------
                // "ready" never arrived within TIMEOUT_LIMIT cycles.
                // -------------------------------------------------------
                S_TIMEOUT: begin
                    fail_count <= fail_count + 1;
                    $display("Test %0d: FAIL (TIMEOUT - 'ready' never asserted)", test_num);
                    state <= S_READ_VEC;
                end

                // -------------------------------------------------------
                // Compare captured_out against the expected modexp_out.
                // -------------------------------------------------------
                S_CHECK: begin
                    if (captured_out === expected_out) begin
                        pass_count <= pass_count + 1;
                        $write("Test %0d: PASS | inp=", test_num);
                        print_hex(inp);
                        $write(" exp=");
                        print_hex(exp);
                        $write(" modexp_out=");
                        print_hex(captured_out);
                        $write("\n");
                    end
                    else begin
                        fail_count <= fail_count + 1;
                        $write("Test %0d: FAIL | inp=", test_num);
                        print_hex(inp);
                        $write(" exp=");
                        print_hex(exp);
                        $write("\n            Expected = ");
                        print_hex(expected_out);
                        $write("\n            Got      = ");
                        print_hex(captured_out);
                        $write("\n");
                    end
                    state <= S_READ_VEC;
                end

                // -------------------------------------------------------
                // All vectors processed: print the final report once
                // and terminate the simulation.
                // -------------------------------------------------------
                S_SUMMARY: begin
                    $display("========================================================");
                    $display(" modexp Verification Summary (N = %0d bits)", N);
                    $display("--------------------------------------------------------");
                    $display(" Total test cases   : %0d", total_count);
                    $display(" Passed             : %0d", pass_count);
                    $display(" Failed             : %0d", fail_count);
                    if (total_count > 0 && fail_count == 0)
                        $display(" Result             : ALL TESTS PASSED");
                    else
                        $display(" Result             : SOME TESTS FAILED");
                    $display("========================================================");

                    $fclose(fd_in1);
                    $fclose(fd_in2);
                    $fclose(fd_out);
                    $finish;
                end

                default: state <= S_INIT;
            endcase
        end
    end

endmodule
