* ===================================================================
* CMOS Inverter: DC VTC & Transient Characterization (180nm CMOS)
* ===================================================================

.include "/home/anirudh/analog_vlsi/models/cmos_180nm.mod"

* Power Supplies
Vdd vdd 0 DC 1.8
Vss vss 0 DC 0.0

* Input Stimulus
* DC source for DC sweep, PULSE for transient analysis
Vin in 0 DC 0.0 PULSE(0 1.8 1n 50p 50p 5n 10n)

* --- CMOS Inverter Core ---
* Sizing: L = 180nm, Wn = 1.0um, Wp = 2.5um (sized for symmetric trip point)
Mn out in vss vss nmos W=1.0u L=0.18u
Mp out in vdd vdd pmos W=2.5u L=0.18u

* Output Load Capacitance (typical fan-out load)
Cload out 0 50f

* ===================================================================
* Simulation Control & Measurements
* ===================================================================
.control
  set color0=white
  set color1=black

  echo "=========================================================="
  echo "--- RUNNING CMOS INVERTER CHARACTERIZATION ---"
  echo "=========================================================="

  * 1. DC Voltage Transfer Characteristic (VTC) Sweep
  dc Vin 0 1.8 0.005

  * Calculate small-signal analog voltage gain: d(Vout)/d(Vin)
  let gain = deriv(v(out))

  echo "DC VTC Finished."
  wrdata /home/anirudh/analog_vlsi/sim_results/inverter_vtc.dat v(out) gain

  * 2. Transient Analysis (Propagation Delay & Slew Rate)
  tran 10p 20n
  echo "Transient Finished."
  wrdata /home/anirudh/analog_vlsi/sim_results/inverter_tran.dat v(in) v(out)

  echo "=========================================================="
  echo "--- INVERTER SIMULATION COMPLETE ---"
  echo "=========================================================="
  quit
.endc

.end
