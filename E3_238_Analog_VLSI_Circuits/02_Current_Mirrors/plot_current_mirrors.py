#!/usr/bin/env python3
"""
CMOS Current Mirrors Analysis & Plotter
Generates publication-quality plots comparing Basic (1:1), Ratioed (1:2),
and Cascode Current Mirrors in TSMC 180nm CMOS technology.
"""

import os
import matplotlib
matplotlib.use('Agg')
import numpy as np
import matplotlib.pyplot as plt

DAT_PATH = "/home/anirudh/Analog_VLSI_Projects/sim_results/current_mirrors_dc.dat"
OUT_PNG = "/home/anirudh/Analog_VLSI_Projects/02_Current_Mirrors/Current_Mirrors_Results.png"

def main():
    if not os.path.exists(DAT_PATH):
        print(f"Error: Data file {DAT_PATH} not found.")
        return

    data = np.loadtxt(DAT_PATH)
    # wrdata exports pairs of (x, y) for each vector:
    # col 0: Vds, col 1: I_basic
    # col 2: Vds, col 3: I_ratio
    # col 4: Vds, col 5: I_casc
    vds = data[:, 0]
    i_basic_uA = data[:, 1] * 1e6
    i_ratio_uA = data[:, 3] * 1e6
    i_casc_uA = data[:, 5] * 1e6

    # Calculate small-signal output resistance: rout = dVds / dIout
    # Avoid division by zero by using numerical differentiation
    dvds = np.gradient(vds)
    rout_basic_kohm = (dvds / np.gradient(data[:, 1])) / 1e3
    rout_casc_Mohm = (dvds / np.gradient(data[:, 5])) / 1e6

    plt.style.use('seaborn-v0_8-whitegrid' if 'seaborn-v0_8-whitegrid' in plt.style.available else 'default')
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5), dpi=150)

    # Subplot 1: Iout vs Vds
    ax1.plot(vds, i_basic_uA, label='Basic Mirror 1:1 ($W=10\\mu m$)', color='#1f77b4', lw=2.2)
    ax1.plot(vds, i_ratio_uA, label='Ratioed Mirror 1:2 ($W=20\\mu m$)', color='#ff7f0e', lw=2.2)
    ax1.plot(vds, i_casc_uA, label='Cascode Mirror ($W=10\\mu m$)', color='#2ca02c', lw=2.4)
    ax1.axhline(50, color='#888888', linestyle='--', lw=1.2, label='Ideal $I_{ref} = 50\\mu A$')
    ax1.axhline(100, color='#aaaaaa', linestyle=':', lw=1.2, label='Ideal $2\\times I_{ref} = 100\\mu A$')
    
    ax1.set_title('Current Mirror Output Characteristics ($I_{out}$ vs $V_{DS}$)', fontsize=13, fontweight='bold', pad=10)
    ax1.set_xlabel('Output Voltage $V_{DS}$ (V)', fontsize=11)
    ax1.set_ylabel('Output Current $I_{out}$ ($\\mu$A)', fontsize=11)
    ax1.set_xlim(0, 1.8)
    ax1.set_ylim(0, 130)
    ax1.legend(loc='lower right', framealpha=0.95, fontsize=9.5)
    ax1.grid(True, linestyle='--', alpha=0.6)

    # Subplot 2: Output Resistance (rout)
    # Filter valid saturation region: Vds >= 0.4V
    sat_mask = vds >= 0.4
    ax2.plot(vds[sat_mask], rout_basic_kohm[sat_mask], label='Basic Mirror $r_{out}$ (k$\\Omega$)', color='#1f77b4', lw=2.2)
    ax2_twin = ax2.twinx()
    ax2_twin.plot(vds[sat_mask], rout_casc_Mohm[sat_mask], label='Cascode Mirror $r_{out}$ (M$\\Omega$)', color='#2ca02c', lw=2.4)

    ax2.set_title('Small-Signal Output Resistance $r_{out} = dV_{DS}/dI_{out}$', fontsize=13, fontweight='bold', pad=10)
    ax2.set_xlabel('Output Voltage $V_{DS}$ (V)', fontsize=11)
    ax2.set_ylabel('Basic Mirror $r_{out}$ (k$\\Omega$)', color='#1f77b4', fontsize=11)
    ax2_twin.set_ylabel('Cascode Mirror $r_{out}$ (M$\\Omega$)', color='#2ca02c', fontsize=11)
    ax2.tick_params(axis='y', labelcolor='#1f77b4')
    ax2_twin.tick_params(axis='y', labelcolor='#2ca02c')
    ax2.set_xlim(0.4, 1.8)
    ax2.grid(True, linestyle='--', alpha=0.6)

    plt.suptitle('IISc Analog VLSI - 180nm CMOS Current Mirror Characterization', fontsize=14, fontweight='bold', y=0.98)
    plt.tight_layout()
    plt.savefig(OUT_PNG, bbox_inches='tight')
    print(f"Plot saved successfully to: {OUT_PNG}")

if __name__ == '__main__':
    main()
