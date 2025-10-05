* Razavi Ch. 16: Common-source amplifier small-signal frequency response
.include "/home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod"

VDD VDD 0 DC 1.8
VIN IN 0 DC 0.57 AC 1
RD VDD OUT 20k
MN1 OUT IN 0 0 nmos W=10u L=0.5u
CL OUT 0 1p

.control
  op
  ac dec 30 1 1G
  meas ac gain_1khz find vdb(OUT) at=1k
  meas ac bandwidth when vdb(OUT)=gain_1khz-3 fall=1
  alter CL = 5p
  ac dec 30 1 1G
  meas ac gain_1khz_5pf find vdb(OUT) at=1k
  meas ac bandwidth_5pf when vdb(OUT)=gain_1khz_5pf-3 fall=1
.endc

.end
