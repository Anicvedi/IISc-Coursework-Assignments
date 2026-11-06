`timescale 1ns/1ps

module HA(
    input logic a,b,clk,
    output logic s,cout
);
    // Lets register the inputs
    logic a_reg;
    logic b_reg;
    logic s_reg;
    logic cout_reg;
    always_ff @( posedge clk ) begin
        a_reg <= a;
        b_reg <= b;
    end
    assign s_reg = a_reg ^ b_reg;
    assign cout_reg = a_reg& b_reg;
    always_ff @( posedge clk ) begin
        s <= s_reg;
        cout <= cout_reg;
    end
endmodule