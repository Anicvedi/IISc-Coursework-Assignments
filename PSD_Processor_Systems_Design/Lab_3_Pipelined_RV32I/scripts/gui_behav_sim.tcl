# Source this inside the Vivado GUI Tcl console (or via -source) to set up the
# behavioural simulation of rv32i_pipeline_tb with the waveform signals the
# lab asks for (stalls, forwarding, flushes, cache misses).
#
#   source scripts/gui_behav_sim.tcl
#
# Note: the testbench hard-codes the memory file path
# "Academics/PSD/Lab3/memory/restoring_div.mem" relative to the xsim run
# directory, so a copy of memory/restoring_div.mem is placed there first.
set root [file normalize [file join [file dirname [info script]] ..]]
set run_dir [file join $root vivado_proj psd_lab3.sim sim_1 behav xsim]
file mkdir [file join $run_dir Academics PSD Lab3 memory]
file mkdir [file join $run_dir Academics PSD Lab3 reports]
file copy -force [file join $root memory restoring_div.mem] [file join $run_dir Academics PSD Lab3 memory restoring_div.mem]
file copy -force [file join $root memory restoring_div.mem] [file join $run_dir restoring_div.mem]

set_property top rv32i_pipeline_tb [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {0ns} -objects [get_filesets sim_1]
launch_simulation

set tb /rv32i_pipeline_tb
add_wave -radix bin  $tb/clk
add_wave -radix hex  $tb/pc_out
add_wave -radix bin  $tb/icache_stall_out
add_wave -radix bin  $tb/load_use_stall_out
add_wave -radix bin  $tb/ex_redirect_out
add_wave -radix bin  $tb/fwd_active_out
add_wave -radix unsigned $tb/quot_out
add_wave -radix unsigned $tb/rem_out
catch { add_wave -radix bin $tb/dut/flush_if_id }
catch { add_wave -radix bin $tb/dut/flush_id_ex }
catch { add_wave -radix bin $tb/dut/fwd_a }
catch { add_wave -radix bin $tb/dut/fwd_b }
catch { add_wave -radix hex $tb/dut/icache_miss_pulse }
run 5200 ns
