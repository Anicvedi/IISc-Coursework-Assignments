# Clock definition: 100 MHz (10.0 ns period)
create_clock -name clock -period 10.0 [get_ports clock]

# Input constraints
set_input_delay 0.0 -clock clock [get_ports {reset write start word_addr* word_data_in*}]

# Output constraints
set_output_delay 0.0 -clock clock [all_outputs]
