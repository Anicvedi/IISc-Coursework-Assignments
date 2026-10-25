`timescale 1ns / 1ps

module synchronizer_2stage(
    input clk,
    input rst,             
    input async_sig_in,
    output reg sync_sig_out
);
    
    reg D0_Q;
    
    always @(posedge clk) begin
        if (rst) begin
            D0_Q <= 1'b1;         
            sync_sig_out <= 1'b1; 
        end else begin
            D0_Q <= async_sig_in;
            sync_sig_out <= D0_Q;   
        end
    end
endmodule
