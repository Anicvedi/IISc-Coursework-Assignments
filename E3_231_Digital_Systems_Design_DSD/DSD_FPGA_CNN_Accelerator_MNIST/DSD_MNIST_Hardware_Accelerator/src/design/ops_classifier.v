`timescale 1ns / 1ps

module ops_classifier(
    input  wire        CLK_IN,
    input  wire        RESET,
    input  wire        MODULE_EN,

    input  wire        EXT_START_OF_COMPUTE,
    output reg         EXT_END_OF_COMPUTE,

    input  wire [13:0] INPUT_BASE_ADDR, 
    input  wire [9:0]  INPUT_SIZE,      
    input  wire [13:0] OUT_ACT_ADDR,    

    output reg         BRAM_act_ENA,
    output reg         BRAM_act_WEA,
    output reg  [13:0] BRAM_act_ADDRA,
    output reg  [127:0] BRAM_act_DINA,

    output reg         BRAM_act_ENB,
    output reg  [13:0] BRAM_act_ADDRB,
    input  wire [127:0] BRAM_act_DOUTB
);

    wire CLK;
    assign CLK = CLK_IN;    
    
    localparam S_IDLE     = 3'd0;
    localparam S_PIPELINE = 3'd1;
    localparam S_WRITE    = 3'd2;
    localparam S_DONE     = 3'd3;

    reg [2:0] state;
    reg running; 
    
    reg [9:0] req_cnt;
    reg [9:0] resp_cnt;

    reg signed [15:0] max_val;
    reg [9:0]         max_idx;

    reg valid_d1, valid_d2, valid_d3;
    reg [9:0] idx_d1, idx_d2, idx_d3;

    always @(posedge CLK) begin
        if (RESET) begin
            state <= S_IDLE;
            running <= 0;
            EXT_END_OF_COMPUTE <= 0;
            BRAM_act_ENA <= 0;
            BRAM_act_WEA <= 0;
            BRAM_act_ENB <= 0;
            valid_d1 <= 0;
            valid_d2 <= 0;
            valid_d3 <= 0;
            req_cnt <= 0;
            resp_cnt <= 0;
            max_val <= 16'sh8000;
            max_idx <= 0;
        end else if (EXT_START_OF_COMPUTE) begin
            running <= 1;
            state <= S_PIPELINE;
            EXT_END_OF_COMPUTE <= 0;
            
            req_cnt  <= 0;
            resp_cnt <= 0;
            max_val <= 16'sh8000; 
            max_idx <= 0;
            
            BRAM_act_ENA <= 0;
            BRAM_act_WEA <= 0;
            BRAM_act_ENB <= 0;
            valid_d1 <= 0;
            valid_d2 <= 0;
            valid_d3 <= 0;
            
        end else begin
            if (running) begin
                BRAM_act_ENA <= 0;
                BRAM_act_WEA <= 0;
                BRAM_act_ENB <= 0;
                
                valid_d1 <= (state == S_PIPELINE && req_cnt < INPUT_SIZE);
                valid_d2 <= valid_d1;
                valid_d3 <= valid_d2; 
                
                if (state == S_PIPELINE && req_cnt < INPUT_SIZE)
                    idx_d1 <= req_cnt;
                idx_d2 <= idx_d1;
                idx_d3 <= idx_d2; 

                case(state)
                    S_PIPELINE: begin
                        if (req_cnt < INPUT_SIZE) begin
                            BRAM_act_ENB   <= 1;
                            BRAM_act_ADDRB <= INPUT_BASE_ADDR + req_cnt; 
                            req_cnt        <= req_cnt + 1;
                        end

                        if (valid_d3) begin
                            if ((resp_cnt == 0) || ($signed(BRAM_act_DOUTB[15:0]) > max_val)) begin
                                max_val <= $signed(BRAM_act_DOUTB[15:0]); 
                                max_idx <= idx_d3;
                            end

                            resp_cnt <= resp_cnt + 1;
                            if (resp_cnt == INPUT_SIZE - 1) begin
                                state <= S_WRITE;
                            end
                        end
                    end
                    
                    S_WRITE: begin
                        BRAM_act_ENA   <= 1;
                        BRAM_act_WEA   <= 1;
                        BRAM_act_ADDRA <= OUT_ACT_ADDR;
                        BRAM_act_DINA  <= {112'd0, max_idx}; 
                        state          <= S_DONE;
                    end
                    
                    S_DONE: begin
                        EXT_END_OF_COMPUTE <= 1;
                        running <= 0; 
                        state <= S_IDLE;
                    end
                    
                    default: state <= S_IDLE;
                endcase
            end else begin
                BRAM_act_ENA <= 0;
                BRAM_act_WEA <= 0;
                BRAM_act_ENB <= 0;
                valid_d1 <= 0;
                valid_d2 <= 0;
                valid_d3 <= 0;
                
                if (EXT_END_OF_COMPUTE) begin
                    EXT_END_OF_COMPUTE <= 0;
                end
            end
        end
    end
endmodule