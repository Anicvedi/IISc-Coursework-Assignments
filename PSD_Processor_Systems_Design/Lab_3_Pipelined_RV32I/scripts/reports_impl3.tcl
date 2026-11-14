# Write post-route reports for the timing-met run (impl_3,
# strategy Performance_ExplorePostRoutePhysOpt) into reports/impl3_met/.
#   vivado.bat -mode batch -source scripts/reports_impl3.tcl
set root [file normalize [file join [file dirname [info script]] ..]]
set out [file join $root reports impl3_met]
file mkdir $out
open_checkpoint [file join $root vivado_proj psd_lab3.runs impl_3 basys3_top_postroute_physopt.dcp]
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out post_route_timing.rpt]
report_utilization -file [file join $out post_route_util.rpt]
report_utilization -hierarchical -file [file join $out post_route_util_hier.rpt]
report_power -file [file join $out post_route_power.rpt]
report_drc -file [file join $out post_route_drc.rpt]
puts "WNS=[get_property SLACK [get_timing_paths -max_paths 1 -setup]] WHS=[get_property SLACK [get_timing_paths -max_paths 1 -hold]]"
puts "REPORTS DONE"
