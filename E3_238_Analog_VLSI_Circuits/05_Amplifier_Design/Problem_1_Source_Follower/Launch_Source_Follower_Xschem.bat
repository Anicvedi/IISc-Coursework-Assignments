@echo off
echo ===================================================================
echo Launching Xschem GUI: Lab 5 Problem 1 (Single Ended Source Follower)
echo ===================================================================
wsl.exe -d Ubuntu -e bash -c "cd /home/anirudh/Analog_VLSI_Projects/05_Amplifier_Design/Problem_1_Source_Follower && xschem source_follower.sch"
