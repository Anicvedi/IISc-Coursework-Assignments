import subprocess

deck = """* Test OP show
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
M5 vdd in out vss nmos W=2.1u L=0.5u
CL out 0 1p
RL out 0 1G
.control
  op
  show m5 : gm gds gmbs id vgs vds vth
  show m2 : gm gds gmbs id vgs vds vth
  show m1 : gm gds gmbs id vgs vds vth
  ac dec 30 1 10G
  meas ac gain_lf find vdb(out) at=1
  meas ac bw when vdb(out)=gain_lf-3 fall=1
  print gain_lf bw
  quit
.endc
.end
"""

with open("test_show.sp", "w") as f:
    f.write(deck)

res = subprocess.run(["wsl", "-d", "Ubuntu", "bash", "-c", "cd /home/anirudh/Analog_VLSI_Projects/05_Amplifier_Design/Problem_1_Source_Follower && ngspice -b test_show.sp"], capture_output=True, text=True)
print(res.stdout)
