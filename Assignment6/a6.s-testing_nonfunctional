// File: a6a.asm
// Author: Shaheryar 
// Date: Dec 02, 2022
//
// Description: Write an ARMv8 assembly language program to compute the sine and cosine of an angle given in degrees using the series expansions.







buffer_size = 8 // Buffer Size in bytes
alloc = -(16 + buffer_size) & -16 // Allocation
buffer_offset = 16 // Buffer Offset

exponent    .req d19 // Exponent
numerator   .req d20 // Numerator 
factorial   .req d21 // Factorial
equation    .req d22 // Equation (x/y)
expansion   .req d23 // Expansion of term
increment   .req d24 // Increment 

minimum:    .double 0r1.0e-10 // Minimum value (constant)
pi_two: .double 0r1.57079632679489661923 // pi/2 value
ninety: .double 0r90.0 // 90 value
zero: .double 0r0.00 // Zero value

label: .string "Input:\t\tSin(x):\t\tCos(x)\n" 
value: .string "%13.10f\t%13.10f  \t%13.10f\n"
error_txt: .string "Error encountered. File not found.\n"
usage_error: .string "Incorrect usage. Format: ./a6 file.bin\n"


    fp .req x29
    lr .req x30

    .global main
    .balign 4

main:

    stp fp, lr, [sp, alloc]! // Allocation of memory
    mov fp, sp // Move FP to value of SP

    mov w18, w0 // Move w0 into w18
	mov x22, x1 // Move x1 into x22

    cmp w18, 2 // Compare w18 with 3
    b.ne usage_error_func // If not 2, branch to error

    adrp x0, label // Print statements
    add x0, x0, :lo12:label // More print statements
    bl printf // Print

    mov w0, -100 // cwd argument
    ldr x1, [x22, 8] // Load the command line file into x1
    mov w2, 0 // Read only argument
    mov w3, 0 // Argument not used
    mov w8, 56 // Openat I/O request
    svc 0 // System function 
    mov w19, w0 // File descriptor recording

    cmp w19, 0 // Check if file opens successfully
    b.ge file_opened // If file opens, go to file_opened function

    adrp x0, error_txt // Print statement
    add x0, x0, :lo12:error_txt // More print
    bl printf // Branch to print

    mov w0, -1 // Move -1 into w0
    b exit // Branch to exit

file_opened:

    add x21, fp, buffer_offset // x21 is now frame pointer + buffer offset

read_inputs:

    mov w0, w19 // Move w0 to fd
    mov x1, x21 // Move x1 to x21
    mov w2, buffer_size // Move w2 to buffer_size
    mov x8, 63 // I/O Read
    svc 0 // System function

    mov x20, x0 // Move the bytes read into x0

    cmp x20, buffer_size // Compare bytes read to buffer_size
    b.ne file_done // Branch to file_read if not equals (finished)

    adrp x10, zero // Load zero
    add x10, x10, :lo12:zero // Format
    ldr d13, [x10] // Load into d13 zero

    adrp x10, pi_two // Load pi_two
    add x10, x10, :lo12:pi_two // format
    ldr d14, [x10] // Load into d14 pi_two

    adrp x10, ninety // Load ninety
    add x10, x10, :lo12:ninety // Format
    ldr d15, [x10] // Load into d15 ninety

    fcmp d0, d13 // Compare input with 0
    b.lt read_inputs // Branch if less than to read_inputs

    fcmp d0, d15 // Compare input with 90
    b.gt read_inputs // Branch if greater than to read_inputs

    ldr d0, [x21] // Load value
    bl sin_function // Branch to sin function
    fmov d1, d0 // First argument

    ldr d0, [x21] // Load value
    bl cos_function // Branch to cos function
    fmov d2, d0 // Second argument

    adrp x0, value // Print statement
    add x0, x0, :lo12:value // More print
    ldr d0, [x21] // Load first argument
    bl printf // Print function

    b read_inputs // Branch back

file_done:

    mov w0, w19 // Move w0 to fd
    mov x8, 57 // Close I/O request
    svc 0 // System function
    mov w0, 0 // Move w0 to 0
    b exit // Branch to exit

