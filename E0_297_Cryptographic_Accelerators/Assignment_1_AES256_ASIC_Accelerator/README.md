# E0 297: Design Assignment 1 - AES-256 Iterative ASIC Accelerator
**Course:** E0 297 - Cryptographic Hardware Accelerators, IISc Bangalore  
**Author:** Anirudh Chaturvedi (SR No: 25850)  
**Submission Date:** September 15, 2026  

## Architecture Overview
- **Standard:** NIST FIPS 197 (AES-256 encryption, 14 rounds, 256-bit key, 128-bit block).
- **Architecture:** Iterative datapath completing 1 round per cycle with on-the-fly SubWord, RotWord, and Round Constant key scheduling.
- **S-Box Implementations Evaluated:**
  1. **LUT-based S-Box:** Direct combinational ROM lookup.
  2. **Canright S-Box:** Composite field arithmetic over ((2^2)^2)$ achieving high area efficiency and lower silicon area.
- **Synthesis & STA:** Yosys Open-Source Synthesis and OpenSTA on NangateOpenCell 45nm standard cell library.
