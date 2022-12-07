// File: a5a.asm
// Author: Shaheryar 
// Date: Nov. 23, 2022
//
// Description: Translate all functions except main() into ARMv8 assembly language.

/** Macro Definition **/ 

define(r_base, x25)

/** Assembler Equates */
QUEUESIZE = 8
MODMASK = 0x7
TRUE = 1
FALSE = 0
display_alloc = -(16 + 24) & -16

/** Declare External Variables */
            .data
			.global queue
			.global head
			.global tail
head:       .word   -1
tail:       .word   -1

            .bss
queue:      .skip   QUEUESIZE * 4

            .text

/** Text Strings **/

.text

overf:   .string "\nQueue overflow! Cannot enqueue into a full queue.\n"
under:  .string "\nQueue underflow! Cannot dequeue from an empty queue.\n"
empty:      .string "\nEmpty queue\n"
current:    .string "\nCurrent queue contents:\n"
qarrelement:    .string "  %d"
head_p:     .string " <-- head of queue"
tail_p:     .string " <-- tail of queue"
newline:    .string "\n"


/** FP & LR **/

	fp .req x29
	lr .req x30

/** Enqueue **/

define(r_val, w9) // Placeholder value register
define(r_tail, w10) // Tail register

	.balign 4
	.global enqueue

enqueue: 

	stp fp, lr, [sp, -16]! // Allocation of memory
	mov fp, sp // Move FP to value of SP

	mov r_val, w0 // Value = value of w0 

	bl queueFull // Branch to queueFull 
	cmp w0, TRUE // If w0 = TRUE (returned from queueFull)
	b.ne enq_empty // If w0 is not TRUE then branch to first if in enqueue

	adrp x0, overf // Print statement
	add x0, x0, :lo12:overf // More print statements
	bl printf // Call printf
	
	b enq_exit // Branch to exit function of enqueue


enq_empty: 
	
	bl queueEmpty // Branch to queueEmpty
	cmp w0, TRUE // Check value of w0 with TRUE
	b.ne enq_if_else // Branch to enq else if not true

	adrp r_base, head // Find address of head
	add r_base, r_base, :lo12:head // Add to r_base it's value with head and format to 12 bits
	str wzr, [r_base] // Store cleared value of r_base

	adrp r_base, tail // Find address of tail
	add r_base, r_base, :lo12:tail // Add r_base to it's value with tail and format to 12 bits
	str wzr, [r_base] // Store cleared value of r_base

	b enq_valassign // Branch to enq_valassign (queue[tail] = value;)

enq_if_else:

	adrp r_base, tail // Find address of tail
	add r_base, r_base, :lo12:tail // Add to r_base it's value and format to 12 bits

	ldr r_tail, [r_base] // Load tail value

	add r_tail, r_tail, 1 // Add 1 to tail_r (tail++)
	and r_tail, r_tail, MODMASK // Bitwise AND with r_tail and MODMASK

	str r_tail, [r_base] // Store tail in r_base

	b enq_valassign // Branch to enq_valassign (queue[tail] = value;)

enq_valassign:

	ldr r_tail, [r_base] // BRING BACK THE TAILLL
	adrp r_base, queue // Find base address of queue

	add r_base, r_base, :lo12:queue // Add r_base to it's value with queue and format to 12 bits

	str r_val, [r_base, r_tail, SXTW 2] // Store value of r_val with adress sign extended

enq_exit:

	ldp fp, lr, [sp], 16 // Deallocate memory
	ret // Return to OS

/** Dequeue **/

define(r_head, w12) // Register for head
define(r_tail, w13) // Register for tail
define(r_val, w11) // Register for placeholder value
define(r_one, w22) // Register for -1 value

	.balign 4
	.global dequeue

dequeue: 

	stp fp, lr, [sp, -16]! // Allocation of memory
	mov fp, sp // Move FP to value of SP

	bl queueEmpty // Branch to queueEmpty function
	cmp w0, TRUE // Compare w0 with TRUE (w0 = returned from queueEmpty)
	b.ne deq_if // Branch to if function of dequeue if w0 was FALSE

	adrp x0, under // Print statement
	add x0, x0, :lo12:under // More print statements
	bl printf // Call printf

	mov w0, -1 // Move register w0 to -1 (for return)

	b deq_exit // Branch to exit


deq_if:

	adrp r_base, head // Find base address of head
	add r_base, r_base, :lo12:head // Add r_base to it's value with head and format to 12 bits
	ldr r_head, [r_base] // Load r_head

	adrp r_base, queue // Find base address of queue
	add r_base, r_base, :lo12:queue // Add r_base to it's value with queue and format to 12 bits
	ldr r_val, [r_base, r_head, SXTW 2] // Load into r_val the stored value

	adrp r_base, tail // Find base address of tail
	add r_base, r_base, :lo12:tail // Add r_base to it's value with tail and format to 12 bits
	ldr r_tail, [r_base] // Load r_tail

	cmp r_head, r_tail // Compare r_tail and r_head
	b.ne deq_if_else // If r_tail is NOT EQUAL to r_head branch to deq_if_else

	mov r_one, -1 // Move into r_one the value of -1

	adrp r_base, head // get base address of head
	add r_base, r_base, :lo12:head // Add r_base to it's value with head and format to 12 bits
	str r_one, [r_base] // Store -1 into r_base for head

	adrp r_base, tail // get base address of tail
	add r_base, r_base, :lo12:tail // Add r_base to it's value with tail and format to 12 bits
	str r_one, [r_base] // Store -1 into r_base for tail

	b branchreturn // Branch to branch return

