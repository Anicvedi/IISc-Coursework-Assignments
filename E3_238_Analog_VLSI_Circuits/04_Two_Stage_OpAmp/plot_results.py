import numpy as np
import matplotlib.pyplot as plt
import os

ac_data_path = "/home/anirudh/analog_vlsi/sim_results/opamp_ac.dat"
tran_data_path = "/home/anirudh/analog_vlsi/sim_results/opamp_tran.dat"
output_png = "/mnt/c/Users/Anirudh/OneDrive - Indian Institute of Science/Desktop/Analog_VLSI_OpAmp_Results.png"

# Load AC data
# Format in wrdata: freq gain_db freq phase_deg
ac_raw = np.loadtxt(ac_data_path)
freq = ac_raw[:, 0]
gain_db = ac_raw[:, 1]
phase_deg = ac_raw[:, 3]

# Compute key metrics
dc_gain = gain_db[0]
f_3db_idx = np.where(gain_db <= dc_gain - 3.0)[0]
f_3db = freq[f_3db_idx[0]] if len(f_3db_idx) > 0 else 0

# Unity Gain Frequency (0 dB crossing)
ugf_idx = np.where(gain_db <= 0.0)[0]
if len(ugf_idx) > 0:
    ugf = freq[ugf_idx[0]]
    phase_at_ugf = phase_deg[ugf_idx[0]]
    pm = 180.0 + phase_at_ugf
else:
    ugf = 0
    pm = 0

# Load Transient data
# Format: time vinp time vout
tran_raw = np.loadtxt(tran_data_path)
t_time = tran_raw[:, 0] * 1e9  # in ns
v_inp = tran_raw[:, 1]
v_out = tran_raw[:, 3]

# Create Figure
fig, axes = plt.subplots(3, 1, figsize=(10, 11), gridspec_kw={'height_ratios': [1.2, 1, 1]})
fig.patch.set_facecolor('#ffffff')

# Subplot 1: Gain Bode Plot
ax1 = axes[0]
ax1.semilogx(freq, gain_db, color='#004080', linewidth=2.2, label=f'Gain (A_v) [DC Gain = {dc_gain:.1f} dB]')
ax1.axhline(0, color='#888888', linestyle='--', alpha=0.7)
if ugf > 0:
    ax1.axvline(ugf, color='#d9534f', linestyle=':', label=f'UGF = {ugf/1e6:.1f} MHz')
ax1.set_title('Two-Stage CMOS Op-Amp (180nm) — Open-Loop Frequency Response', fontsize=12, fontweight='bold', color='#002b49')
ax1.set_ylabel('Magnitude (dB)', fontsize=10, fontweight='bold')
ax1.grid(True, which='both', linestyle='--', alpha=0.5)
ax1.legend(loc='lower left', framealpha=0.9)

# Subplot 2: Phase Bode Plot
ax2 = axes[1]
ax2.semilogx(freq, phase_deg, color='#d9534f', linewidth=2.0, label=f'Phase Margin (PM) = {pm:.1f}°')
ax2.axhline(-180, color='#333333', linestyle='--', alpha=0.5, label='-180° Stability Limit')
if ugf > 0:
    ax2.axvline(ugf, color='#d9534f', linestyle=':')
ax2.set_xlabel('Frequency (Hz)', fontsize=10, fontweight='bold')
ax2.set_ylabel('Phase (degrees)', fontsize=10, fontweight='bold')
ax2.grid(True, which='both', linestyle='--', alpha=0.5)
ax2.legend(loc='upper right', framealpha=0.9)

# Subplot 3: Transient Response
ax3 = axes[2]
ax3.plot(t_time, v_inp, color='#2ca02c', linestyle='--', label='V_in+ (Step Input)')
ax3.plot(t_time, v_out, color='#1f77b4', linewidth=2.0, label='V_out (Amplified Response)')
ax3.set_title('Large-Signal Transient Step Response (Slew Rate & Settling)', fontsize=11, fontweight='bold', color='#002b49')
ax3.set_xlabel('Time (ns)', fontsize=10, fontweight='bold')
ax3.set_ylabel('Voltage (V)', fontsize=10, fontweight='bold')
ax3.grid(True, linestyle='--', alpha=0.5)
ax3.legend(loc='center right', framealpha=0.9)

plt.tight_layout()
plt.savefig(output_png, dpi=200)
print(f"Metrics: DC Gain = {dc_gain:.2f} dB, 3dB BW = {f_3db/1e3:.2f} kHz, UGF = {ugf/1e6:.2f} MHz, PM = {pm:.2f} deg")
print(f"Saved plot image to: {output_png}")
