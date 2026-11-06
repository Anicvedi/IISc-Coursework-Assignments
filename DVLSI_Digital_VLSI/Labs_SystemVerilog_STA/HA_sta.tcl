# Read SkyWater 130nm Standard Cell Library
read_liberty /home/anirudh/.volare/volare/sky130/versions/7519dfb04400f224f140749cda44ee7de6f5e095/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# Read Gate-Level Netlist
read_verilog HA_synth.v

# Link Design
link_design HA

# Read Timing Constraints
read_sdc HA_constraints.sdc

puts "\n======================================================="
puts "           SETUP TIMING REPORT (MAX DELAY)             "
puts "======================================================="
report_checks -path_delay max -fields {slew cap input fanout} -digits 3

puts "\n======================================================="
puts "           HOLD TIMING REPORT (MIN DELAY)              "
puts "======================================================="
report_checks -path_delay min -fields {slew cap input fanout} -digits 3

puts "\n======================================================="
puts "           TIMING SUMMARY METRICS                      "
puts "======================================================="
report_worst_slack -max
report_worst_slack -min
report_tns
report_wns
report_power
exit
