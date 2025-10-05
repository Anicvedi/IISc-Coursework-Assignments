import numpy as np
import matplotlib.pyplot as plt
import os

vtc_path = "/home/anirudh/analog_vlsi/sim_results/inverter_vtc.dat"
tran_path = "/home/anirudh/analog_vlsi/sim_results/inverter_tran.dat"
output_png = "/mnt/c/Users/Anirudh/OneDrive - Indian Institute of Science/Desktop/CMOS_Inverter_Analog_Results.png"

# 1. Process VTC Data
# wrdata format: vin vout vin gain
vtc_raw = np.loadtxt(vtc_path)
v_in = vtc_raw[:, 0]
v_out = vtc_raw[:, 1]
gain = vtc_raw[:, 3]

# Find Trip Point VM (where v_out == v_in)
diff = np.abs(v_out - v_in)
vm_idx = np.argmin(diff)
v_m = v_in[vm_idx]

# Peak Small-Signal Analog Gain
peak_gain = np.min(gain)
peak_gain_vin = v_in[np.argmin(gain)]

# Find Noise Margin points (slope == -1)
# Transition region is around VM
slope_diff = np.abs(gain - (-1.0))
# Left of VM: VIL
left_mask = v_in < v_m
if np.any(left_mask):
    vil_idx = np.argmin(np.abs(gain[left_mask] - (-1.0)))
    v_il = v_in[left_mask][vil_idx]
    v_oh = v_out[left_mask][vil_idx]
else:
    v_il, v_oh = 0.6, 1.8

# Right of VM: VIH
right_mask = v_in > v_m
if np.any(right_mask):
    vih_idx = np.argmin(np.abs(gain[right_mask] - (-1.0)))
    v_ih = v_in[right_mask][vih_idx]
    v_ol = v_out[right_mask][vih_idx]
else:
    v_ih, v_ol = 1.0, 0.0

nm_l = v_il - 0.0
nm_h = 1.8 - v_ih

# 2. Process Transient Data
tran_raw = np.loadtxt(tran_path)
t_time = tran_raw[:, 0] * 1e9  # in ns
tr_vin = tran_raw[:, 1]
tr_vout = tran_raw[:, 3]

# Calculate Propagation Delays (around 1st pulse edge at ~1ns)
# Mid-rail threshold = 0.9V
v_mid = 0.9

# Rising edge of Vin (around t=1.0ns)
rising_vin = np.where((t_time >= 0.8) & (t_time <= 1.5) & (tr_vin >= v_mid))[0]
t_in_rise = t_time[rising_vin[0]] if len(rising_vin) > 0 else 1.0

falling_vout = np.where((t_time >= 0.8) & (t_time <= 1.5) & (tr_vout <= v_mid))[0]
t_out_fall = t_time[falling_vout[0]] if len(falling_vout) > 0 else 1.0
t_phl = (t_out_fall - t_in_rise) * 1e3  # in ps

# Falling edge of Vin (around t=6.0ns)
falling_vin = np.where((t_time >= 5.8) & (t_time <= 6.5) & (tr_vin <= v_mid))[0]
t_in_fall = t_time[falling_vin[0]] if len(falling_vin) > 0 else 6.0

rising_vout = np.where((t_time >= 5.8) & (t_time <= 6.5) & (tr_vout >= v_mid))[0]
t_out_rise = t_time[rising_vout[0]] if len(rising_vout) > 0 else 6.0
t_plh = (t_out_rise - t_in_fall) * 1e3  # in ps

t_pd = (t_phl + t_plh) / 2.0

# 3. Create High-Resolution Figure
fig, axes = plt.subplots(3, 1, figsize=(9.5, 11), gridspec_kw={'height_ratios': [1.2, 1, 1]})
fig.patch.set_facecolor('#ffffff')

