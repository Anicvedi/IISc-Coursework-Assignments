v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
C {title.sym} 160 -30 0 0 {name=l1 author="Anirudh Chaturvedi" title="CMOS Differential Amplifier with Active Mirror Load (TSMC 180nm)"}
C {vdd.sym} 120 20 0 0 {name=l2 lab=VDD}
C {gnd.sym} 120 280 0 0 {name=l3 lab=GND}
C {ipin.sym} 80 140 0 0 {name=p1 lab=INP}
C {ipin.sym} 80 180 0 0 {name=p2 lab=INM}
C {opin.sym} 420 140 0 0 {name=p3 lab=OUT}
C {nmos4.sym} 200 140 0 0 {name=M1 m=1 w=10u l=0.18u model=nmos}
C {nmos4.sym} 200 180 0 0 {name=M2 m=1 w=10u l=0.18u model=nmos}
C {pmos4.sym} 200 60 0 0 {name=M3 m=1 w=20u l=0.5u model=pmos}
C {pmos4.sym} 280 60 0 0 {name=M4 m=1 w=20u l=0.5u model=pmos}
C {nmos4.sym} 240 240 0 0 {name=M5 m=1 w=20u l=0.5u model=nmos}
C {nmos4.sym} 120 180 0 0 {name=M8 m=1 w=20u l=0.5u model=nmos}
C {capa.sym} 360 180 0 0 {name=Cload m=1 value=1p}
C {code.sym} 540 40 0 0 {name=COMMANDS
only_toplevel=false
value=".include /home/anirudh/analog_vlsi/models/cmos_180nm.mod
Vdd vdd 0 DC 1.8
Vss vss 0 DC 0.0
Vinp inp 0 DC 0.9 AC 0.5
Vinm inm 0 DC 0.9 AC -0.5
Iref vdd nbias DC 40u

* Transistors
M8 nbias nbias vss vss nmos W=20u L=0.5u
M5 ntail nbias vss vss nmos W=20u L=0.5u
M1 out1 inp ntail vss nmos W=10u L=0.18u
M2 mirr inm ntail vss nmos W=10u L=0.18u
M3 mirr mirr vdd vdd pmos W=20u L=0.5u
M4 out1 mirr vdd vdd pmos W=20u L=0.5u
Cload out1 0 1p

.control
  set color0=white
  set color1=black
  * 1. DC Operating Point (Verify Saturation)
  op
  print v(out1) v(ntail)
  * 2. Differential AC Gain & Frequency Response
  ac dec 30 100 10G
  plot db(v(out1)/(v(inp)-v(inm))) title 'Differential Voltage Gain Avd (dB)'
  plot phase(v(out1)/(v(inp)-v(inm)))*180/pi title 'Differential Phase (deg)'
  * 3. DC Common-Mode Input Range (ICMR) Sweep
  dc Vinp 0.0 1.8 0.01
  plot v(out1) vs v(inp) title 'Input Common Mode Range (ICMR)'
.endc
"}
