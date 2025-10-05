* ===================================================================
* Lab 5 - Problem 1: Output Impedance Testbench
* Technology: TSMC 180nm CMOS (VDD = 1.8V)
* ===================================================================

.include "/home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod"

* Power Supplies
Vdd vdd 0 DC 1.8
Vss vss 0 DC 0.0

* Input Bias: Vin has DC 1.25V, AC 0V (small signal ground)
Vin in 0 DC 1.25 AC 0.0

* Bias Reference Current: 10uA
Iref vdd vb DC 10u

* Wide-Swing Resistor Biasing
R1 vb vg_bot 20k

* --- Wide-Swing Cascode Current Mirror (Reference Branch) ---
M4 vg_bot vb n_mid1 vss nmos W=2.0u L=0.5u
M3 n_mid1 vg_bot vss vss nmos W=2.0u L=0.5u

* --- Wide-Swing Cascode Current Mirror (Output Sink Branch) ---
M2 out vb n_mid2 vss nmos W=2.0u L=0.5u
M1 n_mid2 vg_bot vss vss nmos W=2.0u L=0.5u

* --- Source Follower Input Transistor ---
M5 vdd in out vss nmos W=1.92u L=0.5u

* --- Output Load ---
CL out 0 1p
RL out 0 1G

* --- Test Stimulus for Output Impedance ---
* Connect AC 1A current source into out: Zout = V(out) / Itest = V(out)
Itest 0 out DC 0 AC 1.0

.control
  set color0=white
  set color1=black

  echo "=========================================================="
  echo "--- RUNNING OUTPUT IMPEDANCE AC SIMULATION ---"
  echo "=========================================================="

  op
  ac dec 30 1 10G
  let zout_mag = mag(v(out))
  let zout_db = db(v(out))
  let zout_phase = cph(v(out)) * 180 / 3.1415926535

  meas ac zout_lf find mag(v(out)) at=1
  meas ac zout_3db find mag(v(out)) at=20Meg
  print zout_lf zout_3db

  wrdata sim_results/p1_zout.dat zout_mag zout_db zout_phase

  quit
.endc

.end
