// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// Lab Exercise 3: 5-Stage Pipelined RISC-V Processor with Instruction Cache
// Main Instruction Memory (512 x 32-bit) implemented in Block RAM
// ==============================================================================

module instr_bram #(
    parameter MEM_FILE = "restoring_div.mem"
)(
    input  wire        clk,
    input  wire [8:0]  addr,
    output reg  [31:0] rdata
);

    (* ram_style = "block" *) reg [31:0] mem [0:511];
    integer i;

    initial begin
        for (i = 0; i < 512; i = i + 1)
            mem[i] = 32'h00000013; // NOP (addi x0, x0, 0)
        $readmemh(MEM_FILE, mem);
    end

    // Synchronous read to infer Xilinx Block RAM (RAMB18E1 / RAMB36E1)
    always @(posedge clk) begin
        rdata <= mem[addr];
    end

endmodule
