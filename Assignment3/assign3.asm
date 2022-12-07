// File: assign3.asm
// Author: Shaheryar 
// Date: October 19, 2022
//
// Description: Create an ARMv8 assembly language program that implements the algorithm given by the professor. 
// Reference: https://pages.cpsc.ucalgary.ca/~sogand.sadrhaghighi/355/Tutorial10.pdf
// Reference: https://d2l.ucalgary.ca/d2l/le/content/472152/viewContent/5564090/View

define(arr_r, x19) // Array register
define(i_s, w20) // i register
define(j_s, w21) // j register
define(int_conver, w22) // Register used for integer conversion for array_total
define(j_1, w23) // j-1 register
define(vj_1, w24) // v[j-1] register
define(v_j, w25) // v[j] register
define(temp_r, w26) // temp register, not used until if_statement
define(stor_reg, w27) // Register used for mod 255

/** Bytes calculations **/ 
arr_total = 40 // Array size
i_bytes = 4 // Bytes of i
j_bytes = 4 // Bytes of j
alloc = -(16 + arr_total*4 + i_size + j_size) & -16 // Allocating 160 bytes for arr_total (40*4) + 4 bytes each for i,j (8 bytes) + 16 for fp,lr. Then bitwise & with -16 to make size divisible by 16.

/** Offset calculations (stack) **/
i_size = 16 // Size of i offset
j_size = i_size + j_bytes // Size of j offset
arr_size = j_size + i_bytes // Size of array offset

/** Print strings **/
print1_str: .string "v[%d]: %d\n" // Printed String
print2_str: .string "\nSorted array:\n" // Printed String

/** Program start **/
	.balign 4	// Ensure instruction's' address is divisible by 4. 
	.global main // Ensure main label is visible to linker

main: 

	stp x29, x30, [sp, alloc]! // Allocating space in memory using the alloc variable
	mov x29, sp // Update current fp

	mov i_s, 0 // Make sure integer i starts at 0
	str i_s, [x29, i_size] // Store value of i in stack using frame pointer (x29) and offset of i.

	b loop1_test // Go to first test loop

loop1: 
	
	ldr i_s, [x29, i_size] // Load value of i
	bl rand // Generate a random number (stored in w0)

	and stor_reg, w0, 0xFF // Use of bitwise and with w0 and 0xFF 
	add arr_r, x29, arr_size // Calculate array address
	str stor_reg, [arr_r, i_s, SXTW 2] // Store the number into v[i] (Using sign extend as array index IS stored in a register, namely i_s.)

	adrp x0, print1_str // Settings arguments for print function (1st print)
	add x0, x0, :lo12:print1_str // Setting more arguments for the print function
	ldr w1, [x29, i_size] // Store into w1, i_size (index i)
	ldr w2, [arr_r, i_s, SXTW 2] // Load into w2 the array register, i_s and sign extend it by 2.
	bl printf // Print the string

	add i_s, i_s, 1 // Increment the i register by 1. 
	str i_s, [x29, i_size] // Store the incremented value into memory 

loop1_test:

	cmp i_s, arr_total // Compare i_s and the array total 
	b.lt loop1 // Branch if less than to loop1

gdb1: // GDB BREAKPOINT 1

	mov int_conver, arr_total // Move array total into int_conver for integer conversion
	sub int_conver, int_conver, 1 // Subtract one from int_conver
	mov i_s, int_conver // Change register i_s to int_conver. 
	str i_s, [x29, i_size] // Store the value of i register into stack
	b outerloop_test // Branch to outerloop test. 

outer_loop: 

	mov j_s, 1 // Initialize j as 1
	str j_s, [x29, j_size] // Store j in the stack

	b innerloop_test // Branch to innerloop test here 


inner_loop:

	ldr j_s, [x29, j_size] // Load value of j from memory
	add arr_r, x29, arr_size // Calculate array address
	sub j_1, j_s, 1 // Subtract into j_1 register to get j-1
	ldr vj_1, [arr_r, j_1, SXTW 2] // vj_1 register now holds v[j-1]
	ldr v_j, [arr_r, j_s, SXTW 2] // v_j now holds v[j]
	cmp vj_1, v_j // Compare v[j-1] and v[j]
	b.gt if_statement // Branch to if_statement if v[j-1] > v[j]

	add j_s, j_s, 1 // Increment j by 1
	str j_s, [x29, j_size] // Store the incremented value into memory
	b innerloop_test // Branch back to innerloop_test
	

if_statement:

	ldr j_s, [x29, j_size] // Load value of j from memory
	sub j_1, j_s, 1 // Subtract into j_1 to get j-1
	add sp, sp, -4 & -16 // Making space for temp variable
	add arr_r, x29, arr_size // Calculate array address
	ldr vj_1, [arr_r, j_1, SXTW 2] // vj_1 register now holds v[j-1]
	ldr v_j, [arr_r, j_s, SXTW 2] // v_j now holds v[j]

	mov temp_r, vj_1 // Temp variable = w26, temp = v[j-1]
	mov vj_1, v_j // Move v[j] into v[j-1] so v[j-1] = v[j]
	mov v_j, temp_r // Move value of temp into v[j], so v[j] = temp
	
	str vj_1, [arr_r, j_1, SXTW 2] // Store v[j-1] into stack
	str v_j, [arr_r, j_s, SXTW 2] // Store v[j] into stack
	add sp,sp, 16 // Deallocate memory for temp variable

	b inner_loop // Branch back to inner loop
	
innerloop_test:

	ldr j_s, [x29, j_size] // Load value of j from memory
	ldr i_s, [x29, i_size] // Load value of i from memory
	cmp j_s, i_s // Compare the values of i & j
	b.le inner_loop // If j <= i, branch to inner_loop

	sub i_s, i_s, 1 // Decrement value of i by 1
	str i_s, [x29, i_size] // Store the decremented value into memory

	b outerloop_test // Otherwise branch to outerloop test

outerloop_test:

	ldr i_s, [x29, i_size] // Load value of i
	cmp i_s, 0 // Compare value of i with 0
	b.ge outer_loop // If i is greater than, or equal to 0, branch to outer_loop

gdb2: // GDB BREAKPOINT 2

	adrp x0, print2_str // Print statement Initialization
	add x0, x0, :lo12:print2_str // Setting more arguments for the print function
	bl printf // Print 
	mov i_s, 0 // Make sure integer i starts at 0
	str i_s, [x29, i_size] // Store value of i in stack using frame pointer (x29) and offset of i.
	b loop2_test // Branch to loop 2 test

loop2:

	ldr i_s, [x29, i_size] // Load value of i
	add arr_r, x29, arr_size // Calculate array address

	adrp x0, print1_str // Settings arguments for print function (1st print)
	add x0, x0, :lo12:print1_str // Setting more arguments for the print function
	ldr w1, [x29, i_size] // Store into w1, i_size (index i)
	ldr w2, [arr_r, i_s, SXTW 2] // Load into w2 the array register, i_s and sign extend it by 2.
	bl printf // Print the string

	add i_s, i_s, 1 // Increment i by 1
	str i_s, [x29, i_size] // Store i into stack
	
loop2_test:
	
	ldr i_s, [x29, i_size] // Load value of i
	cmp i_s, arr_total // Compare index i and array total

	b.lt loop2 // Loop to loop2 if i < array total size
	
exit: 

	ldp x29, x30, [sp], -alloc // Deallocate all the memory previously allocated
	mov w0, 0 // Return 0 for clean exit
	ret // Return to OS