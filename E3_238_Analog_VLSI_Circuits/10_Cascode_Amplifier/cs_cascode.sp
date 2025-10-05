* Razavi Ch. 13: NMOS common-source cascode amplifier
.include "/home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod"

VDD VDD 0 DC 1.8
VIN IN 0 DC 0.57 AC 1
VCAS VCAS 0 DC 1.0
RD VDD OUT 20k
MN1 N1 IN 0 0 nmos W=10u L=0.5u
MN2 OUT VCAS N1 0 nmos W=10u L=0.5u
CL OUT 0 1p

.control
  op
  print v(N1) v(OUT)
  ac dec 20 1 1G
  meas ac gain_1khz find vdb(OUT) at=1k
.endc

.end
