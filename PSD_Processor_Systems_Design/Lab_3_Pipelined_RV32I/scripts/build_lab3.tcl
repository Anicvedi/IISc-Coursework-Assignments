# ==============================================================================
# PSD Lab 3 - rebuild the Vivado project and run every step the handout asks for.
#
# Run from the Lab_3_Pipelined_RV32I folder:
#   C:\AMDDesignTools\2026.1\Vivado\bin\vivado.bat -mode batch -source scripts/build_lab3.tcl
#
# It creates ./vivado_proj/psd_lab3.xpr, runs synthesis + implementation, and
# writes timing / utilization / power reports to ./reports/rebuild/
# (your earlier reports in ./reports/ are not touched).
# Afterwards open vivado_proj/psd_lab3.xpr in the GUI and take the screenshots
# listed in SCREENSHOT_CHECKLIST.md.
# ==============================================================================
set root     [file normalize [file join [file dirname [info script]] ..]]
set proj_dir [file join $root vivado_proj]
set rpt_dir  [file join $root reports rebuild]
file mkdir $rpt_dir

create_project -force psd_lab3 $proj_dir -part xc7a35tcpg236-1

# ---- design sources -----------------------------------------------------------
add_files -fileset sources_1 [glob [file join $root rtl *.v]]
add_files -fileset sources_1 [file join $root memory restoring_div.mem]
add_files -fileset constrs_1 [file join $root constrs basys3.xdc]
set_property top basys3_top [get_filesets sources_1]
set_property verilog_define {} [get_filesets sources_1]

# ---- simulation sources -------------------------------------------------------
add_files -fileset sim_1 [file join $root testbench rv32i_pipeline_tb.v]
add_files -fileset sim_1 [file join $root testbench basys3_top_tb.v]
add_files -fileset sim_1 [file join $root memory restoring_div.mem]
set_property top basys3_top_tb [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {20us} -objects [get_filesets sim_1]
update_compile_order -fileset sources_1

# ---- synthesis + implementation ----------------------------------------------
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} { error "synth_1 failed" }

launch_runs impl_1 -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} { error "impl_1 failed" }

# ---- reports (post-route) -----------------------------------------------------
open_run impl_1
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $rpt_dir post_route_timing.rpt]
report_utilization    -file [file join $rpt_dir post_route_util.rpt]
report_utilization    -hierarchical -file [file join $rpt_dir post_route_util_hier.rpt]
report_power          -file [file join $rpt_dir post_route_power.rpt]
report_drc            -file [file join $rpt_dir post_route_drc.rpt]
puts "WNS = [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] ns"

puts "DONE. Open $proj_dir/psd_lab3.xpr in the Vivado GUI for screenshots."
