// File: a5a.asm
// Author: Shaheryar 
// Date: Dec 02, 2022
//
// Description: Write an ARMv8 assembly language program to compute the sine and cosine of an angle given in degrees using the series expansions.

define(r_fd, w20) 
define(bytes_read, x20)
define(base_buffer, x21)
define(r_cmdarg, w18) // Command line argument
define(r_valarg, x22) // Value argument

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
error_txt: .string "Error encountered.\n"

    fp .req x29
    lr .req x30

    .global main
    .balign 4

main: 

	stp fp, lr, [sp, alloc]! // Allocation of memory
	mov fp, sp // Move FP to value of SP

	mov r_cmdarg, w0 // Move w0 into r_cmdarg
	mov r_valarg, x1 // Move x1 into r_valarg

    cmp r_cmdarg, 2 // Compare r_cmdarg with 3
    b.ne error // If not 2, branch to error

    adrp x0, label // Print statements
    add x0, x0, :lo12:label // More print statements
    bl printf // Print

    mov w0, -100 // cwd argument
    ldr x1, [r_valarg, 8] // Load the command line file into x1
    mov w2, 0 // Read only argument
    mov w3, 0 // Argument not used
    mov w8, 56 // Openat I/O request
    svc 0 // System function 
    mov r_fd, w0 // File descriptor recording

    cmp r_fd, 0 // Check if file opens successfully
    b.ge validated // If file opens, go to validated function

    adrp x0, error_txt // Print statements
    add x0, x0, :lo12:error_txt // More print statements
    bl printf // Print

    mov w0, -1 // Move -1 into w0
    b end

validated:

    add base_buffer, fp, buffer_offset // base_buffer is now frame pointer + buffer offset

read:

    mov w0, r_fd // Move w0 to fd
    mov x1, base_buffer // Move x1 to base_buffer
    mov w2, buffer_size // Move w2 to buffer_size
    mov x8, 63 // I/O Read
    svc 0 // System function

    mov bytes_read, x0 // Move the bytes read into x0

    cmp bytes_read, buffer_size // Compare bytes read to buffer_size
    b.ne file_read // Branch to file_read if not equals (finished)

    adrp x10, pi_two // Load pi_two
    add x10, x10, :lo12:pi_two // Format 
    ldr d14, [x10] // Load into d14 pi_two

    adrp x10, zero // Load ninety
    add x10, x10, :lo12:zero // Format
    ldr d15, [x10] // Load into d15 ninety

    ldr d0, [base_buffer] // Load value into d0
    fcmp d0, d15 // Compare d0 with 0
    b.lt read // Branch if less than 0 to read

    adrp x10, ninety // Load ninety
    add x10, x10, :lo12:ninety // Format
    ldr d15, [x10] // Load into d15 ninety

    fcmp d0, d15 // Compare d0 with 90
    b.gt read // Branch if greater than 90 to read 

    fdiv d16, d14, d15 // d16 = (pi_two)/90 -> Radian conversion

    fmul d0, d0, d16 // d0 = d0 * d16 -> Degrees are now into radian

    bl sin_f // Branch to sin function
    fmov d1, d0 // Second argument (sin)

    ldr d0, [base_buffer] // Load value into d0

    adrp x10, pi_two // Load pi_two
    add x10, x10, :lo12:pi_two // Format 
    ldr d14, [x10] // Load into d14 pi_two

    adrp x10, ninety // Load ninety
    add x10, x10, :lo12:ninety // Format
    ldr d15, [x10] // Load into d15 ninety

    fdiv d16, d14, d15 // d16 = (pi_two)/90 -> Radian conversion

    fmul d0, d0, d16 // d0 = d0 * d16 -> Degrees are now into radian

    bl cos_f // Branch to cos function
    fmov d2, d0 // Third argument (cos)

    adrp x0, value // Print statement
    add x0, x0, :lo12:value // More print statements
    ldr d0, [base_buffer] // Load argument 1
    bl printf // Branch to print function

    b read // Keep branching to read

file_read:

    mov w0, r_fd // Move w0 to fd
    mov x8, 57 // Close I/O request
    svc 0 // System function
    b end // Branch to end

end:

    ldp fp, lr, [sp], -alloc // Deallocate memory
    ret 
    

/** Sin function **/

    .balign 4
    .global sin_f

sin_f:

    stp fp, lr, [sp, -16]! // Allocate memory
    mov fp, sp // Move sp into fp

    adrp x23, minimum // Load minimum
    add x23, x23, :lo12:minimum // Format
    ldr d3, [x22] // d3 is now the minimum

    fmov d18, d0 

    bl sin_loop

/**
    //ldr d0, [base_buffer] // Load x 
    mov d18, d0 // Move value of d0 into d18
    mov d25, d18 // Move value of d18 into d25
    //mov d26, d18 // Move d18 into d26

    //fmul d26, d26, d26 // d26 = x^2

    fmul d25, d25, d25 // d25 = x^2

    fmov exponent, 1.0 // Move exponent to 1
    fmov increment, 2.0 // Move increment to 2
    fmov expansion, d18 // Move d25 to expansion (x)
    fmov numerator, d18 // Move d18 to numerator (x)
    fmov factorial, exponent // Move exponent to factorial

    //fmul factorial, factorial, 2 // Factorial = factorial (3) * 2

    fmul numerator, numerator, d25 // Numerator = x*x^2 = x^3

    fdiv equation, numerator, factorial // Equation = x/1

    //fsub expansion, expansion, equation // Expansion = x - (x^3/3!)

    fneg numerator, numerator // -x **/



sin_loop:

    fmov d0, d18

/**
    fmul numerator, numerator, d25 // Move numerator by x^2
    fadd factorial, factorial, increment // Factorial = factorial + increment
    fadd exponent, exponent, increment // Exponent = Exponent + increment

    fmov d26, factorial // Move value of factorial into d26
    fadd d26, d26, 1 // d26 = factorial + 1
    bl factorial_func // Branch to factorial function

    //fmov d27, exponent // d27 = exponent (temp)
    //fadd d27, d27, 1 // d27 = exponent + 1

    fadd exponent, exponent, increment // Move exponent by increment



    fneg numerator, numerator // Negate numerator for every run

    fabs equation, equation // Absolute value of equation
    fcmp equation, d3 // Compare equation with minimum value in d3
    b.ge sin_loop // If value is > minimum, continue looping

    fmov d0, expansion // Move expansion into d0 
**/

    ldp fp, lr, [sp], 16 // Deallocate 
    ret // Return to OS


/** Cos function **/

    .balign 4
    .global cos_f

cos_f:

    stp fp, lr, [sp, -16]! // Allocate memory
    mov fp, sp // Move sp into fp

    adrp x23, minimum // Load minimum
    add x23, x23, :lo12:minimum // Format
    ldr d3, [x22] // d3 is now the minimum

    fmov d0, d18
    fmov d18, d0

    ldp fp, lr, [sp], 16 // Deallocate 
    ret // Return to OS

    //.balign 4
    //.global factorial_func

//factorial_func: 

/**
    stp fp, lr, [sp, -16]! // Allocate memory
    mov fp, sp // Move sp into fp


    fsub d26, d26, 1 // Subtract 1 from d26 (factorial)
    fsub d27, d26, 1 // Subtract 1 from d27 (factorial - 1)

    fmov d28, d26 // Move value of d26 into d28
    fmul d28, d26, d27 // d28 = factorial * factorial-1

    cmp d27, 1 // Compare d27 with 1
    b.ne factorial_func // If not equals branch to factorial_func

    fmov factorial, d28 // Move value of d28 into factorial 
    
    **/

