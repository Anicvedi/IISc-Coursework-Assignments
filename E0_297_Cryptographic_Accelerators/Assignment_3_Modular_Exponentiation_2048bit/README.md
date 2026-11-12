# E0 297: Design Assignment 3 - 2048-bit Modular Exponentiation Accelerator
**Course:** E0 297 - Cryptographic Hardware Accelerators, IISc  
**Author:** Anirudh Chaturvedi (SR No: 25850)  
**Submission Date:** November 12, 2026  

## Summary
Hardware architecture for large-word (2048-bit) Modular Exponentiation ( = M^e \pmod{N}$) used in RSA public-key cryptosystems:
- **Core Algorithms:** Binary square-and-multiply / Montgomery multiplication engine.
- **FSM & Datapath:** Detailed state machines (FSM, FSMD, and ASM diagrams included).
- **Test Vectors:** Verified against 2048-bit test vectors (inp_2048.txt, exp_2048.txt, modexp_out_2048.txt).
- **Report:** Full technical report with architectural schematics and timing evaluations.
