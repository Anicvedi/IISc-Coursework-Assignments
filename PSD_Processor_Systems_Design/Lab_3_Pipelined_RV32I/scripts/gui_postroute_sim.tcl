# Post-implementation (post-route) timing simulation of basys3_top_tb with SDF.
# Source inside the Vivado GUI Tcl console after implementation has finished:
#   source scripts/gui_postroute_sim.tcl
catch { close_sim -force }
set_property top basys3_top_tb [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {0ns} -objects [get_filesets sim_1]
launch_simulation -mode post-implementation -type timing
set tb /basys3_top_tb
add_wave -radix bin      $tb/clk
add_wave -radix bin      $tb/btnC
add_wave -radix bin      $tb/sw
add_wave -radix unsigned $tb/led
add_wave -radix hex      $tb/seg
add_wave -radix bin      $tb/an
run 5300 ns
