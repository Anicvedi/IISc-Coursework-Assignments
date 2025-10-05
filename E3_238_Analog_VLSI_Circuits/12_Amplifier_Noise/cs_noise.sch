v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 180 200 140 200 {
lab=IN}
N 220 170 280 170 {
lab=OUT}
N 220 200 250 200 {
lab=GND}
N 220 230 250 230 {
lab=GND}
N 250 200 250 230 {
lab=GND}
N 320 50 320 20 {
lab=VDD}
N 320 110 320 170 {
lab=OUT}
N 280 170 320 170 {
lab=OUT}
N 320 170 350 170 {
lab=OUT}
C {title.sym} 180 -30 0 0 {name=l1 author="Analog VLSI Studio" title="Razavi Ch. 17: Common-Source Amplifier Noise"}
C {vdd.sym} 320 20 0 0 {name=l2 lab=VDD}
C {gnd.sym} 250 230 0 0 {name=l3 lab=GND}
C {ipin.sym} 140 200 0 0 {name=p1 lab=IN}
C {opin.sym} 350 170 0 0 {name=p2 lab=OUT}
C {nmos4.sym} 200 200 0 0 {name=MN1 m=1 w=10u l=0.5u model=nmos}
C {res.sym} 320 80 0 0 {name=RD value=20k}
C {code.sym} 520 40 0 0 {name=COMMANDS
only_toplevel=false
value=".include /home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod
VDD VDD 0 DC 1.8
VIN IN 0 DC 0.57 AC 1
CL OUT GND 1p

.control
  op
  noise v(OUT) VIN dec 10 10 100Meg
  plot onoise_spectrum
  plot inoise_spectrum
.endc
"}
