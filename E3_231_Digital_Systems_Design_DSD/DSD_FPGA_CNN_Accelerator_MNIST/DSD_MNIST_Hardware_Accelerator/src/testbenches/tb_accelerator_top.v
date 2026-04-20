`timescale 1ns / 1ps

module BUFGCE (output O, input CE, input I);
    assign O = I & CE;
endmodule

module bram_instructions (
    input clka, input ena, input wea,
    input [9:0] addra, input [63:0] dina, output reg [63:0] douta
);
    reg [63:0] mem [0:1023];
    reg [63:0] pipe;
    integer init_i;
    initial begin
        for (init_i = 0; init_i < 1024; init_i = init_i + 1)
            mem[init_i] = 64'h0;
        $readmemh("bram_instructions_init.hex", mem);
    end
    always @(posedge clka) begin
        if (ena) begin
            if (wea) mem[addra] <= dina;
            pipe <= mem[addra];
        end
        douta <= pipe;
    end
endmodule

module bram_weights (
    input clka, input ena, input wea,
    input [13:0] addra, input [15:0] dina, output reg [15:0] douta
);
    reg [15:0] mem [0:16383];
    reg [15:0] pipe;
    integer init_i;
    initial begin
        for (init_i = 0; init_i < 16384; init_i = init_i + 1)
            mem[init_i] = 16'h0;
        $readmemh("bram_weights_init.hex", mem);
    end
    always @(posedge clka) begin
        if (ena) begin
            if (wea) mem[addra] <= dina;
            pipe <= mem[addra];
        end
        douta <= pipe;
    end
endmodule

module bram_activations (
    input clka,
    input ena, input wea, input [13:0] addra, input [127:0] dina,
    input clkb, input enb, input [13:0] addrb, output reg [127:0] doutb
);
    reg [127:0] mem [0:16383];
    reg [127:0] pipe_b;
    integer init_i;
    initial begin
        for (init_i = 0; init_i < 16384; init_i = init_i + 1)
            mem[init_i] = 128'h0;
    end
    always @(posedge clka) begin
        if (ena && wea) mem[addra] <= dina;
    end
    always @(posedge clkb) begin
        if (enb) pipe_b <= mem[addrb];
        doutb <= pipe_b;
    end
endmodule

module tb_accelerator_TOP;

    localparam CLK_PERIOD       = 10;
    localparam CLOCK_FREQ       = 70_000_000;
    localparam SIM_BAUD_RATE    = 2_000_000;
    localparam CLKS_PER_BIT     = CLOCK_FREQ / SIM_BAUD_RATE;
    localparam BIT_PERIOD       = 1_000_000_000 / SIM_BAUD_RATE;
    localparam TIMEOUT_CYCLES   = 200_000_000;

    localparam MAX_IMAGES       = 128;
    localparam MAX_BYTES_PER_IMG= 4096;
    localparam MAX_TOTAL_BYTES  = MAX_IMAGES * MAX_BYTES_PER_IMG;

    reg         clk;
    reg         reset;
    reg         uart_rx_pin;
    wire        uart_tx_pin;
    wire        led_busy, led_done, led_datarx, led_idle;
    wire [3:0]  cnn_detected_digit;
    reg  [1:0]  baud_select;

    accelerator_TOP uut (
        .CLK_IN           (clk),
        .RESET_IN         (reset),
        .UART_RX_ASYNC (uart_rx_pin),
        .UART_TX       (uart_tx_pin),
        .LED_OPS_BUSY  (led_busy),
        .LED_OPS_DONE  (led_done),
        .LED_OPS_DATARX(led_datarx),
        .LED_IDLE      (led_idle),
        .CNN_DETECTED_DIGIT(cnn_detected_digit),
        .BAUD_SELECT   (baud_select)
    );

    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg [31:0] test_config     [0:3];
    reg [ 7:0] all_uart_data   [0:MAX_TOTAL_BYTES-1];
    reg [15:0] expected_classes [0:MAX_IMAGES-1];
    reg [15:0] true_labels     [0:MAX_IMAGES-1];
    reg [63:0] ref_instructions[0:1023];
    reg [15:0] ref_weights     [0:16383];

    integer num_test_images;
    integer bytes_per_image;
    integer fc_out_base;
    integer num_classes;

    integer errors;
    integer hw_pass_count;
    integer model_correct_count;
    integer i;

    task uart_send_byte;
        input [7:0] data;
        integer b;
        begin
            uart_rx_pin = 1'b0;
            #(BIT_PERIOD);
            for (b = 0; b < 8; b = b + 1) begin
                uart_rx_pin = data[b];
                #(BIT_PERIOD);
            end
            uart_rx_pin = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    function [15:0] decode_7seg;
        input [6:0] seg_val;
        begin
            case (seg_val)
                7'b1000000: decode_7seg = 16'd0;
                7'b1111001: decode_7seg = 16'd1;
                7'b0100100: decode_7seg = 16'd2;
                7'b0110000: decode_7seg = 16'd3;
                7'b0011001: decode_7seg = 16'd4;
                7'b0010010: decode_7seg = 16'd5;
                7'b0000010: decode_7seg = 16'd6;
                7'b1111000: decode_7seg = 16'd7;
                7'b0000000: decode_7seg = 16'd8;
                7'b0010000: decode_7seg = 16'd9;
                default:    decode_7seg = 16'hFFFF;
            endcase
        end
    endfunction

    reg led_datarx_prev, led_busy_prev, led_done_prev;

    always @(posedge clk) begin
        if (!reset) begin
            if ( led_datarx && !led_datarx_prev)
                $display("[%0t] LED: Data-RX ON", $time);
            if (!led_datarx &&  led_datarx_prev)
                $display("[%0t] LED: Data-RX OFF", $time);
            if ( led_busy && !led_busy_prev)
                $display("[%0t] LED: CNN_BUSY ON", $time);
            if (!led_busy &&  led_busy_prev)
                $display("[%0t] LED: CNN_BUSY OFF", $time);
            if ( led_done && !led_done_prev)
                $display("[%0t] LED: OPS_DONE ON", $time);
        end
        led_datarx_prev <= led_datarx;
        led_busy_prev   <= led_busy;
        led_done_prev   <= led_done;
    end

    reg [15:0] hw_result;

    initial begin

        errors              = 0;
        hw_pass_count       = 0;
        model_correct_count = 0;
        uart_rx_pin         = 1'b1;
        baud_select         = 2'b00;
        reset               = 1'b1;

        for (i = 0; i < 4;              i = i + 1) test_config[i]      = 32'h0;
        for (i = 0; i < MAX_TOTAL_BYTES; i = i + 1) all_uart_data[i]   = 8'h0;
        for (i = 0; i < MAX_IMAGES;      i = i + 1) expected_classes[i] = 16'h0;
        for (i = 0; i < MAX_IMAGES;      i = i + 1) true_labels[i]     = 16'h0;
        for (i = 0; i < 1024;            i = i + 1) ref_instructions[i] = 64'h0;
        for (i = 0; i < 16384;           i = i + 1) ref_weights[i]      = 16'h0;

        $readmemh("test_config.hex",      test_config);
        $readmemh("all_uart_bytes.hex",   all_uart_data);
        $readmemh("expected_classes.hex", expected_classes);
        $readmemh("true_labels.hex",      true_labels);
        $readmemh("bram_instructions_init.hex",            ref_instructions);
        $readmemh("bram_weights_init.hex",                 ref_weights);

        num_test_images = test_config[0];
        bytes_per_image = test_config[1];
        fc_out_base     = test_config[2];
        num_classes     = test_config[3];

        #(CLK_PERIOD * 20);
        reset = 1'b0;
        #(CLK_PERIOD * 10);
        #(20_000);

        begin : image_loop
            integer img_idx;
            integer byte_idx;
            integer base_offset;

            for (img_idx = 0; img_idx < num_test_images;
                 img_idx = img_idx + 1)
            begin
                base_offset = img_idx * bytes_per_image;

                for (byte_idx = 0; byte_idx < bytes_per_image;
                     byte_idx = byte_idx + 1) begin
                    uart_send_byte(all_uart_data[base_offset + byte_idx]);
                end

                begin : wait_inference
                    integer cyc;
                    for (cyc = 0; cyc < TIMEOUT_CYCLES; cyc = cyc + 1) begin
                        @(posedge clk);
                        if (led_done) begin
                            disable wait_inference;
                        end
                    end
                    errors = errors + 1;
                end

                #(CLK_PERIOD * 20);

                hw_result = {12'd0, cnn_detected_digit};

                if (hw_result == expected_classes[img_idx]) begin
                    hw_pass_count = hw_pass_count + 1;
                end else begin
                    errors = errors + 1;
                end

                if (hw_result == true_labels[img_idx])
                    model_correct_count = model_correct_count + 1;
            end
        end

        #(CLK_PERIOD * 1000);
        $finish;
    end

endmodule