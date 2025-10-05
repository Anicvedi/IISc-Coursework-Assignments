* Lab 5 Problem 1: Single Ended Source Follower
.include "../../models/cmos_180nm.mod"

.param VDD_VAL = 1.8
.param VDC_VAL = 1.25

* Supplies
Vdd vdd 0 DC {VDD_VAL}
Vss vss 0 DC 0.0

* Bias Reference
Iref vdd vb DC 10u
R1 vb vg_bot 20k

* Cascode Current Mirror (Reference Branch)
* M4 (Cascode)
M4 vg_bot vb n_mid1 vss nmos W=2.0u L=0.5u
* M3 (Diode)
M3 n_mid1 vg_bot vss vss nmos W=2.0u L=0.5u

* Cascode Current Mirror (Output Sink Branch)
* M2 (Cascode)
M2 out vb n_mid2 vss nmos W=2.0u L=0.5u
* M1 (Bottom Mirror)
M1 n_mid2 vg_bot vss vss nmos W=2.0u L=0.5u

* Source Follower Transistor M5
* Vin has DC 1.25V and AC 1V
Vin in 0 DC {VDC_VAL} AC 1.0
M5 vdd in out vss nmos W=2.5u L=0.5u

* Load
CL out 0 1p
RL out 0 1G

* Control block for initial test
.control
  save all @m.m5[gm] @m.m5[gmb] @m.m5[gds] @m.m5[vth] @m.m5[vds] @m.m5[vgs] @m.m5[id]
  save @m.m1[gm] @m.m1[gds] @m.m1[id] @m.m2[gm] @m.m2[gds] @m.m2[id]
  op
  echo "--- DC OPERATING POINT ---"
  print v(in) v(out) v(vb) v(vg_bot) v(n_mid1) v(n_mid2)
  print @m.m5[id] @m.m2[id] @m.m1[id]
  print @m.m5[gm] @m.m5[gmb] @m.m5[gds]
  print @m.m2[gm] @m.m2[gds]
  
  ac dec 30 1 10G
  meas ac gain_lf find vdb(out) at=1
  meas ac bw when vdb(out)=gain_lf-3 fall=1
  print gain_lf bw
  quit
.endc
.end
