* ===================================================================
* Lab 5 - Problem 1: Single Ended Source Follower
* Technology: TSMC 180nm CMOS (VDD = 1.8V)
* Author: Analog VLSI Design Studio
* ===================================================================

.include "/home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod"

* Power Supplies
Vdd vdd 0 DC 1.8
Vss vss 0 DC 0.0

* Input Bias & Signal: Vdc = 1.25V, Vac = 1.0V
Vin in 0 DC 1.25 AC 1.0

* Bias Reference Current: 10uA
Iref vdd vb DC 10u

* Wide-Swing Resistor Biasing
R1 vb vg_bot 20k

* --- Wide-Swing Cascode Current Mirror (Reference Branch) ---
* M4: Top Cascode NMOS
M4 vg_bot vb n_mid1 vss nmos W=2.0u L=0.5u
* M3: Bottom Diode-Connected NMOS
M3 n_mid1 vg_bot vss vss nmos W=2.0u L=0.5u

* --- Wide-Swing Cascode Current Mirror (Output Sink Branch) ---
* M2: Top Cascode NMOS
M2 out vb n_mid2 vss nmos W=2.0u L=0.5u
* M1: Bottom Mirror NMOS
M1 n_mid2 vg_bot vss vss nmos W=2.0u L=0.5u

* --- Source Follower Input Transistor ---
* M5: NMOS Source Follower (Drain=VDD, Gate=in, Source=out, Bulk=VSS)
M5 vdd in out vss nmos W=1.92u L=0.5u

* --- Output Load ---
CL out 0 1p
RL out 0 1G

* ===================================================================
* Simulation Control & Measurements
* ===================================================================
.control
  set color0=white
  set color1=black

  echo "=========================================================="
  echo "--- LAB 5 PROBLEM 1: SOURCE FOLLOWER SIMULATION ---"
  echo "=========================================================="

  * 1. DC Operating Point Analysis
  op
  echo "--- DC BIAS POINT ---"
  print v(in) v(out) v(vb) v(vg_bot) v(n_mid1) v(n_mid2)
  show m5 : gm gds gmbs id vgs vds vth
  show m2 : gm gds gmbs id vgs vds vth
  show m1 : gm gds gmbs id vgs vds vth
  show m4 : gm gds gmbs id vgs vds vth
  show m3 : gm gds gmbs id vgs vds vth

  * 2. Part b: DC Sweep for Linearity & Verror
  dc Vin 0 1.8 0.002
  let v_err = v(out) - v(in)
  wrdata sim_results/p1_dc_sweep.dat v(in) v(out) v_err

  * Reset Vin for AC Analysis
  alter Vin dc = 1.25

  * 3. Part c: AC Gain Analysis (1Hz to 10GHz, 30 pts/decade)
  ac dec 30 1 10G
  let gain_db = db(v(out))
  let gain_mag = mag(v(out))
  let phase_deg = cph(v(out)) * 180 / 3.1415926535
  meas ac gain_lf find vdb(out) at=1
  meas ac bw when vdb(out)=gain_lf-3 fall=1
  print gain_lf bw
  wrdata sim_results/p1_ac_gain.dat gain_db gain_mag phase_deg

  * 4. Part d: Noise Analysis (1Hz to 10GHz, 30 pts/decade)
  noise v(out) Vin dec 30 1 10G
  setplot noise1
  meas noise onoise_lf find onoise_spectrum at=10
  meas noise inoise_lf find inoise_spectrum at=10
  print onoise_lf inoise_lf
  wrdata sim_results/p1_noise.dat onoise_spectrum inoise_spectrum

  * 5. Part e: Transient Step Response (+0.1V step: 1.25V to 1.35V)
  setplot default
  alter Vin dc = 1.25
  * Pulse: initial=1.25, pulsed=1.35, delay=1ns, rise=20ps, fall=20ps, width=40ns, period=100ns
  alter Vin pulse=[ 1.25 1.35 1n 20p 20p 40n 100n ]
  tran 0.02n 30n
  wrdata sim_results/p1_tran_step.dat v(in) v(out)

  echo "=========================================================="
  echo "--- LAB 5 PROBLEM 1 SIMULATION COMPLETE ---"
  echo "=========================================================="
  quit
.endc

.end
