`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2026 12:36:20 PM
// Design Name: 
// Module Name: AXI4_LITE_TOP_TB
// Project Name: Digital Systems Design with FPGAs 2026, Assignment 3
// Target Devices: Basys-3
// Tool Versions: 
// Description: This is a testbench for your AXI4_LITE_TOP module, and should be used without modifications.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AXI4_LITE_TOP_TB();
    reg clk;
    reg resetn;
    
    reg start;
    wire get_data, get_command;
    reg [31:0] data_in;
    reg [15:0] input_command;
    wire [31:0] data_out;
    
    AXI4_LITE_TOP top_uut(
        .CLK(clk),
        .RESETN(resetn),
        .START(start),
        .CMD_IN(input_command),
        .DATA_IN(data_in),
        .GET_DATA(get_data),
        .GET_CMD(get_command),
        .DATA_OUT(data_out)
    );
    
    always #5.5 clk = ~clk;
    
    initial begin
        clk = 0;
        resetn = 0;
        start = 0;
        input_command = 16'd0;
        #150 resetn = 1;
        
        start = 1;
        @(posedge clk);
        start = 0;
        
/************ WRITE INTO BRAM ****************/        
        @(posedge get_command);
        input_command = 16'h8300;  //write 3 words starting at location 0; 1000_0100_0000_0000
        
        
        @(posedge get_data);
        data_in = 32'hABCDEF12;
        
        @(posedge get_data);
        data_in = 32'hdeadbeef;
        
        @(posedge get_data);
        data_in = 32'h12345678;
                
        
/************ WRITE INTO BRAM ****************/     
        
         @(posedge get_command);
        input_command = 16'h8503;  //write 5 words starting at location 4; 1000_0100_0000_0100
        
        @(posedge get_data);
        data_in = 32'h77777777;
        
        @(posedge get_data);
        data_in = 32'h11111111;
        
        @(posedge get_data);
        data_in = 32'h22222222;
        
        @(posedge get_data);
        data_in = 32'h88888888;
        
        @(posedge get_data);
        data_in = 32'h45678910;
                
/************ READ FROM BRAM ****************/     

        @(posedge get_command);
        input_command = 16'h0400; //read 4 words starting from location 0; 0000_0100_0000_0000
                
/************ WRITE INTO BRAM ****************/     
        
        @(posedge get_command);
        input_command = 16'h8308;  //write 3 words starting at location 8; 1000_0011_0000_1000
        
        @(posedge get_data);
        data_in = 32'h66666666;
        
        @(posedge get_data);
        data_in = 32'h99999999;
        
        @(posedge get_data);
        data_in = 32'h44444444;
        
        
/************ READ FROM BRAM ****************/     

        @(posedge get_command);
        input_command = 16'h0204; //read 2 words from starting location 4; 0000_0010_0000_0100
        
/************ READ FROM BRAM ****************/     

        @(posedge get_command);
        input_command = 16'h0704; //read 7 words from starting from location 4; 0000_0111_0000_0100

/************ FINISH SIMULATION ****************/        
        @(posedge get_command);
        repeat (5) @(posedge clk); // give 5 clock cycles before finish
        $finish;
    end
endmodule
