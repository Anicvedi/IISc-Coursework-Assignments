* Razavi Ch. 17: Common-source amplifier output and input-referred noise
.include "/home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod"

VDD VDD 0 DC 1.8
VIN IN 0 DC 0.57 AC 1
RD VDD OUT 20k
MN1 OUT IN 0 0 nmos W=10u L=0.5u
CL OUT 0 1p

.control
  op
  noise v(OUT) VIN dec 10 10 100Meg
  print onoise_total inoise_total
.endc

.end
