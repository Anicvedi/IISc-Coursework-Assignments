`timescale 1ns / 1ps

module bram_weights_wrapper(
	input 			CLK,
	input 			ENA,
	input 			WEA,      
    input 	[13:0] 	ADDRA,  
    input 	[15:0] 	DINA,	
    output 	[15:0] 	DOUTA 	
    );
    
     bram_weights bram_weights_0 (
      .clka(CLK),    // input wire clka
      .ena(ENA),      // input wire ena
      .wea(WEA),      // input wire [0 : 0] wea
      .addra(ADDRA),  // input wire [13 : 0] addra
      .dina(DINA),    // input wire [15 : 0] dina
      .douta(DOUTA)  // output wire [15 : 0] douta
    );

endmodule