usage_error_func:

    adrp x0, usage_error // Print statement
    add x0, x0, :lo12:usage_error // More print
    bl printf // Branch to print

exit:

    ldp fp, lr, [sp], -alloc // Deallocate memory
    ret 

    .balign 4
    .global sin_function

sin_function:

    stp fp, lr, [sp, -16]! // Memory allocation
    mov fp, sp // Move fp to sp

    fdiv d13, d14, d15 // Radian conversion d13 = (pi_two/90)

    fmul d0, d0, d13 // Convert input to radians input * radian conversion

    adrp x10, minimum // Load minimum
    add x10, x10, :lo12:minimum // Format
    ldr d5, [x10] // Load into d5 the minimum

    fmov d12, d0 // Move d0 into d12
    fmul d12, d12, d12 // d12 = x*x = x^2

    fmov numerator, d0 // Move d0 into numerator (x)
    fmov factorial, 1.0 // Move factorial to 1.0
    fmov exponent, 1.0 // Move exponent to 1.0
    fmov increment, 1.0 // Move increment to 1.0
    fmov expansion, numerator // Add x into expansion
    fdiv equation, numerator, factorial // Equation = numerator / factorial

sin_loop:

    fneg numerator, numerator // Negate numerator
    
    fmul numerator, numerator, d12 // Numerator = numerator * x^2

    /** Factorial **/
    fadd exponent, exponent, increment // Exponent = exponent + 1
    fmul factorial, factorial, exponent // Factorial = factorial * exponent

    fadd exponent, exponent, increment // Exponent = exponent + 1
    fmul factorial, factorial, exponent // Factorial = factorial * exponent

    fdiv equation, numerator, factorial // Equation = numerator / factorial

    fadd expansion, expansion, equation // Expansion = Expansion + equation
 
    fabs equation, equation // Equation absolute value
    fcmp equation, d5 // Compare equation with minimum
    b.ge sin_loop // Branch to the current loop if greater than minimum value

    fmov d0, expansion // Move into d0 the value of expansion
    
    ldp fp, lr, [sp], 16 // Deallocate memory
    ret // Return

    .balign 4
    .global cos_function

cos_function:

    stp fp, lr, [sp, -16]! // Memory allocation
    mov fp, sp // Move fp to sp

    fdiv d13, d14, d15 // Radian conversion d13 = (pi_two/90)

    fmul d0, d0, d13 // Convert input to radians input * radian conversion

    adrp x10, minimum // Load minimum
    add x10, x10, :lo12:minimum // Format
    ldr d5, [x10] // Load into d5 the minimum

    fmov d12, d0 // Move d0 into d12
    fmul d12, d12, d12 // d12 = x*x = x^2

    fmov numerator, d12 // Move input into numerator
    fmov factorial, 2.0 // Move 2.0 into factorial
    fmov exponent, 2.0 // Move 2.0 into exponent
    fmov increment, 1.0 // Move 1.0 into increment
    fmov expansion, 1.0 // Move 1.0 into expansion

cos_loop:

    fneg numerator, numerator // Negate the numerator

    fdiv equation, numerator, factorial // Equation = Numerator / Factorial

    fmul numerator, numerator, d12 // Numerator = numerator * x^2

    /** Factorial Calculations **/

    fadd exponent, exponent, increment // Exponent = Exponent + 1
    fmul factorial, factorial, exponent // Factorial = Factorial * Exponent

    fadd exponent, exponent, increment // Exponent = Exponent + 1
    fmul factorial, factorial, exponent // Factorial = Factorial * Exponent

    fadd expansion, expansion, equation // Expansion = Expansion + Equation

    fabs equation, equation // Equation absolute value
    fcmp equation, d5 // Compare equation with minimum
    b.ge cos_loop // Branch to the current loop if greater than minimum value

    fmov d0, expansion // Move value of expansion into d0

    ldp fp, lr, [sp], 16 // Deallocate memory
    ret // Return



