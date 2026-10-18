module booth_encoder_radix4 (
    input  wire signed [7:0] A,
    input  wire [2:0]        code,
    output reg  signed [15:0] pp
);

    wire signed [15:0] A_ext = {{8{A[7]}}, A};

    always @(*) begin
        case (code)
            3'b000,
            3'b111: pp = 16'sd0;

            3'b001,
            3'b010: pp = A_ext;

            3'b011: pp = A_ext <<< 1;

            3'b100: pp = -(A_ext <<< 1);

            3'b101,
            3'b110: pp = -A_ext;

            default: pp = 16'sd0;
        endcase
    end

endmodule
