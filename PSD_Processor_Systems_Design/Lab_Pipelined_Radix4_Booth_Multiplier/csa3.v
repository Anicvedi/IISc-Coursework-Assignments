module csa3 (
    input  wire [17:0] a,
    input  wire [17:0] b,
    input  wire [17:0] c,
    output wire [17:0] sum,
    output wire [17:0] carry
);

    assign sum   = a ^ b ^ c;
    assign carry = (a & b) | (b & c) | (a & c);

endmodule
