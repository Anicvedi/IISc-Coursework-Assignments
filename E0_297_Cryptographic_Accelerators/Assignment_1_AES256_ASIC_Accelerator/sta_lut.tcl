read_liberty NangateOpenCellLibrary_typical.lib
read_verilog synth_lut.v
link_design AES256
read_sdc aes256.sdc
report_checks -path_delay max -format full
report_power
exit
