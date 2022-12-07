// File: assign1a.s 
// Author: Shaheryar 
// Date: September 25, 2022
//
// Description: Find the maximum value of the term y = 4x^4 + 301x^2 + 56x - 103 within the domain (x) -10 and 10. 

print_label: .string "Domain (x): %d, Range (y): %d, Current y maximum: %d\n" // Create String that formats the information we need
		
	.balign 4	// Ensure instruction's' address is divisible by 4. 
	.global main // Ensure main label is visible to linker

main:
	
	stp x29, x30, [sp, -16]! // Saving FP and LR to stack
	mov x29, sp // Move FP to the top of the stack

	mov x19, -10 // Set register x19 to the start of our domain, -10. 
	mov x25, -10563 // Set Register x25 = the value when x=-10 as thats where our loop starts to give us a baseline and use x25 to update the maximum values

validation_loop:
	
	cmp x19, 10 // Ensure we are not out of our domain range between -10 and 10. 
	b.gt exit // If we are over 10, we are out of our domain hence skip the loop.

loop: 
	
	mul x20, x19, x19 // Take register x19 and multiply it twice to get x^2 into x20, x20=x^2

	mov x22, 301 // Put the number 301 in register x22
	mul x23, x22, x20 // Register x23=301x^2
	mov x24, x23 // x24=301x^2

	mov x22, 4 // Store value 4 in register x22
	mul x21, x20, x20 // Register x20 multiplied twice, then x21=x^4
	mul x23, x22, x21 // Register x23 is now: x23=4x^4
	sub x24, x24, x23 // Register x24 = 301x^2-4x^4

	mov x22, 56 // Move into register x22 the value 56
	mul x23, x22, x19 // Take values of register x22=56, and x19=x and multiply them into register x23=56x.
	add x24, x24, x23 // add into register x24 the value of itself and the value of x23. x24=301x^2-4x^4+56x.

	mov x22, 103 // Store into x22 the value 103.
	sub x24, x24, x22 // Register x24 is now: x24=301x^2-4x^4+56x-103.

	cmp x24, x25 // Compare the values of x24 and x25. 
	b.lt next // If x24 is less than x25, keep the current value of x25 stored. 
	mov x25, x24 // If register x24 (the function) returns a larger value, store it into x25 as our new maximum. 

next: 

	adrp x0,print_label // Setting arguments for print function
	add x0, x0, :lo12:print_label // Setting more arguments for the print function
	mov x1, x19 // Store into x1 argument 1, the domain.
	mov x2, x24 // Store into x2, argument 2, the range
	mov x3, x25 // Store into x3, argument 3, the current y maximum.
	bl printf // Call the print function

	add x19, x19, 1 // Making sure we increment our loop by 1. 
	b validation_loop // Run the validation loop to check the value of x19. 
	
exit: 
	
	ldp x29, x30, [sp], 16 // Restore saved FP and LR from the stack
	ret // Return to operating system

