# PSD Lab 3: screenshot checklist (Vivado GUI)

Handout asks you to submit: datapath block schematic, controller state diagram,
Verilog code, constraints, timing report, utilization, timing simulation
waveforms (stalls, hazard detection, forwarding, cache fill, cache misses),
C code and assembly code.

## 0. Build the project (once)
```
C:\AMDDesignTools\2026.1\Vivado\bin\vivado.bat -mode batch -source scripts/build_lab3.tcl
```
Then open `vivado_proj/psd_lab3.xpr` in the Vivado GUI. Save every screenshot
into `doc/figures/` with the file name shown below (PNG).

## 1. Things you draw / already have (not Vivado screenshots)
| File name | What | Where it comes from |
|---|---|---|
| `fig_datapath.png` | Datapath block schematic | Draw it yourself first (handout says "design the datapath first"); the TikZ drawing in `doc/Lab3_Report.tex` can be exported |
| `fig_icache_fsm.png` | I-cache miss/fill FSM | Same, from the report |
| C and assembly code | `memory/restoring_div.c`, `.asm` | Paste into the report appendix |

## 2. Vivado GUI screenshots
| # | File name | How to get it |
|---|---|---|
| 1 | `fig_rtl_schematic.png` | Flow Navigator → RTL Analysis → **Open Elaborated Design** → **Schematic**. Take the top level, then one expanded block (the CPU) |
| 2 | `fig_synth_schematic.png` | Synthesis → Open Synthesized Design → Schematic (optional) |
| 3 | `fig_util.png` | Implementation → Open Implemented Design → **Report Utilization**. Screenshot the summary table (LUTs, FFs, BRAM, DSP) |
| 4 | `fig_timing_summary.png` | Implementation → **Report Timing Summary**. Capture WNS, TNS, WHS, and "All user specified timing constraints are met / not met" |
| 5 | `fig_critical_path.png` | In Timing Summary → Intra-Clock Paths → Setup → double-click the top path. Capture the data path and source/destination |
| 6 | `fig_power.png` | Implementation → **Report Power** (optional but common) |
| 7 | `fig_wave_behav.png` | Simulation → **Run Behavioral Simulation** (set top = `rv32i_pipeline_tb`). Add `clk`, `pc`, `icache_stall_out`, `load_use_stall_out`, `ex_redirect_out`, `fwd_active_out` to the waveform. Zoom so the whole run fits |
| 8 | `fig_wave_postroute_full.png` | Simulation → **Run Post-Implementation Timing Simulation** (top = `basys3_top_tb`). Zoom to fit: `clk`, `btnC`, `sw`, `led` |
| 9 | `fig_wave_stall.png` | Same post-route run, zoom on one **I-cache miss**: show the stall asserted for 5 cycles and the PC frozen |
| 10 | `fig_wave_loaduse.png` | Zoom on a **load-use stall** (1 cycle) with the bubble in ID/EX |
| 11 | `fig_wave_forward.png` | Zoom on a **forwarding** event (`fwd_a`/`fwd_b` non-zero) |
| 12 | `fig_wave_branch.png` | Zoom on a **branch/JAL flush** (`flush_if_id`, `flush_id_ex`) |
| 13 | `fig_wave_result.png` | End of run: show `sw=00` → `led = 14` (quotient) and `sw=01` → `led = 2` (remainder) |

Notes for the waveforms:
* After implementation, internal signal names can change or disappear. If a
  signal is missing in the post-route run, take the stall / forwarding closeups
  from the **behavioral** run and say so in the caption. Show the post-route
  run for the final result and the timing check.
* In the waveform window set the radix to unsigned decimal or hex so values
  are readable, and use the **Add marker** tool to label time stamps.
* Use a light background (Window → Waveform Settings) so prints are readable.

## 3. Demonstration on the board
Program the Basys 3 and take one photo per switch setting:
`sw=00` shows the quotient (14) and `sw=01` shows the remainder (2) on the LEDs.

## 4. Before you submit
* Check the timing summary. Last time WNS was -0.596 ns at 100 MHz, so the
  design did not meet the 10 ns constraint. State your achieved Fmax, or
  relax the clock to e.g. 12 ns (create_clock -period 12) and re-run so the
  report says all constraints are met. Either is fine if the report says it
  honestly.
* Make sure every figure in the report has a caption that says what event it
  shows and at what time stamp.
