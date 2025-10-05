v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 340 240 300 240 {}
N 380 210 460 210 {}
N 460 150 460 210 {}
N 380 150 460 150 {}
N 380 240 420 240 {}
N 380 270 420 270 {}
N 420 240 420 270 {}
N 380 90 420 90 {}
N 380 120 420 120 {}
N 420 90 420 120 {}
N 220 90 260 90 {}
N 220 120 260 120 {}
N 260 90 260 120 {}
N 260 70 260 90 {}
N 380 90 420 90 {}
N 380 120 420 120 {}
N 420 90 420 120 {}
N 420 70 420 90 {}
N 220 150 300 150 {lab=BIAS}
N 300 150 300 60 {lab=BIAS}
N 180 120 140 120 {lab=BIAS}
N 140 120 140 60 {lab=BIAS}
N 140 60 300 60 {lab=BIAS}
N 300 60 320 60 {lab=BIAS}
N 320 60 320 120 {lab=BIAS}
N 320 120 340 120 {lab=BIAS}
N 80 170 80 60 {lab=BIAS}
N 80 60 140 60 {lab=BIAS}
N 80 230 80 260 {}
C {title.sym} 180 -30 0 0 {name=l1 author="Analog VLSI Studio" title="Razavi Ch. 10: Common-Source Amplifier with Current-Source Load"}
C {vdd.sym} 420 70 0 0 {name=l2 lab=VDD}
C {vdd.sym} 260 70 0 0 {name=l3 lab=VDD}
C {gnd.sym} 420 270 0 0 {name=l4 lab=GND}
C {gnd.sym} 80 260 0 0 {name=l5 lab=GND}
C {ipin.sym} 300 240 0 0 {name=p1 lab=IN}
C {opin.sym} 460 210 0 0 {name=p2 lab=OUT}
C {pmos4.sym} 200 120 0 0 {name=MPREF m=1 w=20u l=0.5u model=pmos}
C {pmos4.sym} 360 120 0 0 {name=MPLOAD m=1 w=20u l=0.5u model=pmos}
C {nmos4.sym} 360 240 0 0 {name=MN1 m=1 w=10u l=0.5u model=nmos}
C {isource.sym} 80 200 0 0 {name=IREF value=20u}
C {code.sym} 520 40 0 0 {name=COMMANDS
only_toplevel=false
value=".include /home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod
VDD VDD 0 DC 1.8
VIN IN 0 DC 0.55 AC 1
CL OUT GND 1p

.control
  dc VIN 0.5 0.65 0.01
  plot v(OUT) vs v(IN)
  alter VIN dc=0.55
  op
  print v(OUT)
  ac dec 20 1 1G
  plot db(v(OUT))
  plot phase(v(OUT))*180/pi
.endc
"}
