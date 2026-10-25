`timescale 1ns / 1ps

module serial_to_bram #(
    parameter CLOCK_FREQ = 70_000_000  //100_000_000  // Default 100 MHz
)(
    input  wire CLK,
    input  wire RESET,
    input  wire UART_RX,
    input  wire CNN_BUSY, 
    input  wire [1:0] BAUD_SELECT,
    
    output reg  START_CNN,
    output wire IS_RECEIVING, 
    
    // Activation BRAM - Port A (write)
    output reg          BRAM_act_ENA,
    output reg          BRAM_act_WEA,
    output reg  [13:0]  BRAM_act_ADDRA,
    output reg  [127:0] BRAM_act_DINA
);

    // Baud rate selection mux
    // 2'b00: 2_000_000  (simulation)
    // 2'b01: 9_600      (board test)
    // 2'b10: 19_200     (board test)
    // 2'b11: 115_200    (board test)
    reg [15:0] clks_per_bit;
    always @(*) begin
        case (BAUD_SELECT)
            2'b00:   clks_per_bit = CLOCK_FREQ / 2_000_000;
            2'b01:   clks_per_bit = CLOCK_FREQ / 9_600;
            2'b10:   clks_per_bit = CLOCK_FREQ / 19_200;
            2'b11:   clks_per_bit = CLOCK_FREQ / 115_200;
        endcase
    end
    localparam [63:0] START_SEQ = 64'hAA_BB_CC_DD_EE_FF_11_22;
    localparam [63:0] END_SEQ   = 64'h22_11_FF_EE_DD_CC_BB_AA;

    localparam S_WAIT_START = 3'd0,
               S_READ_HEAD  = 3'd1,
               S_CALC_DIMS  = 3'd2,
               S_RECEIVE    = 3'd3,
               S_WAIT_END   = 3'd4,
               S_CALC_DIMS_1= 3'd5;

    reg [2:0]  state;
    reg [63:0] magic_shifter;
    
    assign IS_RECEIVING = (state == S_RECEIVE);
    
    reg [15:0] dim_h, dim_w, dim_c;
    reg [2:0]  header_cnt;
    
    reg [31:0] expected_bytes;
    reg [31:0] byte_counter; 
    reg [3:0]  word_byte_idx; 

    wire [13:0] words_per_row       = (dim_w[2:0] == 0) ? (dim_w >> 3) : ((dim_w >> 3) + 1);

    // Two-Stage Synchronizer
    reg rx_meta, rx_sync;
    always @(posedge CLK) begin
        if (RESET) begin
            rx_meta <= 1'b1; 
            rx_sync <= 1'b1;
        end else begin
            rx_meta <= UART_RX;
            rx_sync <= rx_meta;
        end
    end

    wire [7:0] rx_data;
    wire       rx_valid;

    uart_rx u_uart_rx ( 
        .clk(CLK),
        .reset(RESET),
        .rx(rx_sync),
        .clks_per_bit(clks_per_bit),
        .data(rx_data),
        .valid(rx_valid)
    );

    // synthesis translate_off
    /*always @(posedge CLK) begin
        if (rx_valid && !RESET) begin
            $display("[%0t ns] [UART RX] Received byte: 8'h%02X", $time, rx_data);
        end
    end*/
    // synthesis translate_on

    always @(posedge CLK) begin
        if (RESET) begin
            START_CNN      <= 0;
            BRAM_act_ENA   <= 0;
            BRAM_act_WEA   <= 0;
            BRAM_act_ADDRA <= 14'd0;
            BRAM_act_DINA  <= 128'd0;
            byte_counter   <= 0;
            word_byte_idx  <= 0;
            magic_shifter  <= 64'd0;
            header_cnt     <= 0;
            expected_bytes <= 0;
            state          <= S_WAIT_START;
        end else begin
            // ---------------------------------------------------------------
            // FIX: Post-write address increment.
            //
            // BRAM_act_ENA / WEA / ADDRA / DINA are registered outputs.
            // When we assert ENA=1 in cycle T, the BRAM samples those values
            // at the *next* rising edge (T+1).  If we also increment ADDRA in
            // the same non-blocking block (cycle T), the BRAM will see the
            // already-incremented address at T+1, writing every word one
            // address too high and overwriting the last two words at the same
            // slot.
            //
            // Solution: read BRAM_act_ENA *before* clearing it.  Its value
            // here is what was registered last cycle, i.e. the cycle in which
            // the BRAM actually performed its write.  Incrementing then gives
            // the correct address for the next word.
            // ---------------------------------------------------------------
            if (BRAM_act_ENA)
                BRAM_act_ADDRA <= BRAM_act_ADDRA + 1;

            // Default de-asserts (override below only when needed)
            BRAM_act_ENA <= 0;
            BRAM_act_WEA <= 0;
            START_CNN    <= 0;
            
            // Continually shift the magic-sequence detector
            if (rx_valid) begin
                magic_shifter <= {magic_shifter[55:0], rx_data};
            end
            
            case (state)
                // ----------------------------------------------------------
                S_WAIT_START: begin
                    if (rx_valid) begin
                        if (!CNN_BUSY && {magic_shifter[55:0], rx_data} == START_SEQ) begin
                            state      <= S_READ_HEAD;
                            header_cnt <= 0;
                        end
                    end
                end

                // ----------------------------------------------------------
                S_READ_HEAD: begin
                    if (rx_valid) begin
                        case (header_cnt)
                            3'd0: dim_h[7:0]  <= rx_data;
                            3'd1: dim_h[15:8] <= rx_data;
                            3'd2: dim_w[7:0]  <= rx_data;
                            3'd3: dim_w[15:8] <= rx_data;
                            3'd4: dim_c[7:0]  <= rx_data;
                            3'd5: begin 
                                  dim_c[15:8] <= rx_data;
                                  state       <= S_CALC_DIMS;
                            end
                        endcase
                        header_cnt <= header_cnt + 1;
                    end
                end
                
                // ----------------------------------------------------------
                // Pipelined dimension calculation:
                //   Cycle 1: words_per_channel = words_per_row * dim_h  (1 DSP)
                //   Cycle 2: total_bytes = words_per_channel * dim_c * 16  (1 DSP + shift)
                // ----------------------------------------------------------
                S_CALC_DIMS: begin
                    expected_bytes <= words_per_row * dim_h;  // words per channel
                    state          <= S_CALC_DIMS_1;
                end

                S_CALC_DIMS_1: begin
                    expected_bytes <= (expected_bytes * dim_c) << 4;  // total bytes
                    byte_counter   <= 0;
                    word_byte_idx  <= 0;
                    BRAM_act_ADDRA <= 14'd0;   // reset for new frame
                    state          <= S_RECEIVE;
                end

                // ----------------------------------------------------------
                S_RECEIVE: begin
                    if (rx_valid) begin
                        // Shift new byte into the LSB side of the 128-bit word.
                        BRAM_act_DINA <= {rx_data, BRAM_act_DINA[127:8]};
                        
                        if (word_byte_idx == 4'd15) begin
                            // 16-byte word complete: trigger BRAM write.
                            // ADDRA is NOT changed here; the post-write logic
                            // at the top of this block will increment it on
                            // the following cycle (when the BRAM has already
                            // latched the current address).
                            BRAM_act_ENA  <= 1;
                            BRAM_act_WEA  <= 1;
                            word_byte_idx <= 0;
                            
                            if (byte_counter == expected_bytes - 1) begin
                                // Last byte of last word - wait for end sequence.
                                state <= S_WAIT_END;
                            end else begin
                                byte_counter <= byte_counter + 1;
                                // ADDRA increment intentionally omitted here;
                                // handled by the post-write section above.
                            end
                        end else begin
                            word_byte_idx <= word_byte_idx + 1;
                            byte_counter  <= byte_counter + 1;
                        end
                    end
                end

                // ----------------------------------------------------------
                S_WAIT_END: begin
                    if (rx_valid) begin
                        if ({magic_shifter[55:0], rx_data} == END_SEQ) begin
                            START_CNN <= 1; 
                            state     <= S_WAIT_START;
                        end
                    end
                end

            endcase
        end
    end
endmodule

// ==========================================================================
module uart_rx (
    input  clk, reset, rx,
    input  [15:0] clks_per_bit,
    output reg [7:0] data,
    output reg valid
);
    reg [2:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_idx;
    
    always @(posedge clk) begin
        if (reset) begin state <= 0; valid <= 0; end 
        else begin
            valid <= 0;
            case(state)
                0: if (rx == 0) begin state <= 1; clk_count <= clks_per_bit/2; end
                1: if (clk_count == 0) begin state <= 2; clk_count <= clks_per_bit; bit_idx <= 0; end else clk_count <= clk_count - 1;
                2: if (clk_count == 0) begin data[bit_idx] <= rx; if (bit_idx == 7) state <= 3; else bit_idx <= bit_idx + 1; clk_count <= clks_per_bit; end else clk_count <= clk_count - 1;
                3: if (clk_count == 0) begin state <= 0; valid <= 1; end else clk_count <= clk_count - 1;
            endcase
        end
    end
endmodule