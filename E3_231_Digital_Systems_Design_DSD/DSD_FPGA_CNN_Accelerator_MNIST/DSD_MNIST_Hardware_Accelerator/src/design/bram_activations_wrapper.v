`timescale 1ns / 1ps

module bram_activations_wrapper(
    input CLK,
    input ena,
    input [0:0] wea,
    input [13:0] addra,
    input [127:0] dina,

    input enb,
    input [13:0] addrb,
    output [127:0] doutb
);

bram_activations bram_activations_0 (
    .clka(CLK),
    .ena(ena),
    .wea(wea),
    .addra(addra),
    .dina(dina),

    .clkb(CLK),
    .enb(enb),
    .addrb(addrb),
    .doutb(doutb)
);

endmodule