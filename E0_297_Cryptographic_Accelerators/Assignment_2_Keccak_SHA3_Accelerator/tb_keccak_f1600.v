// File formats   : in.txt  -> one 1600-bit input state  per line, hex,
//                              no "0x" (400 hex digits/line)
//                  out.txt -> one 1600-bit expected output state per line,
//                              hex, no "0x" (400 hex digits/line)
//                  Line N in each file corresponds to the same test case.
//
// DUT handshake:
//   1. reset is ACTIVE-LOW and SYNCHRONOUS.
//   2. Loading the input state: 25 words x 2 cycles/word (address-setup
//      cycle, then a write-pulse cycle) = 50 cycles total.
//   3. "start" is a single-cycle pulse given from the testbench; the DUT runs the 24-round
//      permutation internally.
//   4. "ready" is high for exactly ONE clock cycle when the result is
//      valid and addressable.


`timescale 1ns/1ps

module tb_keccak_f1600;

    reg          clock;
    reg          reset;         // active-low, synchronous
    reg  [4:0]   word_addr;
    reg  [63:0]  word_data_in;
    reg          write;
    reg          start;
    wire         ready;
    wire [63:0]  word_data_out;


    integer fd_in, fd_out;
    integer st1, st2;

    // Full 1600-bit vectors read from file / reassembled from words
    reg [1599:0] state_in;
    reg [1599:0] expected_out;
    reg [1599:0] captured_out;

    integer total_count;
    integer pass_count;
    integer fail_count;
    integer test_num;
    integer word_idx;          // 0..24 loop counter for write/read word loops

    reg [3:0] rst_cnt;
    localparam RESET_CYCLES = 4;   // hold reset (active-low) for this many edges

    // FSM state encoding
    localparam S_INIT      = 4'd0,   // idle right after reset deasserts
               S_READ_VEC  = 4'd1,   // read one line from each file
               S_WR_ADDR   = 4'd2,   // drive word_addr/word_data_in for word N
               S_WR_PULSE  = 4'd3,   // pulse "write" for word N
               S_START     = 4'd4,   // pulse "start" for one cycle
               S_WAIT_RDY  = 4'd5,   // wait for "ready" (with timeout)
               S_TIMEOUT   = 4'd6,   // ready never arrived -> record FAIL
               S_RD_ADDR   = 4'd7,   // drive word_addr for readback word N
               S_RD_SAMPLE = 4'd8,   // sample word_data_out for word N
               S_CHECK     = 4'd9,   // compare captured_out vs expected_out
               S_SUMMARY   = 4'd10;  // print final report and $finish

    reg [3:0] state;

    // Timeout guard for S_WAIT_RDY
    reg [31:0] timeout_cnt;
    localparam TIMEOUT_LIMIT = 32'd100000; // max cycles to wait per vector

    // Instantiate the DUT
    keccak_f1600 u_DUT (
        .clock         (clock),
        .reset         (reset), 
        .write         (write),
        .start         (start),
        .ready         (ready),
        .word_addr     (word_addr),
        .word_data_in  (word_data_in),
        .word_data_out (word_data_out)
    );

    // Clock generation
    initial clock = 1'b0;
    always #5 clock = ~clock;   // 10 ns period, 100 MHz

    // File opening and error checking
    initial begin
        fd_in  = $fopen("in.txt",  "r");
        fd_out = $fopen("out.txt", "r");

        if (fd_in == 0) begin
            $display("ERROR: Could not open in.txt");
            $finish;
        end
        if (fd_out == 0) begin
            $display("ERROR: Could not open out.txt");
            $finish;
        end

        $display("========================================================");
        $display(" Starting Keccak-f[1600] automated verification");
        $display("========================================================");
    end

    // Active-low synchronous reset generator
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

    // Main FSM: drives the word-addressed write/read handshake, reads
    // vectors, checks results, and produces the final summary.
    always @(posedge clock) begin
        if (!reset) begin
            state        <= S_INIT;
            word_addr    <= 5'd0;
            word_data_in <= 64'd0;
            write        <= 1'b0;
            start        <= 1'b0;
            total_count  <= 0;
            pass_count   <= 0;
            fail_count   <= 0;
            test_num     <= 0;
            timeout_cnt  <= 0;
            word_idx     <= 0;
            captured_out <= {1600{1'b0}};
        end
        else begin
            case (state)

                S_INIT: begin
                    write <= 1'b0;
                    start <= 1'b0;
                    state <= S_READ_VEC;
                end

                // Read the next test vector. If either file has run out
                // of data, all vectors have been consumed -> summary.
                S_READ_VEC: begin
                    write <= 1'b0;
                    start <= 1'b0;

                    st1 = $fscanf(fd_in,  " %h", state_in);
                    st2 = $fscanf(fd_out, " %h", expected_out);

                    if (st1 != 1 || st2 != 1) begin
                        state <= S_SUMMARY;
                    end
                    else begin
                        test_num    <= test_num + 1;
                        total_count <= total_count + 1;
                        word_idx    <= 0;
                        state       <= S_WR_ADDR;
                    end
                end

                // Write loop: 25 words x 2 cycles/word.
                //   S_WR_ADDR  : drive word_addr + word_data_in for word N
                //   S_WR_PULSE : pulse "write" to latch word N
                S_WR_ADDR: begin
                    write        <= 1'b0;
                    word_addr    <= word_idx[4:0];
                    word_data_in <= state_in[64*word_idx +: 64];
                    state        <= S_WR_PULSE;
                end

                S_WR_PULSE: begin
                    write <= 1'b1;
                    if (word_idx == 24) begin
                        state <= S_START;
                    end
                    else begin
                        word_idx <= word_idx + 1;
                        state    <= S_WR_ADDR;
                    end
                end

                // Pulse "start" for exactly one cycle.
                S_START: begin
                    write       <= 1'b0;
                    start       <= 1'b1;
                    timeout_cnt <= 0;
                    state       <= S_WAIT_RDY;
                end

                // Wait for "ready".
                S_WAIT_RDY: begin
                    start <= 1'b0;

                    if (ready) begin
                        word_idx <= 0;
                        state    <= S_RD_ADDR;
                    end
                    else if (timeout_cnt >= TIMEOUT_LIMIT) begin
                        state <= S_TIMEOUT;
                    end
                    else begin
                        timeout_cnt <= timeout_cnt + 1'b1;
                    end
                end

                // "ready" never arrived within TIMEOUT_LIMIT cycles.
                S_TIMEOUT: begin
                    fail_count <= fail_count + 1;
                    $display("Test %0d: FAIL (TIMEOUT - 'ready' never asserted)", test_num);
                    state <= S_READ_VEC;
                end

                // Read loop: 25 words x 2 cycles/word.
                //   S_RD_ADDR   : drive word_addr for word N
                //   S_RD_SAMPLE : sample word_data_out for word N
                //                 (word_data_out is combinational, so by
                //                 this cycle it has already settled to
                //                 state[word_addr] -- no race)
                S_RD_ADDR: begin
                    word_addr <= word_idx[4:0];
                    state     <= S_RD_SAMPLE;
                end

                S_RD_SAMPLE: begin
                    captured_out[64*word_idx +: 64] <= word_data_out;
                    if (word_idx == 24) begin
                        state <= S_CHECK;
                    end
                    else begin
                        word_idx <= word_idx + 1;
                        state    <= S_RD_ADDR;
                    end
                end

                // Compare the reassembled captured_out against expected.
                S_CHECK: begin
                    if (captured_out === expected_out) begin
                        pass_count <= pass_count + 1;
                        $display("Test %0d: PASS", test_num);
                    end
                    else begin
                        fail_count <= fail_count + 1;
                        $display("Test %0d: FAIL", test_num);
                        $display("            Expected = %h", expected_out);
                        $display("            Got      = %h", captured_out);
                    end
                    state <= S_READ_VEC;
                end

                // All vectors processed: print the final report and
                // terminate the simulation.
                S_SUMMARY: begin
                    $display("========================================================");
                    $display(" Keccak-f[1600] Verification Summary");
                    $display("========================================================");
                    $display(" Total test cases   : %0d", total_count);
                    $display(" Passed             : %0d", pass_count);
                    $display(" Failed             : %0d", fail_count);
                    if (total_count > 0 && fail_count == 0)
                        $display(" Result             : ALL TESTS PASSED");
                    else
                        $display(" Result             : SOME TESTS FAILED");
                    $display("========================================================");

                    $fclose(fd_in);
                    $fclose(fd_out);
                    $finish;
                end

                default: state <= S_INIT;
            endcase
        end
    end

endmodule
