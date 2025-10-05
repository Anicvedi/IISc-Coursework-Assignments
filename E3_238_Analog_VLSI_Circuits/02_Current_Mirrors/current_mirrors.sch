v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
C {title.sym} 160 -30 0 0 {name=l1 author="Anirudh Chaturvedi" title="Basic, Ratioed & High-Swing Cascode Current Mirrors (TSMC 180nm)"}
C {vdd.sym} 120 20 0 0 {name=l2 lab=VDD}
C {gnd.sym} 120 280 0 0 {name=l3 lab=GND}
C {nmos4.sym} 160 200 0 0 {name=M1 m=1 w=10u l=0.5u model=nmos}
C {nmos4.sym} 240 200 0 0 {name=M2 m=1 w=10u l=0.5u model=nmos}
C {nmos4.sym} 320 200 0 0 {name=M3 m=1 w=20u l=0.5u model=nmos}
C {nmos4.sym} 440 220 0 0 {name=M4 m=1 w=10u l=0.5u model=nmos}
C {nmos4.sym} 440 140 0 0 {name=M5 m=1 w=10u l=0.5u model=nmos}
C {nmos4.sym} 520 220 0 0 {name=M6 m=1 w=10u l=0.5u model=nmos}
C {nmos4.sym} 520 140 0 0 {name=M7 m=1 w=10u l=0.5u model=nmos}
C {code.sym} 620 40 0 0 {name=COMMANDS
only_toplevel=false
value=".include /home/anirudh/analog_vlsi/models/cmos_180nm.mod
Vdd VDD 0 DC 1.8
Vds_sweep VOUT 0 DC 0.9
Iref VDD NBIAS DC 50u

* Circuit 1: Basic 1:1 Current Mirror
M1 NBIAS NBIAS 0 0 nmos W=10u L=0.5u
M2 IOUT_BASIC NBIAS 0 0 nmos W=10u L=0.5u
Vmeas_basic VOUT IOUT_BASIC DC 0

* Circuit 2: Ratioed 1:2 Current Mirror
M3 IOUT_RATIO NBIAS 0 0 nmos W=20u L=0.5u
Vmeas_ratio VOUT IOUT_RATIO DC 0

* Circuit 3: High-Swing Cascode Current Mirror
Iref_casc VDD NCASC_TOP DC 50u
M4 NCASC_MID NCASC_MID 0 0 nmos W=10u L=0.5u
M5 NCASC_TOP NCASC_TOP NCASC_MID 0 nmos W=10u L=0.5u
M6 NCASC_OUT_MID NCASC_MID 0 0 nmos W=10u L=0.5u
M7 IOUT_CASC NCASC_TOP NCASC_OUT_MID 0 nmos W=10u L=0.5u
Vmeas_casc VOUT IOUT_CASC DC 0

.control
  set color0=white
  set color1=black
  * DC Voltage Sweep to test output compliance and output resistance
  dc Vds_sweep 0 1.8 0.01
  plot -i(Vmeas_basic) -i(Vmeas_ratio) -i(Vmeas_casc) title 'Iout vs Vds Compliance Curve'
.endc
"}
