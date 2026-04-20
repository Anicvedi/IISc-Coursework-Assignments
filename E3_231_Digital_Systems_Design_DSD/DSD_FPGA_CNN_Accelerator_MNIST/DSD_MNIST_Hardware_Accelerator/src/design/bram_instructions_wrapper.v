`timescale 1ns / 1ps

module bram_instructions_wrapper(
	input 			CLK,
	input 			ENA,
	input 			WEA,      
    input 	[ 9:0] 	ADDRA,  
    input 	[63:0] 	DINA,	
    output 	[63:0] 	DOUTA 
    );
    bram_instructions bram_instructions_0 (
      .clka(CLK),    // input wire clka
      .ena(ENA),      // input wire ena
      .wea(WEA),      // input wire [0 : 0] wea
      .addra(ADDRA),  // input wire [9 : 0] addra
      .dina(DINA),    // input wire [63 : 0] dina
      .douta(DOUTA)  // output wire [63 : 0] douta
);
endmodule