@echo off
echo ==============================================================
echo Running 180nm CMOS Inverter DC VTC and Transient Simulation...
echo ==============================================================
wsl.exe -d Ubuntu -e bash -c "/home/anirudh/bin/ngspice -b /home/anirudh/analog_vlsi/circuits/cmos_inverter.sp && python3 /home/anirudh/analog_vlsi/plot_inverter.py"
echo.
echo Simulation complete! Opening results plot...
start "" "C:\Users\Anirudh\OneDrive - Indian Institute of Science\Desktop\CMOS_Inverter_Analog_Results.png"
ping 127.0.0.1 -n 3 > nul
