// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// 32-bit Single Cycle RISC-V Processor (RV32I)
// Register File: 32 x 32-bit Registers (x0 hardwired to zero)
// Dual Asynchronous Read Ports, Single Synchronous Write Port
// ==============================================================================

module reg_file (
    input  wire        clk,
    input  wire        rst,
    input  wire [4:0]  raddr1,
    input  wire [4:0]  raddr2,
    input  wire [4:0]  waddr,
    input  wire [31:0] wdata,
    input  wire        we,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2,
    // Debug ports
    output wire [31:0] x10, // a0
    output wire [31:0] x11  // a1
);

    reg [31:0] regs [0:31];
    integer i;

    // Asynchronous reads (x0 is always 0)
    assign rdata1 = (raddr1 == 5'd0) ? 32'd0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'd0) ? 32'd0 : regs[raddr2];

    // Debug probes for a0 and a1
    assign x10 = regs[10];
    assign x11 = regs[11];

    // Synchronous write on rising clock edge
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'd0;
            end
        end else if (we && (waddr != 5'd0)) begin
            regs[waddr] <= wdata;
        end
    end

endmodule
