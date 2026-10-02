# E0 297: Design Assignment 2 - Keccak-f[1600] SHA-3 Hardware Accelerator
**Course:** E0 297 - Cryptographic Hardware Accelerators, IISc  
**Author:** Anirudh Chaturvedi (SR No: 25850)  
**Submission Date:** October 2, 2026  

## Architecture & Algorithm
- **Primitive:** Keccak-f[1600] permutation core (24 rounds operating on 5x5 array of 64-bit lanes = 1600 bits state).
- **Round Steps:** Fully mapped combinational step functions:
  \theta \rightarrow \rho \rightarrow \pi \rightarrow \chi \rightarrow \iota
- **Synthesis:** Yosys on Nangate 45nm standard cells.
- **Timing:** Static Timing Analysis with SDC constraints evaluating clock frequency, setup/hold slacks, and silicon footprint.
