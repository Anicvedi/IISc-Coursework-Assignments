* ===================================================================
* CMOS Differential Amplifier with Active Current Mirror Load
* 180nm CMOS Technology (VDD = 1.8V, Itail = 40uA)
* ===================================================================

.include "/home/anirudh/analog_vlsi/models/cmos_180nm.mod"

* Power Supplies
Vdd vdd 0 DC 1.8
Vss vss 0 DC 0.0

* Input Differential Stimulus
* Common-Mode DC Bias = 0.9V (mid-rail)
* Differential AC input: +/- 0.5V for AC differential gain analysis
Vinp inp 0 DC 0.9 AC 0.5
Vinm inm 0 DC 0.9 AC -0.5

* Bias Current Source (40uA)
Iref vdd nbias DC 40u

* --- Transistor Sizing ---
* M8: Diode-connected NMOS bias reference
M8 nbias nbias vss vss nmos W=20u L=0.5u

* M5: Tail current source (mirrors M8)
M5 ntail nbias vss vss nmos W=20u L=0.5u

* M1, M2: Input Differential Pair
M1 out1 inp ntail vss nmos W=10u L=0.18u
M2 mirr inm ntail vss nmos W=10u L=0.18u

* M3, M4: Active PMOS Current Mirror Load
M3 mirr mirr vdd vdd pmos W=20u L=0.5u
M4 out1 mirr vdd vdd pmos W=20u L=0.5u

* Load Capacitance
Cload out1 0 1p

* ===================================================================
* Simulation Control & Measurements
* ===================================================================
.control
  set color0=white
  set color1=black

  echo "=========================================================="
  echo "--- RUNNING DIFFERENTIAL AMPLIFIER SIMULATION ---"
  echo "=========================================================="

  * 1. DC Operating Point (Check saturation of all devices)
  op
  echo "DC Bias Points:"
  print v(inp) v(inm) v(out1) v(ntail) v(nbias) v(mirr)

  * 2. DC Differential Transfer Curve (Sweep Vinp around 0.9V)
  dc Vinp 0.8 1.0 0.001
  let diff_in = v(inp) - v(inm)
  let diff_gain_dc = deriv(v(out1))
  wrdata /home/anirudh/analog_vlsi/sim_results/diff_pair_dc.dat v(out1) diff_gain_dc

  * Reset Vinp back to DC 0.9 for AC
  alter Vinp dc = 0.9

  * 3. AC Differential Frequency Response (Gain & Bandwidth)
  ac dec 20 1 10G
  let gain_db = db(v(out1))
  let phase_deg = cph(v(out1)) * 180 / 3.1415926535
  wrdata /home/anirudh/analog_vlsi/sim_results/diff_pair_ac.dat gain_db phase_deg

  echo "=========================================================="
  echo "--- DIFFERENTIAL PAIR SIMULATION COMPLETE ---"
  echo "=========================================================="
  quit
.endc

.end
