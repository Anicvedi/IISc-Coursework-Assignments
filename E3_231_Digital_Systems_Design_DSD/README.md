# E3 231: Digital Systems Design with FPGAs (DSD - Spring 2026)
**Instructor:** Prof. Debayan Das  
**Department:** Electronic Systems Engineering (DESE), IISc Bangalore  
**Student:** Anirudh Chaturvedi (SR No: 25850)  

*(Note: DSD is a distinct course focused on advanced FPGA architecture, high-level synthesis, and specialized accelerators, distinct from the Processor Systems Design course).*

---

## ?? Course Deliverables & MS Teams Submissions:

### 1. Lab Exercise 1: FPGA Design Flow & Timing Constraints
- **File:** [E3_231_DSD_Lab1_FPGA_Report.pdf](E3_231_DSD_Lab1_FPGA_Report.pdf)
- **Topics:** Digilent Basys-3 (Artix-7 XC7A35T) architecture, clock management tiles (MMCM/PLL), synchronous reset methodologies, I/O pin mapping, setup/hold slack closure.

### 2. Major Course Project: FPGA Hardware CNN Accelerator for MNIST Digit Recognition
- **Folder:** [DSD_FPGA_CNN_Accelerator_MNIST](DSD_FPGA_CNN_Accelerator_MNIST/)
- **Deliverables:** Full RTL implementation, testbenches, BRAM initialization coefficient files (.coe), slide presentation (CNN_Hardware_Accelerator.pptx), and technical report (Hardware_Accelerator_MNIST_Project.pdf).
- **Architecture:** Custom streaming convolution engine with integrated ReLU activation (ops_convrelu.v), max-pooling reduction unit (ops_maxpool.v), and fully-connected layer classifier (ops_classifier.v) operating with on-chip dual-port BRAMs.