deq_if_else:

	add r_head, r_head, 1 // Add one to r_head for head++
	and r_head, r_head, MODMASK // Bitwise AND with r_head and MODMASK

	adrp r_base, head // Find address of head
	add r_base, r_base, :lo12:head // Add r_base to it's value with head and format to 12 bits
	str r_head, [r_base] // Store r_head into r_base

branchreturn:

	mov w0, r_val // Move r_val to 0

deq_exit:

	ldp fp, lr, [sp], 16 // Deallocate memory
	ret // Return to OS

/** queueFull **/

define(r_head, w14)
define(r_tail, w15)

	.global queueFull
	.balign 4

queueFull:

	stp fp, lr, [sp, -16]! // Allocation of memory
	mov fp, sp // Move FP to value of SP
	
	adrp r_base, tail // Find base address of tail
	add r_base, r_base, :lo12:tail // Add r_base to it's value with tail and format to 12 bits
	ldr r_tail, [r_base] // Load r_tail

	add r_tail, r_tail, 1 // Add one to r_tail for tail++
	and r_tail, r_tail, MODMASK // Bitwise AND with r_tail and MODMASK

	adrp r_base, head // get base address of head
	add r_base, r_base, :lo12:head // Add r_base to it's value with head and format to 12 bits
	ldr r_head, [r_base] // Load r_head

	cmp r_tail, r_head // Compare r_tail and r_head
	b.eq que_true // Branch if they are equal to quef_true
	
	mov w0, FALSE // If not equal, move w0 to FALSE

	ldp fp, lr, [sp], 16 // Deallocate memory
	ret // Return to OS

que_true:

	mov w0, TRUE // Move w0 to TRUE

/** queueEmpty **/

define(r_head, w19)

	.balign 4
	.global queueEmpty

queueEmpty: 

	stp fp, lr, [sp, -16]! // Allocation of memory
	mov fp, sp // Move FP to value of SP

	adrp r_base, head // get base address of head
	add r_base, r_base, :lo12:head // Add r_base to it's value with head and format to 12 bits
	ldr r_head, [r_base] // Load r_head

	cmp r_head, -1 // Compare r_head with -1
	b.ne quee_false // Branch if false to quee_false

	mov w0, TRUE // Move w0 to TRUE

	b queueEmptyExit // Branch to exit

quee_false:
	
	mov w0, FALSE // Move w0 to FALSE

queueEmptyExit:

	ldp fp, lr, [sp], 16 // Deallocate memory
	ret // Return to OS


/** Display **/

define(r_i, w20)
define(r_j, w21)
define(r_counter, w22)
define(r_tail, w23)
define(r_head, w24)

	.balign 4
	.global display

	/** blank if it has numbers **/

display:

	stp fp, lr, [sp, display_alloc]! // Allocation of memory
	mov fp, sp // Move FP to value of SP

	bl queueEmpty // Branch to queueEmpty
	cmp w0, TRUE // Check value of w0 with TRUE
	b.ne dis_if // Branch to dis_if if not true

	adrp x0, empty // Print statements
	add x0, x0, :lo12:empty // More print statements
	bl printf // Call printf

	b displayexit // Branch to display exit

dis_if:

	adrp r_base, head // get base address of head
	add r_base, r_base, :lo12:head // Add r_base to it's value with head and format to 12 bits
	ldr r_head, [r_base] // Load r_head

	adrp r_base, tail // Find base address of tail
	add r_base, r_base, :lo12:tail // Add r_base to it's value with tail and format to 12 bits
	ldr r_tail, [r_base] // Load r_tail

	sub r_counter, r_tail, r_head // r_counter = tail - head
	add r_counter, r_counter, 1 // r_counter + 1

	cmp r_counter, 0 // Compare r_counter with 0
	b.gt dis_main // If r_counter > 0, branch to dis_main

	add r_counter, r_counter, QUEUESIZE // Otherwise add QUEUESIZE to r_counter

dis_main:

	adrp x0, current // Print statement
	add x0, x0, :lo12:current // More print statements
	bl printf // Call printf

	mov r_i, r_head // Move value of r_head into i
	mov r_j, 0 // Move r_j to 0
	b pretest_for // Branch to pretest_for

dis_forloop:

	adrp x0, qarrelement // Print statement
	add x0, x0, :lo12:qarrelement // More print statements

	adrp r_base, queue // Get base address of queue
	add r_base, r_base, :lo12:queue // Add r_base to it's value with queue and format to 12 bits
	ldr w1, [r_base, r_i, SXTW 2] // Load into w1 the value of i with it's offset and sign extend it 
	bl printf // Call printf

	cmp r_i, r_head // Compare r_i with r_head
	b.ne continue // If not equals, continue

	adrp x0, head_p // Print statement
	add x0, x0, :lo12:head_p // More print statements
	bl printf // Call printf

continue:

	cmp r_i, r_tail // Compare i with tail
	b.ne for_main // Branch if not equals to for_main
	
	adrp x0, tail_p // Print statements
	add x0, x0, :lo12:tail_p // More print statements
	bl printf // Call printf 

for_main:

	adrp x0, newline // Print statements
	add x0, x0, :lo12:newline // More print statements
	bl printf // Call printf

	add r_i, r_i, 1 // Add 1 to i (i++)
	add r_i, r_i, MODMASK // Add MODMASK to i

	add r_j, r_j, 1 // Add 1 to j (j++)

pretest_for:

	cmp r_j, r_counter // Compare r_j with r_counter

/** GDB TEST FOR FAULT **/

gdb1:

	b.lt dis_forloop // Branch if less than to dis_forloop


displayexit:

	ldp fp, lr, [sp], -display_alloc // Deallocate memory
	ret // Return to OS
