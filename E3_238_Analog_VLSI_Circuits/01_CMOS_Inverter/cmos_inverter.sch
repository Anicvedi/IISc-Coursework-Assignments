v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 100 140 150 140 {
lab=IN}
N 150 80 150 200 {
lab=IN}
N 150 80 180 80 {
lab=IN}
N 150 200 180 200 {
lab=IN}
N 220 110 220 170 {
lab=OUT}
N 220 140 280 140 {
lab=OUT}
N 220 20 220 50 {
lab=VDD}
N 220 80 240 80 {
lab=VDD}
N 240 50 240 80 {
lab=VDD}
N 220 50 240 50 {
lab=VDD}
N 220 230 220 260 {
lab=GND}
N 220 200 240 200 {
lab=GND}
N 240 200 240 230 {
lab=GND}
N 220 230 240 230 {
lab=GND}
C {title.sym} 160 -30 0 0 {name=l1 author="Anirudh Chaturvedi" title="180nm CMOS Inverter"}
C {vdd.sym} 220 20 0 0 {name=l2 lab=VDD}
C {gnd.sym} 220 260 0 0 {name=l3 lab=GND}
C {pmos4.sym} 200 80 0 0 {name=Mp m=1 w=2.5u l=0.18u model=pmos}
C {nmos4.sym} 200 200 0 0 {name=Mn m=1 w=1.0u l=0.18u model=nmos}
C {ipin.sym} 100 140 0 0 {name=p1 lab=IN}
C {opin.sym} 280 140 0 0 {name=p2 lab=OUT}
C {code.sym} 360 40 0 0 {name=COMMANDS
only_toplevel=false
value=".include /home/anirudh/analog_vlsi/models/cmos_180nm.mod
Vdd VDD 0 1.8
Vin IN 0 0 PULSE(0 1.8 1n 50p 50p 5n 10n)
Cload OUT 0 50f

.control
  set color0=white
  set color1=black

  * 1. DC Sweep Analysis & VTC Plot
  dc Vin 0 1.8 0.005
  plot v(OUT) vs v(IN) title '180nm CMOS Inverter DC VTC'

  * 2. Transient Analysis & Switching Plot
  tran 10p 20n
  plot v(IN) v(OUT) title '180nm CMOS Inverter Transient Switching'
.endc
"}
