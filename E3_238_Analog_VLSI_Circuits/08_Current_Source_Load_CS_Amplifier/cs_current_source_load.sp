* Razavi Ch. 10: Common-source amplifier with a PMOS current-mirror load
.include "/home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod"

VDD VDD 0 DC 1.8
VIN IN 0 DC 0.65 AC 1
IREF BIAS 0 DC 20u
MPREF BIAS BIAS VDD VDD pmos W=20u L=0.5u
MPLOAD OUT BIAS VDD VDD pmos W=20u L=0.5u
MN1 OUT IN 0 0 nmos W=10u L=0.5u
CL OUT 0 1p

.control
  dc VIN 0.5 0.65 0.01
  print v(OUT)
  alter VIN dc=0.55
  op
  print v(BIAS) v(OUT)
  ac dec 20 1 1G
  meas ac gain_1khz find vdb(OUT) at=1k
.endc

.end
