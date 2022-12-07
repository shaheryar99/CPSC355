// File: assign2a.asm 
// Author: Shaheryar 
// Date: October 05, 2022
//
// Description: Create an ARMv8 assembly language program that implements the program given by the professor. 

define(x_var, w19)
define(y_var, w20)
define(t1, w21)
define(t2, w22)
define(t3, w23)
define(t4, w24)
define(place_holder1, w25)
define(place_holder2, w26)

print_vari: .string "original: 0x%08X reversed: 0x%08X\n" // Printed String


	.balign 4	// Ensure instruction's' address is divisible by 4. 
	.global main // Ensure main label is visible to linker

main:
	
	stp x29, x30, [sp, -16]! // Saving FP and LR to stack
	mov x29, sp // Move FP to the top of the stack

	mov x_var, 0x01FF01FF // Initialize x as  0x01FF01FF

step_1:	// Step 1
		and t1, x_var, 0x55555555 // Use of bitwise AND into t1 with x and 0x55555555
		lsl t1, t1, 1 // Logical shift left (32-bit) of t1 by 1 into t1.
		lsr t2, x_var, 1 // Logical shift right (32-bit) of t1 by 1 into t2.
		and t2, t2, 0x55555555 // Use of bitwise AND into t2 with its own value and 0x55555555
		orr y_var, t1, t2 // Use of bitwise OR on t1 and t2.

step_2: // Step 2
		and t1, y_var, 0x33333333 // Use of bitwise AND on y and 0x33333333 to store in t1
		lsl t1, t1, 2 // Logical shift left of t1 by 2.
		lsr t2, y_var, 2 // Logical shift right ofy by 2 into t2.
		and t2, t2, 0x33333333 // Use of bitwise AND on t2 and 0x33333333 to store in t2.
		orr y_var, t1, t2 // Use of bitwise OR on t1 and t2.

step_3: // Step 3
		and t1, y_var, 0x0F0F0F0F // Use of bitwise AND on y and 0x0F0F0F0F into t1.
		lsl t1, t1, 4 // Logical Shift left on t1 by 4.
		lsr t2, y_var, 4 // Logical Shift Right on y by 4 into t2.
		and t2, t2, 0x0F0F0F0F // Use of bitwise AND on t2 and 0x0F0F0F0F.
		orr y_var, t1, t2 // Use of bitwise OR on t1 and t2.

step_4: // Step 4
		lsl t1, y_var, 24 // Logical shift left y by 24 into t1.
		and t2, y_var, 0xFF00 // Bitwise AND on y and 0xFF00 into t2.
		lsl t2, t2, 8 // Logical shift left by 8 onto t2.
		lsr t3, y_var, 8 // Logical shift right on y by 8 into t3. 
		and t3, t3, 0xFF00 // Bitwise AND onto t3 and 0xFF00 into t3.
		lsr t4, y_var, 24 // Logical shift right onto y by 24 into t4. 

last_steps: // Concluding ORs
		orr place_holder1, t1, t2 // Bitwise OR onto t1 and t2 into place_holder1.
		orr place_holder2, t3, t4 // Bitwise OR onto t3 and t4 into place_holder2.
		orr y_var, place_holder1, place_holder2 // Bitwise OR onto place_holder1 (t1 OR t2) and place_holder2 (t3 OR t4).

print_statement: // Print statement
		adrp x0,print_vari // Setting arguments for print function
		add x0, x0, :lo12:print_vari // Setting more arguments for the print function
		mov w1, x_var // Store into x1 argument 1, the original value.
		mov w2, y_var // Store into x2, argument 2, the reversed value.
		bl printf // Call the print function


exit: 
	
	// Exit Parameters
	ldp x29, x30, [sp], 16 // Restore saved FP and LR from the stack
	mov x0, 0 // Return code 0 at exit
	ret // Return to operating system