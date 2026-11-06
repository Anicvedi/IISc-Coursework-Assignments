create_clock -name clk -period 5.0 [get_ports clk]
set_clock_uncertainty 0.15 [get_clocks clk]
set_input_delay -clock clk 0.5 [get_ports {a b}]
set_output_delay -clock clk 0.5 [get_ports {s cout}]
set_load 0.015 [all_outputs]

