create_clock -name clock -period 10.0 [get_ports clock]
set_input_delay 0.0 -clock clock [get_ports {write reset start ptxt* key*}]
set_output_delay 0.0 -clock clock [all_outputs]
