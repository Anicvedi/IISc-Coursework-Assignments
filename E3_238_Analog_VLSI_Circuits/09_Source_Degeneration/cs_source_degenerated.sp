* Razavi Ch. 11: Source degeneration and local feedback
.include "/home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod"

VDD VDD 0 DC 1.8
VIN IN 0 DC 0.8 AC 1
RD VDD OUT 20k
RS NS 0 4.7k
MN1 OUT IN NS 0 nmos W=10u L=0.5u
CL OUT 0 1p

.control
  op
  print v(NS) v(OUT)
  ac dec 20 1 1G
  meas ac gain_1khz find vdb(OUT) at=1k
.endc

.end
