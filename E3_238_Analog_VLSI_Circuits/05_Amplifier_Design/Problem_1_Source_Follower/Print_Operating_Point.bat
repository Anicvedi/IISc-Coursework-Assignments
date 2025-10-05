@echo off
echo ===================================================================
echo Lab 5 Problem 1: Inspecting DC Operating Point & AC Measurements
echo ===================================================================
wsl.exe -d Ubuntu -e bash -c "cd /home/anirudh/Analog_VLSI_Projects/05_Amplifier_Design/Problem_1_Source_Follower && ngspice -b ~/.xschem/simulations/source_follower.spice"
echo.
pause
