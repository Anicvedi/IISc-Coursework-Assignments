`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.03.2026 17:52:45
// Design Name: 
// Module Name: debouncer
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


`timescale 1ns / 1ps

module debouncer (
    input clk,
    input btn_async,
    output reg btn_pulse
);

parameter MAX_COUNT = 2_000_000; // 20 ms @ 100 MHz sim level 5000

reg btn_sync0, btn_sync1;
reg [20:0] count = 0;
reg stable_state = 0;

// -----------------------------
// 2-stage synchronizer
// -----------------------------
always @(posedge clk) begin
    btn_sync0 <= btn_async;
    btn_sync1 <= btn_sync0;
end

// -----------------------------
// Debounce logic
// -----------------------------
always @(posedge clk) begin
    if (btn_sync1 != stable_state) begin
        count <= count + 1;

        if (count >= MAX_COUNT) begin
            stable_state <= btn_sync1;
            count <= 0;

            // generate pulse only on press
            if (btn_sync1 == 1)
                btn_pulse <= 1;
            else
                btn_pulse <= 0;
        end else begin
            btn_pulse <= 0;
        end

    end else begin
        count <= 0;
        btn_pulse <= 0;
    end
end

endmodule