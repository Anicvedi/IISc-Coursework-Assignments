`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2026 18:42:41
// Design Name: 
// Module Name: booth_radix4_pipelined_multiplier
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


module booth_radix4_pipelined_multiplier (
    input clk,
    input rst,
    input signed [7:0] multiplicand,
    input signed [7:0] multiplier,
    output reg signed [15:0] product
);

/////////////////////////
// Stage 0: Input Register
/////////////////////////
reg signed [7:0] A_s0, B_s0;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        A_s0 <= 0;
        B_s0 <= 0;
    end else begin
        A_s0 <= multiplicand;
        B_s0 <= multiplier;
    end
end

/////////////////////////
// Booth Encoding
/////////////////////////
wire [9:0] B_ext = {B_s0[7], B_s0, 1'b0};

wire signed [15:0] pp0, pp1, pp2, pp3;

booth_encoder_radix4 be0 (.A(A_s0), .code(B_ext[2:0]), .pp(pp0));
booth_encoder_radix4 be1 (.A(A_s0), .code(B_ext[4:2]), .pp(pp1));
booth_encoder_radix4 be2 (.A(A_s0), .code(B_ext[6:4]), .pp(pp2));
booth_encoder_radix4 be3 (.A(A_s0), .code(B_ext[8:6]), .pp(pp3));

/////////////////////////
// Stage 1: Register Partial Products
/////////////////////////
reg signed [15:0] pp0_s1, pp1_s1, pp2_s1, pp3_s1;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pp0_s1 <= 0;
        pp1_s1 <= 0;
        pp2_s1 <= 0;
        pp3_s1 <= 0;
    end else begin
        pp0_s1 <= pp0;
        pp1_s1 <= pp1;
        pp2_s1 <= pp2;
        pp3_s1 <= pp3;
    end
end

/////////////////////////
// Stage 2: Shift + CSA1
/////////////////////////
wire [17:0] pp0e = {{2{pp0_s1[15]}}, pp0_s1};
wire [17:0] pp1e = {{2{pp1_s1[15]}}, pp1_s1} << 2;
wire [17:0] pp2e = {{2{pp2_s1[15]}}, pp2_s1} << 4;
wire [17:0] pp3e = {{2{pp3_s1[15]}}, pp3_s1} << 6;

wire [17:0] sum1, carry1;

csa3 csa1 (
    .a(pp0e),
    .b(pp1e),
    .c(pp2e),
    .sum(sum1),
    .carry(carry1)
);

reg [17:0] sum1_s2, carry1_s2, pp3e_s2;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        sum1_s2 <= 0;
        carry1_s2 <= 0;
        pp3e_s2 <= 0;
    end else begin
        sum1_s2 <= sum1;
        carry1_s2 <= carry1;
        pp3e_s2 <= pp3e;
    end
end

/////////////////////////
// Stage 3: CSA2
/////////////////////////
wire [17:0] carry1_shift = carry1_s2 << 1;

wire [17:0] sum2, carry2;

csa3 csa2 (
    .a(sum1_s2),
    .b(carry1_shift),
    .c(pp3e_s2),
    .sum(sum2),
    .carry(carry2)
);

reg [17:0] sum2_s3, carry2_s3;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        sum2_s3 <= 0;
        carry2_s3 <= 0;
    end else begin
        sum2_s3 <= sum2;
        carry2_s3 <= carry2;
    end
end

/////////////////////////
// Stage 4: Final Adder
/////////////////////////
wire [17:0] final_sum = sum2_s3 + (carry2_s3 << 1);

always @(posedge clk or posedge rst) begin
    if (rst)
        product <= 0;
    else
        product <= final_sum[15:0];
end

endmodule
