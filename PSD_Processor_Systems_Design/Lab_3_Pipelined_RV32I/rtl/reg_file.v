// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// Lab Exercise 3: 5-Stage Pipelined RISC-V Processor with Instruction Cache
// Register File (32 x 32-bit, x0 = 0) with WB-to-ID Forwarding Bypass
// ==============================================================================

module reg_file (
    input  wire        clk,
    input  wire        rst,
    input  wire        we,
    input  wire [4:0]  raddr1,
    input  wire [4:0]  raddr2,
    input  wire [4:0]  waddr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata1,
    output reg  [31:0] rdata2
);

    reg [31:0] regs [1:31];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 1; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end else if (we && (waddr != 5'd0)) begin
            regs[waddr] <= wdata;
        end
    end

    // Combinational read with WB-stage write-through bypass
    always @(*) begin
        if (raddr1 == 5'd0)
            rdata1 = 32'd0;
        else if (we && (waddr == raddr1))
            rdata1 = wdata;
        else
            rdata1 = regs[raddr1];

        if (raddr2 == 5'd0)
            rdata2 = 32'd0;
        else if (we && (waddr == raddr2))
            rdata2 = wdata;
        else
            rdata2 = regs[raddr2];
    end

endmodule
