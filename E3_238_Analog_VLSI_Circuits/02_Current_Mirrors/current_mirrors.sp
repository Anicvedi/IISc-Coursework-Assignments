* ===================================================================
* CMOS Current Mirrors (Basic & Cascode) - 180nm CMOS Technology
* TSMC 180nm BSIM3v3 Models (VDD = 1.8V, Iref = 50uA)
* Author: Anirudh Chaturvedi (IISc Bangalore)
* ===================================================================

.include "/home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod"

* --- Power Supplies & Stimuli ---
Vdd VDD 0 DC 1.8
Vds_sweep VOUT 0 DC 0.9

* Reference Current Source: 50 uA
Iref VDD NBIAS DC 50u

* ===================================================================
* Circuit 1: Basic 1:1 NMOS Current Mirror
* Reference M1 (diode connected), Output M2
* ===================================================================
M1 NBIAS NBIAS 0 0 nmos W=10u L=0.5u
M2 IOUT_BASIC NBIAS 0 0 nmos W=10u L=0.5u
Vmeas_basic VOUT IOUT_BASIC DC 0

* ===================================================================
* Circuit 2: Basic 1:2 Ratioed NMOS Current Mirror (W = 20u)
* ===================================================================
M3 IOUT_RATIO NBIAS 0 0 nmos W=20u L=0.5u
Vmeas_ratio VOUT IOUT_RATIO DC 0

* ===================================================================
* Circuit 3: High-Swing / Standard Cascode Current Mirror
* Reference branch: M4 (bottom), M5 (top diode)
* Mirror branch:    M6 (bottom), M7 (top cascode)
* ===================================================================
Iref_casc VDD NCASC_TOP DC 50u
M4 NCASC_MID NCASC_MID 0 0 nmos W=10u L=0.5u
M5 NCASC_TOP NCASC_TOP NCASC_MID 0 nmos W=10u L=0.5u

M6 NCASC_OUT_MID NCASC_MID 0 0 nmos W=10u L=0.5u
M7 IOUT_CASC NCASC_TOP NCASC_OUT_MID 0 nmos W=10u L=0.5u
Vmeas_casc VOUT IOUT_CASC DC 0

* ===================================================================
* Control Block: DC Sweep & Interactive Plotting
* ===================================================================
.control
  set color0=white
  set color1=black

  echo "=========================================================="
  echo "--- RUNNING CURRENT MIRRORS DC SWEEP (Vout = 0V to 1.8V) ---"
  echo "=========================================================="

  op
  print i(Vmeas_basic) i(Vmeas_ratio) i(Vmeas_casc)

  * Sweep output voltage from 0 to 1.8V
  dc Vds_sweep 0 1.8 0.005

  * Plot branch currents vs output voltage
  plot -i(Vmeas_basic) -i(Vmeas_ratio) -i(Vmeas_casc) title 'CMOS Current Mirrors: Iout vs Vds'

  * Export data for Python plotting
  let ibasic = -i(Vmeas_basic)
  let iratio = -i(Vmeas_ratio)
  let icasc = -i(Vmeas_casc)
  wrdata /home/anirudh/Analog_VLSI_Projects/sim_results/current_mirrors_dc.dat ibasic iratio icasc
.endc

.end
