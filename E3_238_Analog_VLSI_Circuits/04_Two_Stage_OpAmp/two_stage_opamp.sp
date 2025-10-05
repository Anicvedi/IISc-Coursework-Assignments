* ===================================================================
* Two-Stage Miller-Compensated CMOS Operational Amplifier Testbench
* Technology: 180nm CMOS (VDD = 1.8V)
* ===================================================================

.include "/home/anirudh/analog_vlsi/models/cmos_180nm.mod"

* Power Supplies
Vdd vdd 0 DC 1.8
Vss vss 0 DC 0.0

* Input Differential Stimuli for AC and Transient
* Common mode input bias = 0.9V (mid-rail)
Vinp inp 0 DC 0.9 AC 0.5 PULSE(0.85 0.95 10n 1n 1n 100n 200n)
Vinm inm 0 DC 0.9 AC -0.5

* Bias Current Reference: 20uA
Iref vdd nbias DC 20u

* --- Stage 0: Bias Generator ---
* M8: Diode-connected NMOS reference
M8 nbias nbias vss vss nmos W=10u L=0.18u

* --- Stage 1: Differential Amplifier with Current Mirror Load ---
* M5: Tail current source
M5 ntail nbias vss vss nmos W=20u L=0.18u

* M1, M2: Differential pair NMOS
M1 out1 inp ntail vss nmos W=10u L=0.18u
M2 mirr inm ntail vss nmos W=10u L=0.18u

* M3, M4: Active PMOS current mirror load
M3 mirr mirr vdd vdd pmos W=20u L=0.18u
M4 out1 mirr vdd vdd pmos W=20u L=0.18u

* --- Stage 2: Common-Source Gain Stage ---
* M6: PMOS Common-Source driver
M6 vout out1 vdd vdd pmos W=50u L=0.18u

* M7: NMOS Current sink active load
M7 vout nbias vss vss nmos W=30u L=0.18u

* --- Compensation Network: Miller Capacitor + Nulling Resistor ---
Cc out1 ncomp 1.5p
Rz ncomp vout 1.2k

* --- Output Load ---
Cl vout 0 5p

* ===================================================================
* Simulation Control & Measurements
* ===================================================================
.control
  set color0=white
  set color1=black

  echo "=========================================================="
  echo "--- RUNNING OP-AMP SIMULATION IN NGSPICE ---"
  echo "=========================================================="

  * 1. DC Operating Point Analysis
  op
  echo "DC Bias Points:"
  print v(out1) v(vout) v(ntail) v(nbias)

  * 2. AC Frequency Response (1 Hz to 10 GHz)
  ac dec 20 1 10G

  * Calculate Open Loop Gain in dB and Phase
  let gain_db = db(v(vout))
  let phase_deg = cph(v(vout)) * 180 / 3.1415926535

  echo "AC Simulation Finished."
  wrdata /home/anirudh/analog_vlsi/sim_results/opamp_ac.dat gain_db phase_deg

  * 3. Transient Step Response
  tran 0.1n 300n
  echo "Transient Simulation Finished."
  wrdata /home/anirudh/analog_vlsi/sim_results/opamp_tran.dat v(inp) v(vout)

  echo "=========================================================="
  echo "--- SIMULATION COMPLETE: Results saved to sim_results/ ---"
  echo "=========================================================="
  quit
.endc

.end