# Panel 1: Voltage Transfer Characteristic (VTC)
ax1 = axes[0]
ax1.plot(v_in, v_out, color='#003366', linewidth=2.4, label='VTC: V_out vs V_in')
ax1.plot(v_in, v_in, color='#888888', linestyle='--', linewidth=1.2, label='Unity Slope (V_out = V_in)')
ax1.plot(v_m, v_m, marker='o', markersize=7, color='#d9534f', label=f'Trip Point V_M = {v_m:.3f} V')
ax1.axvline(v_il, color='#2ca02c', linestyle=':', label=f'V_IL = {v_il:.3f} V (NM_L = {nm_l:.3f} V)')
ax1.axvline(v_ih, color='#ff7f0e', linestyle=':', label=f'V_IH = {v_ih:.3f} V (NM_H = {nm_h:.3f} V)')
ax1.set_title('180nm CMOS Inverter (Wn=1µm, Wp=2.5µm) — DC Transfer Characteristics', fontsize=12, fontweight='bold', color='#002244')
ax1.set_xlabel('Input Voltage V_in (V)', fontsize=10, fontweight='bold')
ax1.set_ylabel('Output Voltage V_out (V)', fontsize=10, fontweight='bold')
ax1.grid(True, linestyle='--', alpha=0.5)
ax1.legend(loc='center right', framealpha=0.9, fontsize=9)

# Panel 2: Small-Signal Analog Gain dVout / dVin
ax2 = axes[1]
ax2.plot(v_in, gain, color='#800080', linewidth=2.0, label=f'Small-Signal Gain A_v = dV_out/dV_in (Peak = {peak_gain:.1f} V/V)')
ax2.axhline(-1, color='#d9534f', linestyle='--', alpha=0.7, label='Slope = -1 (Noise Margin Limits)')
ax2.axvline(v_m, color='#003366', linestyle=':', label=f'At V_M ({v_m:.2f} V)')
ax2.set_title('Small-Signal Analog Voltage Gain vs Input Bias', fontsize=11, fontweight='bold', color='#002244')
ax2.set_xlabel('Input Voltage V_in (V)', fontsize=10, fontweight='bold')
ax2.set_ylabel('Gain A_v (V/V)', fontsize=10, fontweight='bold')
ax2.grid(True, linestyle='--', alpha=0.5)
ax2.legend(loc='lower left', framealpha=0.9, fontsize=9)

# Panel 3: Transient Response & Delay
ax3 = axes[2]
ax3.plot(t_time, tr_vin, color='#2ca02c', linestyle='--', linewidth=1.8, label='V_in (100 MHz Clock Pulse)')
ax3.plot(t_time, tr_vout, color='#1f77b4', linewidth=2.2, label=f'V_out (t_pHL={t_phl:.1f}ps, t_pLH={t_plh:.1f}ps, t_pd={t_pd:.1f}ps)')
ax3.set_title('Transient Switching Response (C_load = 50 fF)', fontsize=11, fontweight='bold', color='#002244')
ax3.set_xlabel('Time (ns)', fontsize=10, fontweight='bold')
ax3.set_ylabel('Voltage (V)', fontsize=10, fontweight='bold')
ax3.set_xlim([0, 12])
ax3.grid(True, linestyle='--', alpha=0.5)
ax3.legend(loc='upper right', framealpha=0.9, fontsize=9)

local_png = "/home/anirudh/analog_vlsi/CMOS_Inverter_Analog_Results.png"
plt.tight_layout()
plt.savefig(local_png, dpi=200)

import shutil
try:
    shutil.copyfile(local_png, output_png)
except Exception as e:
    print(f"Note: Desktop image locked by viewer, saved to {local_png}: {e}")

print(f"=== CMOS INVERTER CHARACTERIZATION SUMMARY ===")
print(f"Trip Point (V_M):       {v_m:.3f} V  (Ideal mid-rail = 0.900 V)")
print(f"Peak Analog Gain (A_v): {peak_gain:.2f} V/V  ({20*np.log10(np.abs(peak_gain)):.2f} dB)")
print(f"V_IL:                   {v_il:.3f} V")
print(f"V_IH:                   {v_ih:.3f} V")
print(f"Noise Margin Low (NML): {nm_l:.3f} V")
print(f"Noise Margin High (NMH):{nm_h:.3f} V")
print(f"Propagation Delay t_pHL:{t_phl:.1f} ps")
print(f"Propagation Delay t_pLH:{t_plh:.1f} ps")
print(f"Average Delay (t_pd):   {t_pd:.1f} ps")
print(f"Plot updated at: {local_png}")
