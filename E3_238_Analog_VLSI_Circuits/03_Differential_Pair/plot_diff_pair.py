import numpy as np
import matplotlib.pyplot as plt

dc_path = "/home/anirudh/analog_vlsi/sim_results/diff_pair_dc.dat"
ac_path = "/home/anirudh/analog_vlsi/sim_results/diff_pair_ac.dat"
output_png = "/mnt/c/Users/Anirudh/OneDrive - Indian Institute of Science/Desktop/CMOS_Diff_Pair_Results.png"

# 1. Process DC Data
# wrdata format: vinp vout1 vinp gain
dc_raw = np.loadtxt(dc_path)
v_inp = dc_raw[:, 0]
v_out = dc_raw[:, 1]
dc_gain = dc_raw[:, 3]
v_id = (v_inp - 0.9) * 1e3  # Differential input in mV

peak_dc_gain = np.max(np.abs(dc_gain))

# 2. Process AC Data
# wrdata format: freq gain_db freq phase_deg
ac_raw = np.loadtxt(ac_path)
freq = ac_raw[:, 0]
gain_db = ac_raw[:, 1]
phase_deg = ac_raw[:, 3]

ad_db = gain_db[0]
ad_linear = 10**(ad_db / 20.0)

# 3dB Bandwidth
bw_3db_idx = np.where(gain_db <= ad_db - 3.0)[0]
f_3db = freq[bw_3db_idx[0]] if len(bw_3db_idx) > 0 else 0

# Unity Gain Frequency
ugf_idx = np.where(gain_db <= 0.0)[0]
ugf = freq[ugf_idx[0]] if len(ugf_idx) > 0 else 0

# 3. Create Plots
fig, axes = plt.subplots(3, 1, figsize=(9.5, 11), gridspec_kw={'height_ratios': [1.1, 1.2, 1]})
fig.patch.set_facecolor('#ffffff')

# Panel 1: DC Transfer Curve
ax1 = axes[0]
ax1.plot(v_id, v_out, color='#004080', linewidth=2.3, label='V_out vs V_id (V_in+ - V_in-)')
ax1.axvline(0, color='#888888', linestyle='--', alpha=0.7)
ax1.axhline(1.144, color='#d9534f', linestyle=':', label='Quiescent Output = 1.144 V')
ax1.set_title('CMOS Differential Pair (180nm) — DC Transfer Characteristic', fontsize=12, fontweight='bold', color='#002244')
ax1.set_xlabel('Differential Input V_id (mV)', fontsize=10, fontweight='bold')
ax1.set_ylabel('Output Voltage V_out (V)', fontsize=10, fontweight='bold')
ax1.grid(True, linestyle='--', alpha=0.5)
ax1.legend(loc='lower right', framealpha=0.9, fontsize=9)

# Panel 2: AC Frequency Response (Gain in dB)
ax2 = axes[1]
ax2.semilogx(freq, gain_db, color='#006699', linewidth=2.2, label=f'Differential Gain A_d [DC = {ad_db:.1f} dB ({ad_linear:.1f} V/V)]')
ax2.axhline(0, color='#888888', linestyle='--', alpha=0.7)
if f_3db > 0:
    ax2.axvline(f_3db, color='#ff7f0e', linestyle=':', label=f'3-dB Bandwidth = {f_3db/1e6:.2f} MHz')
if ugf > 0:
    ax2.axvline(ugf, color='#d9534f', linestyle=':', label=f'UGF = {ugf/1e6:.1f} MHz')
ax2.set_title('Differential AC Frequency Response (C_load = 1 pF)', fontsize=11, fontweight='bold', color='#002244')
ax2.set_ylabel('Magnitude (dB)', fontsize=10, fontweight='bold')
ax2.grid(True, which='both', linestyle='--', alpha=0.5)
ax2.legend(loc='lower left', framealpha=0.9, fontsize=9)

# Panel 3: AC Phase Response
ax3 = axes[2]
ax3.semilogx(freq, phase_deg, color='#d9534f', linewidth=2.0, label='Phase Angle (degrees)')
ax3.set_xlabel('Frequency (Hz)', fontsize=10, fontweight='bold')
ax3.set_ylabel('Phase (degrees)', fontsize=10, fontweight='bold')
ax3.grid(True, which='both', linestyle='--', alpha=0.5)
ax3.legend(loc='upper right', framealpha=0.9, fontsize=9)

plt.tight_layout()
plt.savefig(output_png, dpi=200)

print(f"=== DIFFERENTIAL PAIR PERFORMANCE SUMMARY ===")
print(f"DC Differential Gain (A_d): {ad_db:.2f} dB  ({ad_linear:.2f} V/V)")
print(f"3-dB Bandwidth (f_3dB):     {f_3db/1e3:.2f} kHz  ({f_3db/1e6:.3f} MHz)")
print(f"Gain-Bandwidth (GBW/UGF):   {ugf/1e6:.2f} MHz")
print(f"Quiescent Output Voltage:   1.144 V (Symmetric Bias)")
print(f"Saved plot image to: {output_png}")
