# IISc M.Tech Coursework & Academic Assignments Portfolio
**Author:** Anirudh Chaturvedi  
**Institution:** Indian Institute of Science (IISc), Bangalore  
**Department:** Electronic Systems Engineering (DESE)  
**GitHub:** [@Anicvedi](https://github.com/Anicvedi)  

---

## ?? Overview
This repository contains a curated portfolio of academic assignments, laboratory designs, hardware accelerators, RTL implementations, and synthesis/STA reports completed during M.Tech coursework at the Indian Institute of Science (IISc).

---

## ?? Coursework Index & Submission Timeline

### ?? 1. E0 297: Cryptographic Hardware Accelerators
*Focus: ASIC architecture, standard cell synthesis, static timing analysis, and cryptoprocessors.*

| # | Assignment Name | Topic / Highlights | Tech Stack | Submission Date |
|---|---|---|---|---|
| **DA1** | [AES-256 Iterative ASIC Accelerator](E0_297_Cryptographic_Accelerators/Assignment_1_AES256_ASIC_Accelerator/) | NIST FIPS 197 14-round AES, Canright vs LUT S-Box area/delay tradeoff, STA | Verilog, Yosys, OpenSTA, Nangate 45nm | **Sep 15, 2026** |
| **A2** | [SHA Hashing Accelerator Paper Review](E0_297_Cryptographic_Accelerators/Assignment_2_SHA_Accelerator_Paper_Review/) | Critique & presentation on 18Gbps 50mW multi-mode SHA accelerator in 45nm CMOS | LaTeX, Technical Review | **Sep 24, 2026** |
| **DA2** | [Keccak-f[1600] SHA-3 Accelerator](E0_297_Cryptographic_Accelerators/Assignment_2_Keccak_SHA3_Accelerator/) | 24-round permutation datapath with $\theta, \rho, \pi, \chi, \iota$ round functions | Verilog, Nangate 45nm, OpenSTA | **Oct 02, 2026** |
| **DA3** | [2048-bit Modular Exponentiation](E0_297_Cryptographic_Accelerators/Assignment_3_Modular_Exponentiation_2048bit/) | 2048-bit RSA coprocessor, square-and-multiply, Montgomery multiplication, FSMD | Verilog, Draw.io, LaTeX | **Nov 12, 2026** |

---

### ?? 2. Processor Systems Design (PSD)
*Focus: Computer architecture, microcontrollers, RISC-V pipelining, and FPGA hardware implementation.*

| # | Lab Exercise Name | Topic / Highlights | Target Platform | Date |
|---|---|---|---|---|
| **Lab 1** | [MC16 Multi-Cycle CISC Microcontroller](PSD_Processor_Systems_Design/Lab_1_MC16_Microcontroller/) | 16-bit processor, microsequencer, ALU, 7-segment display control | Digilent Basys-3 (Artix-7) | **Sep 17, 2026** |
| **Lab 2** | [Single-Cycle RV32I Processor](PSD_Processor_Systems_Design/Lab_2_Single_Cycle_RV32I/) | Full RV32I ISA core with restoring division unit | Vivado, Basys-3 FPGA | **Oct 09, 2026** |
| **Lab 3** | [5-Stage Pipelined RV32I Core](PSD_Processor_Systems_Design/Lab_3_Pipelined_RV32I/) | Classic IF/ID/EX/MEM/WB pipeline, data forwarding, hazard detection unit | Vivado, Basys-3 FPGA | **Nov 12, 2026** |
| **Lab** | [FPGA Radix-4 Booth Multiplier](PSD_Processor_Systems_Design/Lab_FPGA_Booth_Multiplier/) | High-speed carry-save multiplier with debouncer & counter | Artix-7 FPGA | **Oct 09, 2026** |
| **Lab** | [AXI4-Lite Bus Interface](PSD_Processor_Systems_Design/Lab_AXI4_Lite_Interface/) | Master/Slave memory-mapped peripheral bus protocol | Verilog RTL | **Oct 18, 2026** |
| **Lab** | [Pipelined Booth Multiplier with Display](PSD_Processor_Systems_Design/Lab_Pipelined_Radix4_Booth_Multiplier/) | Pipelined multiplication core driving Basys-3 7-segment displays | Verilog, Basys-3 | **Oct 18, 2026** |
| **Lab 5** | [FPGA CNN Hardware Accelerator for MNIST](PSD_Processor_Systems_Design/Lab_5_FPGA_CNN_Accelerator_MNIST/) | Custom hardware accelerator for CNN inference on handwritten digits | Artix-7 FPGA, BRAM, Verilog | **Oct 25, 2026** |

---

### ? 3. Digital VLSI Design (DVLSI)
*Focus: Circuit theory, delay models, cell sizing, SystemVerilog HDL, and static timing constraints.*

| # | Assignment Name | Topic / Highlights | Deliverable | Date |
|---|---|---|---|---|
| **A1** | [Combinational Logic Optimization](DVLSI_Digital_VLSI/Assignment_1_Combinational_Logic/) | Logical Effort, optimal stage sizing, gate delay minimization | Technical Report | **Sep 12, 2026** |
| **A2** | [Delay & Dynamic Power Analysis](DVLSI_Digital_VLSI/Assignment_2_Delay_and_Power_Analysis/) | RC tree delay, Elmore delay, buffer insertion, dynamic/leakage power | Technical Report | **Sep 30, 2026** |
| **Labs** | [SystemVerilog & STA Exercises](DVLSI_Digital_VLSI/Labs_SystemVerilog_STA/) | Half Adder, Full Adder, Counter, Carry Chain with SDC constraints | SystemVerilog, OpenSTA, Yosys | **Nov 06, 2026** |
| **A5** | [Logic Synthesis & Tech Mapping](DVLSI_Digital_VLSI/Assignment_5_Synthesis_and_Mapping/) | Technology mapping, area-delay tradeoff curves, standard cell mapping | Technical Report | **Nov 09, 2026** |
| **A6** | [Physical Design & Static Timing Analysis](DVLSI_Digital_VLSI/Assignment_6_Physical_Design_STA/) | Clock tree synthesis (CTS), setup/hold slack, violation fix strategies | Technical Report | **Nov 09, 2026** |

---

## ??? Tools & EDA Environment
- **Hardware Description:** Verilog-2001, SystemVerilog
- **Synthesis:** Yosys Open-Source Synthesis, Xilinx Vivado
- **Timing Analysis:** OpenSTA, Synopsys Design Constraints (SDC)
- **FPGA Platforms:** Digilent Basys-3 (AMD/Xilinx Artix-7 XC7A35T)
- **Cell Libraries:** NangateOpenCell 45nm Typical Corner
- **Simulation:** Icarus Verilog (iverilog), GTKWave, Vivado Simulator (xsim)
