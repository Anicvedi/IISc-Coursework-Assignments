// =============================================================================
// Testbench      : AES256_tb
// DUT            : AES256
// Purpose        : Automatically apply all (plaintext, key) test vectors from
//                   ptxt_in.txt / key_in.txt to the AES-256 DUT, wait for the
//                   DUT to assert "ready", compare the resulting "ctxt" against
//                   the expected ciphertext in ctxt_out.txt, and report a final
//                   PASS/FAIL summary.
//
// File formats   : ptxt_in.txt  -> one 128-bit plaintext  per line, hex, no "0x"
//                  key_in.txt   -> one 256-bit key        per line, hex, no "0x"
//                  ctxt_out.txt -> one 128-bit ciphertext per line, hex, no "0x"
//                  Line N in each file corresponds to the same test case.
//
// DUT handshake:
//   1. reset is ACTIVE-LOW and SYNCHRONOUS.
//   2. ptxt / key are loaded into the DUT on the posedge of clock where
//      "write" is high. "write" is a single-cycle pulse, and ptxt/key are
//      held stable for that entire cycle (they are actually held stable
//      from the moment they are read from file until the next vector is
//      read, i.e., across write/start/wait/check).
//   3. "start" is a single-cycle pulse; the DUT begins encryption on the
//      posedge of clock where start is high.
//   4. "ready" is high for exactly ONE clock cycle when "ctxt" is valid.
//      The TB samples "ctxt" on that same cycle.
// =============================================================================

`timescale 1ns/1ps

module AES256_tb;

    // -------------------------------------------------------------------
    // DUT interface signals
    // -------------------------------------------------------------------
    reg          clock;
    reg          write;
    reg          reset;      // active-low, synchronous
    reg          start;
    wire         ready;
    reg  [127:0] ptxt_in;    // plaintext
    reg  [255:0] key_in;     // key
    wire [127:0] ctxt_out;   // ciphertext

    // -------------------------------------------------------------------
    // File handles / read-status variables
    // -------------------------------------------------------------------
    integer fd_in1, fd_in2, fd_out;
    integer st1, st2, st3;              // $fscanf return codes

    // -------------------------------------------------------------------
    // Used for summary 
    // -------------------------------------------------------------------
    reg  [127:0] expected_out;
    reg  [127:0] captured_out;
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
    reg [31:0] timeout_cnt;
    localparam TIMEOUT_LIMIT = 32'd100000; // max cycles to wait per vector

    // -------------------------------------------------------------------
    // Instantiate the DUT
    // -------------------------------------------------------------------
    AES256 u_DUT (
        .clock (clock),
        .write (write),
        .reset (reset),
        .start (start),
        .ready (ready),
        .ptxt  (ptxt_in),
        .key   (key_in),
        .ctxt  (ctxt_out)
    );

    // -------------------------------------------------------------------
    // Clock generation
    // -------------------------------------------------------------------
    initial clock = 1'b0;
    always #5 clock = ~clock;   // 10 ns period, 100 MHz
	
	// -------------------------------------------------------------------
    // VCD dump
    // -------------------------------------------------------------------

	initial begin
		$dumpfile("AES256_tb.vcd");
		$dumpvars(0, u_DUT);
	end

    // -------------------------------------------------------------------
    // File opening and error checking
    // -------------------------------------------------------------------
    initial begin
        fd_in1 = $fopen("ptxt_in.txt", "r");
        fd_in2 = $fopen("key_in.txt", "r");
        fd_out = $fopen("ctxt_out.txt", "r");

        if (fd_in1 == 0) begin
            $display("ERROR: Could not open ptxt_in.txt");
            $finish;
        end
        if (fd_in2 == 0) begin
            $display("ERROR: Could not open key_in.txt");
            $finish;
        end
        if (fd_out == 0) begin
            $display("ERROR: Could not open ctxt_out.txt");
            $finish;
        end

        $display("========================================================");
        $display(" Starting AES-256 automated verification");
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
            ptxt_in      <= {128{1'b0}};
            key_in       <= {256{1'b0}};
            total_count  <= 0;
            pass_count   <= 0;
            fail_count   <= 0;
            test_num     <= 0;
            timeout_cnt  <= 0;
            captured_out <= {128{1'b0}};
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

                    st1 = $fscanf(fd_in1, " %h", ptxt_in);
                    st2 = $fscanf(fd_in2, " %h", key_in);
                    st3 = $fscanf(fd_out, " %h", expected_out);

                    if (st1 != 1 || st2 != 1 || st3 != 1) begin
                        state <= S_SUMMARY;
                    end
                    else begin
                        test_num    <= test_num + 1;
                        total_count <= total_count + 1;
                        state       <= S_WRITE;
                    end
                end

                // -------------------------------------------------------
                // Pulse "write" for exactly one cycle. ptxt_in/key_in are
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
                // encryption.
                // -------------------------------------------------------
                S_START: begin
                    write       <= 1'b0;
                    start       <= 1'b1;
                    timeout_cnt <= 0;
                    state       <= S_WAIT_RDY;
                end

                // -------------------------------------------------------
                // Wait for "ready". Since "ready" is only high for one
                // cycle, capture "ctxt" on the very cycle it is seen.
                // -------------------------------------------------------
                S_WAIT_RDY: begin
                    write <= 1'b0;
                    start <= 1'b0;

                    if (ready) begin
                        captured_out <= ctxt_out;
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
                // Compare captured_out against the expected ciphertext.
                // -------------------------------------------------------
                S_CHECK: begin
                    if (captured_out === expected_out) begin
                        pass_count <= pass_count + 1;
                        $display("Test %0d: PASS | ptxt=%h key=%h ctxt=%h",
                                  test_num, ptxt_in, key_in, captured_out);
                    end
                    else begin
                        fail_count <= fail_count + 1;
                        $display("Test %0d: FAIL | ptxt=%h key=%h", test_num, ptxt_in, key_in);
                        $display("            Expected = %h", expected_out);
                        $display("            Got      = %h", captured_out);
                    end
                    state <= S_READ_VEC;
                end

                // -------------------------------------------------------
                // All vectors processed: print the final report once
                // and terminate the simulation.
                // -------------------------------------------------------
                S_SUMMARY: begin
                    $display("========================================================");
                    $display(" AES-256 Verification Summary");
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

