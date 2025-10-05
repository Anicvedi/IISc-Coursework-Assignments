* Razavi Ch. 9: Common-source amplifier with a diode-connected PMOS load
.include "/home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod"

VDD VDD 0 DC 1.8
VIN IN 0 DC 0.9 AC 1
MP1 OUT OUT VDD VDD pmos W=20u L=0.5u
MN1 OUT IN 0 0 nmos W=10u L=0.5u
CL OUT 0 1p

.control
  op
  print v(OUT)
  ac dec 20 1 1G
  meas ac gain_1khz find vdb(OUT) at=1k
.endc

.end
