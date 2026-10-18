`timescale 1ns / 1ps

module top_question2a (
    input clk,
    input btn,
    input dir,              // 1 = up, 0 = down
    input rst_n,

    input [3:0] N,          // modulus
    input load,             // load enable
    input [3:0] load_val,   // value to load

    output [3:0] count
);

// mode: up / down
wire [1:0] mode = dir ? 2'b01 : 2'b10;

// counter
modN_updown_counter u_counter (
    .clk(clk),
    .clk_en(btn),
    .rst_n(rst_n),
    .N(N),
    .mode(mode),
    .load(load),
    .load_val(load_val),
    .count(count)
);

endmodule