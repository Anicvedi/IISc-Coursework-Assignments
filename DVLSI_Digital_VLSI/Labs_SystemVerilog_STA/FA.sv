module FA(
    input logic a,b,c,
    output logic s,cout
);
logic clk;
logic [2:0] mode;
logic [2:0]count;
    CC U1(.*);
    CC U2(.*);
    logic p = a^b;
    assign s = p ^ c;
    assign cout = (p)?c:a;
endmodule