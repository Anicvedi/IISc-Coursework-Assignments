// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// Lab Exercise 3: 5-Stage Pipelined RISC-V Processor with Instruction Cache
// Digilent Basys 3 FPGA Board Top-Level Wrapper (XC7A35T-1CPG236C)
// ==============================================================================

module basys3_top #(
    parameter MEM_FILE = "restoring_div.mem"
)(
    input  wire        clk,     // 100 MHz System Clock (W5)
    input  wire        btnC,    // Center Push Button (Reset, U18)
    input  wire [1:0]  sw,      // Slide Switches: sw[0] = Quot/Rem, sw[1] = PC/Status
    output wire [15:0] led,     // 16 Discrete LEDs
    output wire [6:0]  seg,     // 7-Segment Cathodes (a..g)
    output wire        dp,      // 7-Segment Decimal Point
    output wire [3:0]  an       // 7-Segment Anodes
);

    wire [31:0] pc_out;
    wire [31:0] quot_out;
    wire [31:0] rem_out;
    wire        icache_stall_out;
    wire        load_use_stall_out;
    wire        ex_redirect_out;
    wire        fwd_active_out;

    rv32i_pipeline_cpu #(
        .MEM_FILE(MEM_FILE)
    ) u_cpu (
        .clk                (clk),
        .rst                (btnC),
        .pc_out             (pc_out),
        .quot_out           (quot_out),
        .rem_out            (rem_out),
        .icache_stall_out   (icache_stall_out),
        .load_use_stall_out (load_use_stall_out),
        .ex_redirect_out    (ex_redirect_out),
        .fwd_active_out     (fwd_active_out)
    );

    reg [15:0] disp_val;
    always @(*) begin
        case (sw)
            2'b00:   disp_val = quot_out[15:0];
            2'b01:   disp_val = rem_out[15:0];
            2'b10:   disp_val = pc_out[15:0];
            2'b11:   disp_val = {icache_stall_out, load_use_stall_out, ex_redirect_out, fwd_active_out, pc_out[11:0]};
            default: disp_val = quot_out[15:0];
        endcase
    end

    assign led = disp_val;

    seg7_driver u_seg7 (
        .clk   (clk),
        .rst   (btnC),
        .value (disp_val),
        .seg   (seg),
        .dp    (dp),
        .an    (an)
    );

endmodule
