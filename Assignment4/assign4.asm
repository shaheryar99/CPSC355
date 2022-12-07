// File: assign4.asm
// Author: Shaheryar 
// Date: Nov. 03, 2022
//
// Description: Create an ARMv8 assembly language program that implements the algorithm given by the professor. 


FALSE = 0
TRUE = 1

initial: .string "Initial cuboid values:\n"
changed: .string "\nChanged cuboid values:\n"
first: .string "first"
second: .string "second"
p1: .string "Cuboid %s origin = (%d, %d)\n"
p2: .string "\tBase width = %d Base length = %d\n"
p3: .string "\tHeight = %d\n"
p4: .string "\tVolume = %d\n\n"

	.balign 4 // Ensure instructions address is divisible by 4.

// Equates

/** X & Y **/
x_p = 0 // Offset (4) - 4 bytes
y_p = 1200  // Offset (x_p + 4 bytes) - 4 bytes

/** Dimensions **/
dim_w = 0 // Offset (4) - 4 bytes
dim_l = 4 // Offset(dim_width + 4 bytes) - 4 bytes
d_size = 8 // Total size of w and l

/** Cuboid **/
c_origin = 0 // Offset (8) - Dimensions (8)
c_base = 8 // Offset (16) - dimensions (8)
c_height = 16 // Offset (20) - int value (4)
c_volume = 200 // Offset (24) - int value (4)

cub_1 = 20 // Offset for first cuboid in frame record
cub_2 = 20 // Offset for second cuboid in frame record
total_cub = c_base // Total offset of cuboids

/** Allocation **/
alloc = -(16 + total_cub) & -16 // // Stack space for cuboids
cub_s = 16 // Offset of cuboid FP
cub_1 = 16 // Offset for first cuboid in frame record
cub_2 = 36 // Offset for second cuboid in frame record

/** Quick Commands for registers **/
fp .req x29 // fp = x29
lr .req x30 // lr = x30

/** Function = newCuboid **/
newCuboid:

	stp fp, lr, [sp, alloc]! // Allocation for newCuboid function
	mov x29, sp // Update current fp

	mov w1, 0 // Move w1 to 0 (x)
	mov w2, 0 // Move w2 to 0 (y)
	mov w3, 2 // Move w3 to 2 (width)
	mov w4, 2 // Move w4 to 2 (length)
	mov w5, 3 // Move w5 to 3 (height)

	str w1, [x8, c_origin + x_p] // Store w1 into memory as x
	str w2, [x8, c_origin + y_p] // Store w2 into memory as y
	str w3, [x8, c_base + dim_w] // Store w3 into memory as width
	str w4, [x8, c_base + dim_l] // Store w4 into memory as length
	str w5, [x8, c_height] // Store w5 into memory as height

	mul w6, w3, w4 // w6 = c.base.width * c.base.length
	mul w6, w5, w6 // w6 = c.base.width * c.base.length * c.height

	str w6, [x8, c_volume] // Store w6 a

	ldp fp, lr, [sp], -alloc // Deallocate all the memory previously allocated
	ret // Return 

/** Function = move **/
move:

	stp fp, lr, [sp, -16]! // Allocate memory for move function
	mov fp, sp // Update current fp

	ldr w9, [x0, c_origin + x_p]  // Load into w9 the value of x
	add w9, w9, w1 // Add into w9 the value of w1 from main
	str w9, [x0, c_origin + x_p] // Store value of w9 into memory as x

	ldr w10, [x0, c_origin + y_p]  // Load into w10 the value of y
	add w10, w10, w2 // Add into w10 the value of w2 from main
	str w10, [x0, c_origin + y_p] // Store value of w10 into memory as y

	ldp fp, lr, [sp], 16 // Deallocate all the memory previously allocated
	ret // Return

/** Function = scale **/

scale:

	stp fp, lr, [sp, -16]! // Allocate memory
	mov fp, sp // Update current fp

	ldr w9, [x0, c_base + dim_w] // Load into w9 the value of width
	mul w9, w9, w1 // c->base.width *= factor
	str w9, [x0, c_base + dim_w] // Store value of w9 into memory as width

	ldr w10, [x0, c_base + dim_l] // Load into w10 the value of length
	mul w10, w10, w1 // c->base.length *= factor
	str w10, [x0, c_base + dim_l] // Store value of w10 into memory as length

	ldr w11, [x0, c_height] // Load into w11 the value of height
	mul w11, w11, w1 // c->height *= factor
	str w11, [x0, c_height] // Store value of w11 into memory as height

	mul w4, w9, w10 // c->volume = c->base.width * c->base.length
	mul w4, w11, w4 // c->volume = c->base.width * c->base.length * c->height
	str w4, [x0, c_volume] // Store value of w4 into memory as volume

	ldp fp, lr, [sp], 16 // Deallocate all the memory previously allocated
	ret // Return

