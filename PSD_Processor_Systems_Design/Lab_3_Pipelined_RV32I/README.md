# PSD Lab 3: 5-Stage Classic Pipelined RV32I Processor
**Course:** Processor Systems Design, IISc  
**Author:** Anirudh Chaturvedi (SR No: 25850)  
**Submission Date:** November 12, 2026  

## Pipeline Stages
1. **IF (Instruction Fetch):** PC generator and instruction memory interface.
2. **ID (Instruction Decode):** Register file read and immediate generation.
3. **EX (Execute):** ALU, branch target calculation, and forwarding multiplexers.
4. **MEM (Memory Access):** Data memory read/write.
5. **WB (Write Back):** Register write-back selector.

Includes complete Hazard Detection & Data Forwarding units to resolve RAW hazards and branch flushes.
