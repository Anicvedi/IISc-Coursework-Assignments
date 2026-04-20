create_clock -period 10.000 -name CLK_IN -waveform {0.000 5.000} [get_ports CLK_IN]

set_property IOSTANDARD LVCMOS18 [get_ports {BAUD_SELECT[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {BAUD_SELECT[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports {CNN_DETECTED_DIGIT[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {CNN_DETECTED_DIGIT[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {CNN_DETECTED_DIGIT[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {CNN_DETECTED_DIGIT[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports LED_IDLE]
set_property IOSTANDARD LVCMOS18 [get_ports LED_OPS_BUSY]
set_property IOSTANDARD LVCMOS18 [get_ports LED_OPS_DATARX]
set_property IOSTANDARD LVCMOS18 [get_ports LED_OPS_DONE]
set_property IOSTANDARD LVCMOS18 [get_ports UART_RX_ASYNC]
set_property IOSTANDARD LVCMOS18 [get_ports UART_TX]
set_property IOSTANDARD LVCMOS18 [get_ports CLK_IN]
set_property IOSTANDARD LVCMOS18 [get_ports RESET_IN]


set_property PACKAGE_PIN V18 [get_ports UART_RX_ASYNC]
set_property PACKAGE_PIN AA19 [get_ports UART_TX]
set_property PACKAGE_PIN M17 [get_ports RESET_IN]
set_property PACKAGE_PIN U16 [get_ports {CNN_DETECTED_DIGIT[3]}]
set_property PACKAGE_PIN T16 [get_ports {CNN_DETECTED_DIGIT[2]}]
set_property PACKAGE_PIN T15 [get_ports {CNN_DETECTED_DIGIT[1]}]
set_property PACKAGE_PIN T14 [get_ports {CNN_DETECTED_DIGIT[0]}]
set_property PACKAGE_PIN Y13 [get_ports LED_OPS_DONE]
set_property PACKAGE_PIN W15 [get_ports LED_OPS_BUSY]
set_property PACKAGE_PIN W16 [get_ports LED_OPS_DATARX]
set_property PACKAGE_PIN V15 [get_ports LED_IDLE]

set_property PACKAGE_PIN R4 [get_ports CLK_IN]
set_property PACKAGE_PIN M17 [get_ports RESET_IN]
set_property PACKAGE_PIN F21 [get_ports {BAUD_SELECT[1]}]
set_property PACKAGE_PIN E22 [get_ports {BAUD_SELECT[0]}]


