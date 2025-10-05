v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 180 250 140 250 {}
N 220 220 220 180 {lab=N1}
N 220 120 320 120 {}
N 180 150 140 150 {}
N 220 150 260 150 {}
N 220 250 260 250 {}
N 220 280 260 280 {}
N 320 30 320 0 {}
N 320 90 320 120 {}
C {title.sym} 180 -40 0 0 {name=l1 author="Analog VLSI Studio" title="Razavi Ch. 13: NMOS Cascode Amplifier"}
C {vdd.sym} 320 0 0 0 {name=l2 lab=VDD}
C {gnd.sym} 260 150 0 0 {name=l3 lab=GND}
C {gnd.sym} 260 250 0 0 {name=l4 lab=GND}
C {gnd.sym} 260 280 0 0 {name=l5 lab=GND}
C {ipin.sym} 140 250 0 0 {name=p1 lab=IN}
C {ipin.sym} 140 150 0 0 {name=p2 lab=VCAS}
C {opin.sym} 320 120 0 0 {name=p3 lab=OUT}
C {nmos4.sym} 200 250 0 0 {name=MN1 m=1 w=10u l=0.5u model=nmos}
C {nmos4.sym} 200 150 0 0 {name=MN2 m=1 w=10u l=0.5u model=nmos}
C {res.sym} 320 60 0 0 {name=RD value=20k}
C {code.sym} 520 40 0 0 {name=COMMANDS
only_toplevel=false
value=".include /home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod
VDD VDD 0 DC 1.8
VIN IN 0 DC 0.57 AC 1
VCAS VCAS 0 DC 1.0
CL OUT GND 1p

.control
  op
  print v(OUT)
  ac dec 20 1 1G
  plot db(v(OUT))
  plot phase(v(OUT))*180/pi
.endc
"}