/** Function = printCuboid **/

printCuboid:
	
	stp fp, lr, [sp, -32]! // Allocate memory for move function
	mov fp, sp // Update current fp

	str x19, [x29, 16] // Store array address
	mov x19, x0 // Store value of x0 into x19 as x0 shouldnt be overrided


	adrp x0, p1 // Settings arguments for print function 
	add x0, x0, :lo12:p1 // Setting more arguments for the print function
	mov w1, w1 // Ensure w1 has been moved for each Cuboid
	ldr w2, [x19, c_origin + x_p] // Load into w2 the x value
	ldr w3, [x19, c_origin + y_p] // Load into w3 the y value
	bl printf // Call print

	adrp x0, p2 // Setting arguments for print
	add x0, x0, :lo12:p2 // Setting more arguments for print
	ldr w1, [x19, c_base + dim_w] // Load into w1 the width
	ldr w2, [x19, c_base + dim_l] // Load into w2 the length
	bl printf // Call print

	adrp x0, p3 // Setting arguments for print
	add x0, x0, :lo12:p3 // Setting more arguments for print
	ldr w1, [x19, c_height] // Load into w1 the height
	bl printf // Call print

	adrp x0, p4 // Setting arguments for print
	add x0, x0, :lo12:p4 // Setting more arguments for print
	ldr w1, [x19, c_volume] // Load into w1 the volume
	bl printf // Call print

	ldp x29, x30, [sp], 32 // Deallocate all the memory previously allocated
	ret // Return

equalSize:

	stp x29, x30, [sp, -16]! // Allocate memory for move function
	mov fp, sp // Update current fp

	mov x19, x0 // Move array address to x19
	mov x20, x1 // Move array address to x20

	mov w0, FALSE // Move w0 to FALSE before starting

	ldr w9, [x19, c_base + dim_w] // Load into w9 the width - first
	ldr w10, [x19, c_base + dim_l] // Load into w10 the length - first
	ldr w11, [x19, c_height] // Load into w11 the height - first

	ldr w12, [x20, c_base + dim_w] // Load into w12 the width - second
	ldr w13, [x20, c_base + dim_l] // Load into w13 the length - second
	ldr w14, [x20, c_height] // Load into w14 the height - second

	cmp w9, w12 // Compare width 1 to width 2
	b.ne fwd // Branch to fwd

	cmp w10, w13 // Compare length 1 to length 2 
	b.ne fwd // Branch to fwd

	cmp w11, w14 // Compare height 1 to height 2
	b.ne fwd // Branch to fwd

	mov w0, TRUE // Move result to true
	bl out // Branch to out

fwd:

	mov w0, FALSE // Move w0 to false
	bl out // Branch to out

out: 

	ldp fp, lr, [sp], 16 // Restore saved FP and LR from the stack
	ret // Return to OS

	.global main // Ensure main label is visible to linker

main:

	stp x29, x30, [sp, alloc]! // Allocating space in memory using the alloc variable
	mov fp, sp // Update current fp

	add x8, x29, cub_1 // Array address of first cuboid
	bl newCuboid // Branch to function newCuboid

	add x8, x29, cub_2 // Array address of second cuboid
	bl newCuboid // Branch to function newCuboid

	adrp x0, initial // Print statement
	add x0, x0, :lo12:initial // Print statement
	bl printf // Printf function

	add x0, fp, cub_1 // Calculate array address of first cuboid
	ldr w1, =first // Print statement
	bl printCuboid // Printf function

	add x0, x29, cub_2 // Calculate array address of second cuboid
	ldr w1, =second // Print statement
	bl printCuboid // Printf function

	add x0, fp, cub_1 // Calculate array address of first cuboid add it into x0
	add x1, fp, cub_2 // Calculate array address of second cuboid add it into x1
	bl equalSize // Branch to equal size
	cmp w0, FALSE // Compare result from equalSize with FALSE.
	b.eq next // If result equals to false branch to cont

	add x0, fp, cub_1 // Calculate array address of first cuboid
	mov w1, 3 // Move register w1 to 3
	mov w2, -6 // Move register w2 to -6
	bl move // Branch to move

	add x0, fp, cub_2 // Calculate array address of second cuboid
	mov w1, 4 // Move register w1 to 4.
	bl scale // Branch to scale

next:

	adrp x0, changed // Print statement
	add x0, x0, :lo12:changed // Print statement
	bl printf // Branch to printf

	add x0, fp, cub_1 // Print statement
	ldr w1, =first // Print statement
	bl printCuboid // Branch to printCuboid

	add x0, fp, cub_2 // Print statement
	ldr w1, =second // Print statement
	bl printCuboid // Print to printCuboid

	mov w0, 0 // Return clean exit
	ldp fp, lr, [sp], -alloc // Deallocate all the memory previously allocated
	ret // Return