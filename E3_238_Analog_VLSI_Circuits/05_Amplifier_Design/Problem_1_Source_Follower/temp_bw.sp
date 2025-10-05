* Test exact BW
.include "../../models/cmos_180nm.mod"
Vdd vdd 0 DC 1.8
Vss vss 0 DC 0
Iref vdd vb DC 10u
R1 vb vg_bot 20k
M4 vg_bot vb n_mid1 vss nmos W=2.0u L=0.5u
M3 n_mid1 vg_bot vss vss nmos W=2.0u L=0.5u
M2 out vb n_mid2 vss nmos W=2.0u L=0.5u
M1 n_mid2 vg_bot vss vss nmos W=2.0u L=0.5u
Vin in 0 DC 1.25 AC 1.0
M5 vdd in out vss nmos W=2.0u L=0.5u
CL out 0 1p
RL out 0 1G
.control
  ac dec 30 1 10G
  meas ac gain_lf find vdb(out) at=1
  meas ac bw when vdb(out)=gain_lf-3 fall=1
  print gain_lf bw
  quit
.endc
.end
