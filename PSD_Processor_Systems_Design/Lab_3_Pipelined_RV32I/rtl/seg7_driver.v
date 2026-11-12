// ==============================================================================
// E3: 245 Processor System Design - IISc DESE
// 4-Digit Multiplexed Seven-Segment Display Driver for Digilent Basys 3
// Active-Low Cathodes (seg[6:0]) and Anodes (an[3:0])
// ==============================================================================

module seg7_driver (
    input  wire        clk,      // 100 MHz board clock
    input  wire        rst,
    input  wire [15:0] value,    // 16-bit binary value to display in hex (4 hex digits)
    output reg  [6:0]  seg,      // Cathodes: seg[6]=g, seg[5]=f, ... seg[0]=a
    output reg  [3:0]  an,       // Anodes: an[3:0] active low
    output wire        dp        // Decimal point
);

    assign dp = 1'b1; // Turned off (active low)

    // 18-bit counter gives refresh rate ~381 Hz across 4 digits (~95 Hz/digit)
    reg [17:0] refresh_counter;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_counter <= 18'd0;
        end else begin
            refresh_counter <= refresh_counter + 1'b1;
        end
    end

    wire [1:0] digit_sel = refresh_counter[17:16];
    reg  [3:0] nibble;

    // Digit multiplexer
    always @(*) begin
        case (digit_sel)
            2'b00: begin
                an     = 4'b1110; // Digit 0 (Rightmost)
                nibble = value[3:0];
            end
            2'b01: begin
                an     = 4'b1101; // Digit 1
                nibble = value[7:4];
            end
            2'b10: begin
                an     = 4'b1011; // Digit 2
                nibble = value[11:8];
            end
            2'b11: begin
                an     = 4'b0111; // Digit 3 (Leftmost)
                nibble = value[15:12];
            end
            default: begin
                an     = 4'b1111;
                nibble = 4'h0;
            end
        endcase
    end

    // Hex-to-7Segment Decoder (Active Low: a=seg[0], b=seg[1] ... g=seg[6])
    always @(*) begin
        case (nibble)
            4'h0: seg = 7'b1000000; // 0
            4'h1: seg = 7'b1111001; // 1
            4'h2: seg = 7'b0100100; // 2
            4'h3: seg = 7'b0110000; // 3
            4'h4: seg = 7'b0011001; // 4
            4'h5: seg = 7'b0010010; // 5
            4'h6: seg = 7'b0000010; // 6
            4'h7: seg = 7'b1111000; // 7
            4'h8: seg = 7'b0000000; // 8
            4'h9: seg = 7'b0010000; // 9
            4'hA: seg = 7'b0001000; // A
            4'hB: seg = 7'b0000011; // b
            4'hC: seg = 7'b1000110; // C
            4'hD: seg = 7'b0100001; // d
            4'hE: seg = 7'b0000110; // E
            4'hF: seg = 7'b0001110; // F
            default: seg = 7'b1111111;
        endcase
    end

endmodule
