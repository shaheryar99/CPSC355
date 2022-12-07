// File: assign1b.asm 
// Author: Shaheryar 
// Date: September 25, 2022
//
// Description: Find the maximum value of the term y = -4x^4 + 301x^2 + 56x - 103 within the domain (x) -10 and 10. 

define(xvi_r, x19)
define(yvi_r,x24)
define(t1_r, x22)
define(t2_r, x23)
define(max_r, x25)
define(dmin, -10)
define(dmax, 10)

print_label: .string "Domain (x): %d, Range (y): %d, Current y maximum: %d\n" // Create String that formats the information we need
		
	.balign 4	// Ensure instruction's' address is divisible by 4. 
	.global main // Ensure main label is visible to linker

main:
	
	stp x29, x30, [sp, -16]! // Saving FP and LR to stack
	mov x29, sp // Move FP to the top of the stack

	mov xvi_r, dmin // Set register xvi_r to the start of our domain, dmin (-10). 
	mov x25, -10563 // Set Register x25 = the value when x=-10 as thats where our loop starts to give us a baseline and use x25 to update the maximum values

	b validation_loop // Run/Branch to the validation loop

loop: 
	
	mul x20, xvi_r, xvi_r // Take register xvi_r and multiply it twice to get x^2 into x20, x20=x^2
	mul x21, x20, x20 // Register x20 multiplied twice, then x21=x^4

	mov t1_r, -4 // Set term 1 as -4
	mov t2_r, 301 // Set term 2 as 301
	mul t2_r, t2_r, x20 // Set term 2 as 301x^2
	madd yvi_r, t1_r, x21, t2_r // Put into yvi_r register the contents of t1_r = -4, multiply it by register x21 (x^4) so -4x^4, then add t2_r = 301x^2. Hence yvi_r = -4x^4 + 301x^2.

	mov t1_r, 56 // Move the term 56 to register t1_r
	mov t2_r, -103 // Move the term -103 to register t2_r
	madd t1_r, t1_r, xvi_r, t2_r // Put into t1_r register the contents of itself multiplied by xvi_r, and then the contents of t2_r. So t1_r = 56x - 103.

	add yvi_r, yvi_r, t1_r // Add into the yvi_r register the contents of itself and the contents of register t1_r so yvi_r = -4x^4 + 301x^2 + 56x - 103.

	cmp yvi_r, max_r // Compare the values of yvi_r and max_r. 
	b.lt next // If yvi_r is less than max_r, keep the current value of max_r stored. 
	mov max_r, yvi_r // If register yvi_r (the function) returns a larger value, store it into max_r as our new maximum. 

next: 

	adrp x0,print_label // Setting arguments for print function
	add x0, x0, :lo12:print_label // Setting more arguments for the print function
	mov x1, xvi_r // Store into x1 argument 1, the domain.
	mov x2, yvi_r // Store into x2, argument 2, the range
	mov x3, max_r // Store into x3, argument 3, the current y maximum.
	bl printf // Call the print function

	add xvi_r, xvi_r, 1 // Making sure we increment our loop by 1. 

validation_loop:
	
	cmp xvi_r, dmax // Ensure we are not out of our domain range between -10 and 10. 
	b.le loop // If we are less than 10, loop.
	
exit: 
	
	ldp x29, x30, [sp], 16 // Restore saved FP and LR from the stack
	ret // Return to operating system

