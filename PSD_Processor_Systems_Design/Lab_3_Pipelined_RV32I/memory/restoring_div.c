/*
 * ==============================================================================
 * E3: 245 Processor System Design - IISc DESE
 * Lab Exercise 2: 32-bit Single Cycle RISC-V Processor (RV32I)
 * C Program for 16-bit Unsigned Restoring Division Algorithm
 * ==============================================================================
 */

// Function: restoring_divide
// Performs 16-bit restoring division algorithm:
// Inputs:
//   dividend: 16-bit unsigned dividend (e.g. 100)
//   divisor : 16-bit unsigned divisor  (e.g. 7)
// Outputs:
//   Returns quotient (e.g. 14) and writes remainder to *rem_ptr (e.g. 2)
unsigned int restoring_divide(unsigned int dividend, unsigned int divisor, unsigned int *rem_ptr) {
    unsigned int Q = dividend & 0xFFFF; // Quotient / Working dividend
    unsigned int D = divisor & 0xFFFF;  // Divisor
    unsigned int R = 0;                 // Remainder accumulator
    int count = 16;                     // 16-bit division loop

    while (count > 0) {
        // Step 1: Shift R left by 1 bit, pull in MSB of current Q (bit 15)
        unsigned int msb_q = (Q >> 15) & 1;
        R = (R << 1) | msb_q;

        // Step 2: Shift Q left by 1 bit
        Q = (Q << 1) & 0xFFFF;

        // Step 3: Trial subtraction: R - D
        if (R >= D) {
            R = R - D;     // Subtraction successful, keep subtracted remainder
            Q = Q | 1;     // Set quotient bit to 1
        } else {
            // Trial subtraction negative -> Restore R (remains unchanged)
            // Quotient bit remains 0
        }

        count--;
    }

    if (rem_ptr) {
        *rem_ptr = R;
    }
    return Q;
}

// Main Program
int main(void) {
    // Test Vector: 100 / 7
    unsigned int dividend = 100;
    unsigned int divisor  = 7;
    unsigned int rem = 0;

    // Call restoring division function
    unsigned int quot = restoring_divide(dividend, divisor, &rem);

    // Write results to designated data memory locations:
    // Address 0x200 (Word 128) = Quotient  (Expected: 14 = 0x000E)
    // Address 0x204 (Word 129) = Remainder (Expected: 2  = 0x0002)
    volatile unsigned int *quot_mem = (volatile unsigned int *)0x200;
    volatile unsigned int *rem_mem  = (volatile unsigned int *)0x204;
    *quot_mem = quot;
    *rem_mem  = rem;

    // Unaligned transfer validation:
    // Test byte and half-word unaligned store and load
    volatile unsigned char  *unaligned_byte = (volatile unsigned char *)0x209;
    volatile unsigned short *unaligned_half = (volatile unsigned short *)0x20A;
    *unaligned_byte = 0x5A;
    *unaligned_half = 0xC0DE;

    // Halt in infinite loop
    while (1);

    return 0;
}
