# ==============================================================================
# E3: 245 Processor System Design - IISc DESE
# Laboratory Exercise 2: 32-bit Single Cycle RISC-V Processor (RV32I)
# Assembly Program: 16-bit Unsigned Restoring Division Algorithm
# ==============================================================================

.org 0x0000

main:
    # Initialize Stack Pointer (top of memory space, word 448 = 0x700)
    li   sp, 0x700

    # Test Vector: Dividend = 100 (0x0064), Divisor = 7 (0x0007)
    li   a0, 100          # a0 = Dividend
    li   a1, 7            # a1 = Divisor

    # Call restoring_divide function (Passes a0, a1; returns a0=Quot, a1=Rem)
    jal  ra, restoring_divide

    # Save results to Data Memory:
    # Address 0x200 (Word 128) = Quotient  (Expected: 14 = 0x000E)
    # Address 0x204 (Word 129) = Remainder (Expected: 2  = 0x0002)
    li   t0, 0x200
    sw   a0, 0(t0)        # MEM[0x200] = Quotient
    sw   a1, 4(t0)        # MEM[0x204] = Remainder

    # ==========================================================================
    # Verification of Unaligned Word, Half-Word, and Byte Transfers
    # ==========================================================================
    li   t2, 0x5A
    sb   t2, 9(t0)        # Unaligned byte store at 0x209
    lbu  t4, 9(t0)        # Unaligned byte load from 0x209 (Expect 0x5A)

    li   t3, 0xC0DE
    sh   t3, 10(t0)       # Unaligned half-word store at 0x20A
    lhu  t5, 10(t0)       # Unaligned half-word load from 0x20A (Expect 0xC0DE)

    # Unaligned word load across boundary (at 0x209: bytes 0x209, 0x20A, 0x20B, 0x20C)
    lw   t6, 9(t0)        # Reads 32-bit unaligned word

halt:
    j    halt             # Infinite loop terminating test program

# ==============================================================================
# Function: restoring_divide
# Algorithm: 16-bit Unsigned Restoring Division
# Input:
#   a0 = 16-bit Dividend
#   a1 = 16-bit Divisor
# Output:
#   a0 = 16-bit Quotient  (14 = 0x000E)
#   a1 = 16-bit Remainder (2  = 0x0002)
# Register Usage:
#   t0 = Q (working dividend / quotient register)
#   t1 = D (divisor)
#   t2 = R (remainder register, initialized to 0)
#   t3 = Loop Counter (16 downto 1)
#   t4 = Shift bit extracted from Q
# ==============================================================================
restoring_divide:
    mv   t0, a0           # t0 = Q = Dividend
    mv   t1, a1           # t1 = D = Divisor
    li   t2, 0            # t2 = R = 0 (Remainder accumulator)
    li   t3, 16           # t3 = 16 (Loop iteration counter)

div_loop:
    # 1. Extract MSB of current Q (bit 15)
    srli t4, t0, 15
    andi t4, t4, 1

    # 2. Shift R left by 1 and pull in MSB of Q
    slli t2, t2, 1
    or   t2, t2, t4

    # 3. Shift Q left by 1
    slli t0, t0, 1

    # 4. Trial subtraction: R - D
    # If R < D, trial subtraction borrows -> Restore R (keep unchanged), Q LSB = 0
    # If R >= D, subtract D from R, set Q LSB = 1
    bltu t2, t1, no_sub
    sub  t2, t2, t1       # Subtraction successful: R = R - D
    ori  t0, t0, 1        # Set quotient bit: Q = Q | 1

no_sub:
    # Loop control: count down from 16 to 0
    addi t3, t3, -1
    bne  t3, x0, div_loop

    # Return results in a0 (Quotient) and a1 (Remainder)
    slli a0, t0, 16
    srli a0, a0, 16       # a0 = Quotient (14 = 0x000E)
    slli a1, t2, 16
    srli a1, a1, 16       # a1 = Remainder (2  = 0x0002)
    ret                   # Return to caller: jalr x0, ra, 0

# ==============================================================================
# Data Section (Memory initialized to 0)
# ==============================================================================
.org 0x0200
DATA_QUOTIENT:
    .word 0x00000000
DATA_REMAINDER:
    .word 0x00000000
DATA_UNALIGNED:
    .word 0x00000000
    .word 0x00000000
