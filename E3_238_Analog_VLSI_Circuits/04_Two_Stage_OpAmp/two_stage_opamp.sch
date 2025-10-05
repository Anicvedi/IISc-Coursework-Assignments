v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
C {title.sym} 160 -30 0 0 {name=l1 author="Anirudh Chaturvedi" title="Two-Stage Miller-Compensated CMOS Op-Amp (TSMC 180nm)"}
C {vdd.sym} 120 20 0 0 {name=l2 lab=VDD}
C {gnd.sym} 120 280 0 0 {name=l3 lab=GND}
C {ipin.sym} 80 140 0 0 {name=p1 lab=INP}
C {ipin.sym} 80 180 0 0 {name=p2 lab=INM}
C {opin.sym} 540 160 0 0 {name=p3 lab=VOUT}
C {nmos4.sym} 200 140 0 0 {name=M1 m=1 w=10u l=0.18u model=nmos}
C {nmos4.sym} 200 180 0 0 {name=M2 m=1 w=10u l=0.18u model=nmos}
C {pmos4.sym} 200 60 0 0 {name=M3 m=1 w=20u l=0.18u model=pmos}
C {pmos4.sym} 280 60 0 0 {name=M4 m=1 w=20u l=0.18u model=pmos}
C {nmos4.sym} 240 240 0 0 {name=M5 m=1 w=20u l=0.18u model=nmos}
C {pmos4.sym} 440 100 0 0 {name=M6 m=1 w=50u l=0.18u model=pmos}
C {nmos4.sym} 440 220 0 0 {name=M7 m=1 w=30u l=0.18u model=nmos}
C {nmos4.sym} 120 180 0 0 {name=M8 m=1 w=10u l=0.18u model=nmos}
C {capa.sym} 360 80 0 0 {name=Cc m=1 value=1.5p}
C {res.sym} 360 140 0 0 {name=Rz value=1.2k}
C {capa.sym} 520 220 0 0 {name=Cl m=1 value=5p}
C {code.sym} 620 40 0 0 {name=COMMANDS
only_toplevel=false
value=".include /home/anirudh/analog_vlsi/models/cmos_180nm.mod
Vdd vdd 0 DC 1.8
Vss vss 0 DC 0.0
Vinp inp 0 DC 0.9 AC 0.5 PULSE(0.85 0.95 10n 1n 1n 100n 200n)
Vinm inm 0 DC 0.9 AC -0.5
Iref vdd nbias DC 20u

* Bias Generator
M8 nbias nbias vss vss nmos W=10u L=0.18u

* Stage 1: Diff Pair & Active Mirror
M5 ntail nbias vss vss nmos W=20u L=0.18u
M1 out1 inp ntail vss nmos W=10u L=0.18u
M2 mirr inm ntail vss nmos W=10u L=0.18u
M3 mirr mirr vdd vdd pmos W=20u L=0.18u
M4 out1 mirr vdd vdd pmos W=20u L=0.18u

* Stage 2: Common Source Driver & Pull-down
M6 vout out1 vdd vdd pmos W=50u L=0.18u
M7 vout nbias vss vss nmos W=30u L=0.18u

* Miller Compensation & Nulling Resistor
Cc out1 ncomp 1.5p
Rz ncomp vout 1.2k
Cl vout 0 5p

.control
  set color0=white
  set color1=black
  * 1. DC Operating Point Check
  op
  print v(out1) v(vout) v(ntail)
  * 2. AC Frequency Response (Gain & Phase Margin)
  ac dec 50 10 10G
  plot db(v(vout)/(v(inp)-v(inm))) title 'Two-Stage Op-Amp Open Loop Gain (dB)'
  plot phase(v(vout)/(v(inp)-v(inm)))*180/pi title 'Two-Stage Op-Amp Phase Response (deg)'
  * 3. Transient Pulse Response (Slew Rate)
  tran 0.1n 300n
  plot v(inp) v(vout) title 'Large-Signal Step Response & Slew Rate'
.endc
"}
