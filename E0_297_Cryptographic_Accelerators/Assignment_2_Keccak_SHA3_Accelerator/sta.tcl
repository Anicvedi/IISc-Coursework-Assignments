read_liberty NangateOpenCellLibrary_typical.lib

read_verilog synth_keccak.v

link_design keccak_f1600

read_sdc keccak_f1600.sdc

# 1. Setup Timing Analysis (Max Path Delay)
report_checks -path_delay max -fields {slew cap input fanout} -digits 4

# 2. Hold Timing Analysis (Min Path Delay)
report_checks -path_delay min -fields {slew cap input fanout} -digits 4

# 3. Cell-level Power Estimation
report_power

exit
