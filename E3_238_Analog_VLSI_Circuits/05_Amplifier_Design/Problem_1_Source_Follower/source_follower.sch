v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 80 50 80 20 {
lab=VDD}
N 80 110 80 150 {
lab=VB}
N 80 130 140 130 {
lab=VB}
N 140 130 140 260 {
lab=VB}
N 140 130 300 130 {
lab=VB}
N 300 130 300 260 {
lab=VB}
N 80 210 80 240 {
lab=VG_BOT}
N 80 240 180 240 {
lab=VG_BOT}
N 180 230 180 240 {
lab=VG_BOT}
N 120 240 120 360 {
lab=VG_BOT}
N 120 360 140 360 {
lab=VG_BOT}
N 120 240 280 240 {
lab=VG_BOT}
N 280 240 280 360 {
lab=VG_BOT}
N 280 360 300 360 {
lab=VG_BOT}
N 180 290 180 330 {
lab=N_MID1}
N 340 290 340 330 {
lab=N_MID2}
N 340 90 340 60 {
lab=VDD}
N 260 120 300 120 {
lab=IN}
N 340 150 340 230 {
lab=OUT}
N 340 180 420 180 {
lab=OUT}
N 420 180 420 210 {
lab=OUT}
N 420 180 480 180 {
lab=OUT}
N 480 180 480 210 {
lab=OUT}
N 180 390 180 430 {
lab=VSS}
N 340 390 340 430 {
lab=VSS}
N 180 430 340 430 {
lab=VSS}
N 340 430 420 430 {
lab=VSS}
N 420 430 480 430 {
lab=VSS}
N 420 270 420 430 {
lab=VSS}
N 480 270 480 430 {
lab=VSS}
N 180 260 200 260 {
lab=VSS}
N 200 260 200 430 {
lab=VSS}
N 180 360 200 360 {
lab=VSS}
N 340 260 360 260 {
lab=VSS}
N 360 260 360 430 {
lab=VSS}
N 340 360 360 360 {
lab=VSS}
N 340 120 360 120 {
lab=VSS}
N 360 120 360 260 {
lab=VSS}
C {title.sym} 160 -40 0 0 {name=l1 author="Analog VLSI Studio" title="Lab 5 Problem 1: Source Follower"}
C {vdd.sym} 80 20 0 0 {name=l2 lab=VDD}
C {vdd.sym} 340 60 0 0 {name=l3 lab=VDD}
C {gnd.sym} 340 430 0 0 {name=l4 lab=VSS}
C {isource.sym} 80 80 0 0 {name=Iref value=10u}
C {res.sym} 80 180 0 0 {name=R1 value=20k}
C {nmos4.sym} 160 260 0 0 {name=M4 m=1 w=2.0u l=0.5u model=nmos}
C {nmos4.sym} 160 360 0 0 {name=M3 m=1 w=2.0u l=0.5u model=nmos}
C {nmos4.sym} 320 120 0 0 {name=M5 m=1 w=1.92u l=0.5u model=nmos}
C {nmos4.sym} 320 260 0 0 {name=M2 m=1 w=2.0u l=0.5u model=nmos}
C {nmos4.sym} 320 360 0 0 {name=M1 m=1 w=2.0u l=0.5u model=nmos}
C {capa.sym} 420 240 0 0 {name=CL m=1 value=1p}
C {res.sym} 480 240 0 0 {name=RL value=1G}
C {ipin.sym} 260 120 0 0 {name=p1 lab=IN}
C {opin.sym} 420 180 0 0 {name=p2 lab=OUT}
C {opin.sym} 80 130 0 0 {name=p3 lab=VB}
C {opin.sym} 80 240 0 0 {name=p4 lab=VG_BOT}
C {code.sym} 560 100 0 0 {name=COMMANDS
only_toplevel=false
value=".include /home/anirudh/Analog_VLSI_Projects/models/cmos_180nm.mod
Vdd vdd 0 1.8
Vss vss 0 0
Vin in 0 1.25 AC 1.0

.control
  set color0=white
  set color1=black

  echo \\"\\"
  echo \\"===========================================================\\"
  echo \\"--- LAB 5 PROBLEM 1: DC OPERATING POINT & MEASUREMENTS ---\\"
  echo \\"===========================================================\\"
  op
  print v(IN) v(OUT) v(VB) v(VG_BOT)
  let V_error = v(OUT) - v(IN)
  let Vgs5 = v(IN) - v(OUT)
  print V_error Vgs5
  show m5 : gm gds gmbs id vgs vds vth
  show m2 : gm gds id vgs vds vth
  show m1 : gm gds id vgs vds vth

  echo \\"\\"
  echo \\"--- AC FREQUENCY RESPONSE ---\\"
  ac dec 30 1 10G
  meas ac gain_lf find vdb(OUT) at=1
  meas ac bw when vdb(OUT)=gain_lf-3 fall=1
  print gain_lf bw
  plot vdb(OUT) title 'Source Follower AC Gain (dB20) vs Frequency'
.endc
"}
