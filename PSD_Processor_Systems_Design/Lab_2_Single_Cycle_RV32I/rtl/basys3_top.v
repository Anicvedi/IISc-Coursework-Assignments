// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// 32-bit Single Cycle RISC-V Processor (RV32I)
// Top-Level Module for Digilent Basys 3 FPGA Board
// Target Device: Xilinx Artix-7 XC7A35T-1CPG236C
// ==============================================================================

module basys3_top #(
    parameter MEM_INIT_FILE = "memory/restoring_div.mem"
)(
    input  wire        clk,       // 100 MHz board oscillator (Pin W5)
    input  wire        btnC,      // Push button Center: System Reset (Pin U18)
    input  wire [1:0]  sw,        // sw[0]: 0=Quotient, 1=Remainder; sw[1]: 0=10MHz, 1=1Hz
    output wire [15:0] led,       // 16 Discrete LEDs (Pins U16..L1)
    output wire [6:0]  seg,       // 7-segment cathodes (Pins W7..U7)
    output wire [3:0]  an,        // 7-segment anodes (Pins U2, U4, V4, W4)
    output wire        dp         // 7-segment decimal point (Pin V7)
);

    // --------------------------------------------------------------------------
    // 1. Reset Synchronizer (Active High)
    // --------------------------------------------------------------------------
    reg rst_sync1, rst_sync2;
    always @(posedge clk) begin
        rst_sync1 <= btnC;
        rst_sync2 <= rst_sync1;
    end
    wire rst = rst_sync2;

    // --------------------------------------------------------------------------
    // 2. Clock Generation for Single-Cycle CPU
    //    100 MHz -> 10 MHz (divide by 10) for normal execution
    //    100 MHz -> 1 Hz (divide by 100,000,000) for slow-step observation
    // --------------------------------------------------------------------------
    reg [3:0]  fast_cnt;
    reg        clk_10mhz;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fast_cnt  <= 4'd0;
            clk_10mhz <= 1'b0;
        end else if (fast_cnt == 4'd4) begin
            fast_cnt  <= 4'd0;
            clk_10mhz <= ~clk_10mhz;
        end else begin
            fast_cnt  <= fast_cnt + 1'b1;
        end
    end

    reg [25:0] slow_cnt;
    reg        clk_1hz;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            slow_cnt <= 26'd0;
            clk_1hz  <= 1'b0;
        end else if (slow_cnt == 26'd49_999_999) begin
            slow_cnt <= 26'd0;
            clk_1hz  <= ~clk_1hz;
        end else begin
            slow_cnt <= slow_cnt + 1'b1;
        end
    end

    // Selected CPU clock
    wire cpu_clk = (sw[1]) ? clk_1hz : clk_10mhz;

    // --------------------------------------------------------------------------
    // 3. 32-bit Single-Cycle RISC-V CPU Core
    // --------------------------------------------------------------------------
    wire [31:0] cpu_pc;
    wire [31:0] cpu_instr;
    wire [31:0] quotient_word;
    wire [31:0] remainder_word;
    wire [31:0] reg_x10;
    wire [31:0] reg_x11;

    rv32i_cpu #(
        .MEM_INIT_FILE (MEM_INIT_FILE)
    ) u_cpu (
        .clk       (cpu_clk),
        .rst       (rst),
        .pc        (cpu_pc),
        .instr     (cpu_instr),
        .quotient  (quotient_word),
        .remainder (remainder_word),
        .reg_x10   (reg_x10),
        .reg_x11   (reg_x11)
    );

    // --------------------------------------------------------------------------
    // 4. Peripheral Display Multiplexing
    //    sw[0] = 0 -> Display Quotient (Expected: 14 = 0x000E)
    //    sw[0] = 1 -> Display Remainder (Expected: 2 = 0x0002)
    // --------------------------------------------------------------------------
    wire [15:0] selected_display = (sw[0]) ? remainder_word[15:0] : quotient_word[15:0];

    // Discrete LEDs
    assign led = selected_display;

    // 4-Digit 7-Segment Display Driver (driven by 100 MHz clock for flicker-free display)
    seg7_driver u_seg7 (
        .clk   (clk),
        .rst   (rst),
        .value (selected_display),
        .seg   (seg),
        .an    (an),
        .dp    (dp)
    );

endmodule
