`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2026 19:14:46
// Design Name: 
// Module Name: modN_updown_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module modN_updown_counter (
    input  wire        clk,      // 100 MHz
    input  wire        clk_en,   // 1 Hz enable
    input  wire        rst_n,
    input  wire [3:0]  N,
    input  wire [1:0]  mode,
    input  wire        load,
    input  wire [3:0]  load_val,
    output reg  [3:0]  count
);

    reg direction;
    wire [3:0] N_eff = (N < 2) ? 4'd2 : N;

    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 4'd0;
            direction <= 1'b1;
        end
        else if (clk_en) begin
            if (load)
                count <= (load_val < N_eff) ? load_val : 4'd0;
            else begin
                case (mode)
                    2'b00: count <= count;

                    2'b01: count <= (count == N_eff-1) ? 4'd0 : count + 1'b1;

                    2'b10: count <= (count == 0) ? N_eff-1 : count - 1'b1;

                    2'b11: begin
                        if (direction) begin
                            if (count == N_eff-1) begin
                                count <= count - 1'b1;
                                direction <= 1'b0;
                            end else
                                count <= count + 1'b1;
                        end else begin
                            if (count == 0) begin
                                count <= count + 1'b1;
                                direction <= 1'b1;
                            end else
                                count <= count - 1'b1;
                        end
                    end
                endcase
            end
        end
    end
endmodule



