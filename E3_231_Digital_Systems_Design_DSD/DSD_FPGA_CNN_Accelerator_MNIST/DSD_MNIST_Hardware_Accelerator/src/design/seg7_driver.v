`timescale 1ns / 1ps

module seg7_driver(
    input  wire        CLK,
    input  wire        RESET,
    
    input  wire        LATCH_DATA_EN, 
    
    output reg         BRAM_act_ENB,
    output reg  [13:0] BRAM_act_ADDRB,
    input  wire [127:0] BRAM_act_DOUTB,
    
    output reg  [6:0]  SEG7_SEG,
    output reg  [3:0]  SEG7_ANODE,
    
    output reg  [15:0] CNN_RESULT,
    output reg         BUSY
);
    
    localparam BRAM_ACT_CNN_RESULT_ADDR = 14'd8190;  

    reg [1:0] state;
    reg [1:0] wait_cnt;

    always @(posedge CLK) begin
        if (RESET) begin
            state <= 0;
            BRAM_act_ENB <= 0;
            BRAM_act_ADDRB <= 0;
            CNN_RESULT <= 16'd0;
            BUSY <= 0;
        end else begin
            case (state)
                0: begin
                    if (LATCH_DATA_EN) begin
                        BUSY <= 1;
                        BRAM_act_ENB <= 1;
                        BRAM_act_ADDRB <= BRAM_ACT_CNN_RESULT_ADDR;
                        wait_cnt <= 2;
                        state <= 1;
                    end
                end
                
                1: begin
                    if (wait_cnt == 0) begin
                        CNN_RESULT <= BRAM_act_DOUTB[15:0]; 
                        BRAM_act_ENB <= 0;
                        BUSY <= 0;
                        state <= 0;
                    end else begin
                        wait_cnt <= wait_cnt - 1;
                    end
                end
                
                default: state <= 0;
            endcase
        end
    end

    reg [19:0] refresh_counter; 
    wire [1:0] digit_sel = refresh_counter[19:18];
    reg [3:0]  current_hex_val;

    always @(posedge CLK) begin
        if (RESET)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end

    always @(*) begin
        case (digit_sel)
            2'b00: begin 
                SEG7_ANODE = 4'b1110; 
                current_hex_val = CNN_RESULT[3:0];   
            end
            2'b01: begin 
                SEG7_ANODE = (CNN_RESULT[15:4] == 0) ? 4'b1111 : 4'b1101; 
                current_hex_val = CNN_RESULT[7:4];   
            end
            2'b10: begin 
                SEG7_ANODE = (CNN_RESULT[15:8] == 0) ? 4'b1111 : 4'b1011; 
                current_hex_val = CNN_RESULT[11:8];  
            end
            2'b11: begin 
                SEG7_ANODE = (CNN_RESULT[15:12] == 0) ? 4'b1111 : 4'b0111; 
                current_hex_val = CNN_RESULT[15:12]; 
            end
        endcase
    end

    always @(*) begin
        case (current_hex_val)
            4'h0: SEG7_SEG = 7'b1000000;
            4'h1: SEG7_SEG = 7'b1111001;
            4'h2: SEG7_SEG = 7'b0100100;
            4'h3: SEG7_SEG = 7'b0110000;
            4'h4: SEG7_SEG = 7'b0011001;
            4'h5: SEG7_SEG = 7'b0010010;
            4'h6: SEG7_SEG = 7'b0000010;
            4'h7: SEG7_SEG = 7'b1111000;
            4'h8: SEG7_SEG = 7'b0000000;
            4'h9: SEG7_SEG = 7'b0010000;
            4'hA: SEG7_SEG = 7'b0001000;
            4'hB: SEG7_SEG = 7'b0000011;
            4'hC: SEG7_SEG = 7'b1000110;
            4'hD: SEG7_SEG = 7'b0100001;
            4'hE: SEG7_SEG = 7'b0000110;
            4'hF: SEG7_SEG = 7'b0001110;
            default: SEG7_SEG = 7'b1111111;
        endcase
    end

endmodule