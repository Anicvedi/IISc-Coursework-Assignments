# Try more aggressive Vivado implementation strategies on the unchanged RTL and
# unchanged constraints (10 ns clock) and report the worst setup slack of each.
#
#   vivado.bat -mode batch -source scripts/explore_timing.tcl
#
# New runs (impl_2, impl_3, ...) are created next to impl_1; impl_1 is not touched.
set root [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $root vivado_proj psd_lab3.xpr]

set flow [get_property FLOW [get_runs impl_1]]
set strategies {
    impl_2 Performance_Explore
    impl_3 Performance_ExtraTimingOpt
    impl_4 Performance_NetDelay_high
}

foreach {name strat} $strategies {
    if {[catch {
        create_run $name -parent_run synth_1 -flow $flow -strategy $strat
        launch_runs $name -jobs 2
        wait_on_run $name
    } err]} {
        puts "STRATEGY $strat ($name): FAILED TO RUN: $err"
        continue
    }
    set wns [get_property STATS.WNS [get_runs $name]]
    set tns [get_property STATS.TNS [get_runs $name]]
    set whs [get_property STATS.WHS [get_runs $name]]
    puts "STRATEGY $strat ($name): WNS=$wns TNS=$tns WHS=$whs"
    if {$wns ne "" && $wns >= 0} {
        puts "TIMING MET with $strat"
        break
    }
}
puts "EXPLORE DONE"
close_project
