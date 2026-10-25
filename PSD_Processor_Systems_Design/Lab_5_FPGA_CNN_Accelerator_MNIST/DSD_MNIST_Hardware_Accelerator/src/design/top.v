`timescale 1ns / 1ps

module accelerator_TOP(
    input  wire        CLK_IN,
    input  wire        RESET_IN,
    
    input  wire        UART_RX_ASYNC,
    output wire        UART_TX,

    output wire LED_OPS_BUSY,
    output wire LED_OPS_DONE,
    output wire LED_OPS_DATARX,
    output wire LED_IDLE,
    
    output wire [3:0] CNN_DETECTED_DIGIT,
    
    input wire [1:0] BAUD_SELECT
);

    wire CLK_RAW;
    wire CLK;
    wire RESET;
    wire locked_status;
    wire mmcm_clk_fb;
    
    clk_wiz_0 mmcm_100_to_70MHz (
        .clk_in1  (CLK_IN),
        .clk_out1 (CLK_RAW),
        .reset    (RESET_IN),
        .locked   (locked_status),
        .clkfb_in(mmcm_clk_fb),
        .clkfb_out(mmcm_clk_fb)
    );

    wire en_conv, en_maxp, en_class;

    BUFGCE u_clk_main (
        .O  (CLK),
        .CE (1'b1),
        .I  (CLK_RAW)
    );

    wire CLK_MAXP, CLK_CONV, CLK_CLASS;

    BUFGCE u_clock_gating_buffer_maxp (
        .O  (CLK_MAXP),
        .CE (en_maxp | RESET),
        .I  (CLK_RAW)
    );

    BUFGCE u_clock_gating_buffer_conv (
        .O  (CLK_CONV),
        .CE (en_conv | RESET),
        .I  (CLK_RAW)
    );

    BUFGCE u_clock_gating_buffer_class (
        .O  (CLK_CLASS),
        .CE (en_class | RESET),
        .I  (CLK_RAW)
    );

    assign RESET = ~locked_status;
    
    wire [15:0] CNN_RESULT_wire;
    assign CNN_DETECTED_DIGIT = CNN_RESULT_wire[3:0] ;

    
    wire UART_RX_SYNC;

    synchronizer_2stage uart_synch (
        .clk(CLK), 
        .rst(RESET),                     
        .async_sig_in(UART_RX_ASYNC), 
        .sync_sig_out(UART_RX_SYNC)
    );
    
    wire start_cnn;       
    wire cnn_busy;        
    wire halt;            
    wire latch_data_en;
    wire is_receiving;   

    assign UART_TX = 1'b1;

    assign LED_OPS_BUSY   = cnn_busy;
    assign LED_OPS_DONE   = halt;
    assign LED_OPS_DATARX = is_receiving;
    assign LED_IDLE       = ~(LED_OPS_BUSY | LED_OPS_DONE | LED_OPS_DATARX);

    wire sop_conv, sop_maxp, sop_class;
    wire eop_conv, eop_maxp, eop_class;

    wire [13:0] inp_act_addr, inp_wgt_addr, out_act_addr;
    wire [9:0]  inp_act_dim1, inp_act_dim2, inp_act_dim3;
    wire [9:0]  wgt_dim1, wgt_dim2, wgt_dim3;
    wire [9:0]  out_act_dim1, out_act_dim2, out_act_dim3;
    wire [7:0]  pool_dim, conv_stride;
    wire [3:0]  no_of_filter;
    wire        relu_en;

    
    wire        ctrl_inst_ena, ctrl_inst_wea;
    wire [9:0]  ctrl_inst_addra;
    wire [63:0] ctrl_inst_dina, inst_douta;

    wire        conv_wgt_ena, conv_wgt_wea;
    wire [13:0] conv_wgt_addra;
    wire [15:0] conv_wgt_dina, wgt_douta;

    wire        host_act_ena, host_act_wea;
    wire [13:0] host_act_addra;
    wire [127:0] host_act_dina;

    wire        conv_act_ena, conv_act_wea;
    wire [13:0] conv_act_addra;
    wire [127:0] conv_act_dina;

    wire        mp_act_ena, mp_act_wea;
    wire [13:0] mp_act_addra;
    wire [127:0] mp_act_dina;

    wire        cls_act_ena, cls_act_wea;
    wire [13:0] cls_act_addra;
    wire [127:0] cls_act_dina;

    wire [127:0] act_doutb;
    wire        conv_act_enb;
    wire [13:0] conv_act_addrb;
    
    wire        mp_act_enb;
    wire [13:0] mp_act_addrb;
    
    wire        cls_act_enb;
    wire [13:0] cls_act_addrb;

    wire        seg7_act_enb, seg7_busy;
    wire [13:0] seg7_act_addrb;

    
    wire        act_ena   = en_conv  ? conv_act_ena   : 
                            en_maxp  ? mp_act_ena     : 
                            en_class ? cls_act_ena    : host_act_ena;

    wire        act_wea   = en_conv  ? conv_act_wea   : 
                            en_maxp  ? mp_act_wea     : 
                            en_class ? cls_act_wea    : host_act_wea;

    wire [13:0] act_addra = en_conv  ? conv_act_addra : 
                            en_maxp  ? mp_act_addra   : 
                            en_class ? cls_act_addra  : host_act_addra;

    wire [127:0] act_dina = en_conv  ? conv_act_dina  : 
                            en_maxp  ? mp_act_dina    : 
                            en_class ? cls_act_dina   : host_act_dina;

    wire        act_enb   = seg7_busy ? seg7_act_enb   : 
                            en_conv   ? conv_act_enb   : 
                            en_maxp   ? mp_act_enb     : 
                            en_class  ? cls_act_enb    : 1'b0;

    wire [13:0] act_addrb = seg7_busy ? seg7_act_addrb : 
                            en_conv   ? conv_act_addrb : 
                            en_maxp   ? mp_act_addrb   : 
                            en_class  ? cls_act_addrb  : 14'd0;

    serial_to_bram u_host_if (
        .CLK(CLK), 
        .RESET(RESET),
        .UART_RX(UART_RX_SYNC),
        .CNN_BUSY(cnn_busy),
        .BAUD_SELECT(BAUD_SELECT),
        
        .START_CNN(start_cnn),
        .IS_RECEIVING(is_receiving),
        
        .BRAM_act_ENA(host_act_ena),   
        .BRAM_act_WEA(host_act_wea),   
        .BRAM_act_ADDRA(host_act_addra),   
        .BRAM_act_DINA(host_act_dina)
    );

    controller u_ctrl (
        .CLK(CLK), 
        .RST(RESET), 
        .START_CONTROLLER(start_cnn),
        
        .ENA(ctrl_inst_ena), 
        .WEA(ctrl_inst_wea), 
        .ADDRA(ctrl_inst_addra), 
        .DINA(ctrl_inst_dina), 
        .DOUTA(inst_douta),
        
        .EN_CONV(en_conv),     .EN_MAXP(en_maxp),     .EN_CLASS(en_class),
        .SOP_CONV(sop_conv),   .SOP_MAXP(sop_maxp),   .SOP_CLASS(sop_class),
        .EOP_CONV(eop_conv),   .EOP_MAXP(eop_maxp),   .EOP_CLASS(eop_class),
        
        .INP_ACT_ADDR(inp_act_addr), .INP_WGT_ADDR(inp_wgt_addr), .OUT_ACT_ADDR(out_act_addr),
        .INP_ACT_DIM1(inp_act_dim1), .INP_ACT_DIM2(inp_act_dim2), .INP_ACT_DIM3(inp_act_dim3),
        .WGT_DIM1(wgt_dim1),         .WGT_DIM2(wgt_dim2),         .WGT_DIM3(wgt_dim3),
        .OUT_ACT_DIM1(out_act_dim1), .OUT_ACT_DIM2(out_act_dim2), .OUT_ACT_DIM3(out_act_dim3),
        
        .POOL_DIM(pool_dim), 
        .CONV_STRIDE(conv_stride), 
        .NO_OF_FILTER(no_of_filter), 
        .RELU_EN(relu_en), 
        
        .LATCH_DATA_EN(latch_data_en),
        .halt(halt),
        .CNN_BUSY(cnn_busy)
    );

endmodule