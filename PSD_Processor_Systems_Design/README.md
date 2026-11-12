# Processor Systems Design (PSD - Spring 2026)
**Instructor:** Prof. Kuruvilla Varghese  
**Department:** Electronic Systems Engineering (DESE), IISc Bangalore  
**Student:** Anirudh Chaturvedi (SR No: 25850)  

---

> [!NOTE]
> **MS Teams Submission Status:** In PSD, course evaluation is conducted via live laboratory demonstrations, in-class hardware evaluations, and viva rather than formal assignment uploads to MS Teams. The lab implementations below represent the complete working hardware designs verified on the Digilent Basys-3 FPGA board.

---

## ??? Laboratory FPGA Implementations:

### 1. [Lab 1: MC16 Multi-Cycle CISC Microcontroller](Lab_1_MC16_Microcontroller/)
- 16-bit CISC microprocessor architecture with microsequencer, ALU, internal register files, memory interface, and Basys-3 7-segment display driver.

### 2. [Lab 2: Single-Cycle RV32I Processor Core](Lab_2_Single_Cycle_RV32I/)
- Complete 32-bit RISC-V integer instruction set core with hardware coprocessor for restoring division algorithm.

### 3. [Lab 3: 5-Stage Pipelined RV32I Processor Core](Lab_3_Pipelined_RV32I/)
- Classic IF/ID/EX/MEM/WB pipeline architecture with integrated Data Forwarding Unit and Hazard Detection Unit resolving RAW data dependencies and control hazards.

### 4. [Peripheral & Arithmetic Subsystems](Lab_AXI4_Lite_Interface/)
- **AXI4-Lite Bus Interface:** Master and Slave memory-mapped communication controllers.
- **Pipelined Radix-4 Booth Multiplier:** High-speed multiplier with carry-save adders and hardware debouncing.
