v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 180 220 140 220 {}
N 220 190 300 190 {}
N 300 130 300 190 {}
N 220 130 300 130 {}
N 180 100 140 100 {}
N 140 100 140 130 {}
N 140 130 220 130 {}
N 220 70 260 70 {}
N 220 100 260 100 {}
N 260 70 260 100 {}
N 260 50 260 70 {}
N 220 220 260 220 {}
N 220 250 260 250 {}
N 260 220 260 250 {}
C {title.sym} 180 -30 0 0 {name=l1 author="Analog VLSI Studio" title="Razavi Ch. 9: Common-Source Amplifier with Diode-Connected Load"}
C {vdd.sym} 260 50 0 0 {name=l2 lab=VDD}
C {gnd.sym} 260 250 0 0 {name=l3 lab=GND}
C {ipin.sym} 140 220 0 0 {name=p1 lab=IN}
C {opin.sym} 300 190 0 0 {name=p2 lab=OUT}
C {pmos4.sym} 200 100 0 0 {name=MP1 m=1 w=20u l=0.5u model=pmos}
C {nmos4.sym} 200 220 0 0 {name=MN1 m=1 w=10u l=0.5u model=nmos}
C {code.sym} 500 40 0 0 {name=COMMANDS
only_toplevel=false
value=".include /home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod
VDD VDD 0 DC 1.8
VIN IN 0 DC 0.9 AC 1
CL OUT 0 1p

.control
  op
  print v(OUT)
  ac dec 20 1 1G
  plot db(v(OUT))
  plot phase(v(OUT))*180/pi
.endc
"}
