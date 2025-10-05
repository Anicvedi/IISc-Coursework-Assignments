v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 180 200 140 200 {}
N 220 170 320 170 {}
N 220 200 260 200 {}
N 220 230 260 230 {lab=NS}
N 300 270 260 270 {lab=NS}
N 260 230 260 270 {lab=NS}
N 300 330 300 360 {}
N 320 50 320 20 {}
N 320 110 320 170 {}
N 320 170 350 170 {}
C {title.sym} 180 -30 0 0 {name=l1 author="Analog VLSI Studio" title="Razavi Ch. 11: Source-Degenerated Common-Source Amplifier"}
C {vdd.sym} 320 20 0 0 {name=l2 lab=VDD}
C {gnd.sym} 260 200 0 0 {name=l3 lab=GND}
C {gnd.sym} 300 360 0 0 {name=l4 lab=GND}
C {ipin.sym} 140 200 0 0 {name=p1 lab=IN}
C {opin.sym} 350 170 0 0 {name=p2 lab=OUT}
C {nmos4.sym} 200 200 0 0 {name=MN1 m=1 w=10u l=0.5u model=nmos}
C {res.sym} 320 80 0 0 {name=RD value=20k}
C {res.sym} 300 300 0 0 {name=RS value=4.7k}
C {code.sym} 520 40 0 0 {name=COMMANDS
only_toplevel=false
value=".include /home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod
VDD VDD 0 DC 1.8
VIN IN 0 DC 0.8 AC 1
CL OUT GND 1p

.control
  op
  print v(OUT)
  ac dec 20 1 1G
  plot db(v(OUT))
  plot phase(v(OUT))*180/pi
.endc
"}
