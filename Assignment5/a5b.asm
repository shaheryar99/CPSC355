// File: a5b.asm
// Author: Shaheryar 
// Date: Nov. 23, 2022
//
// Description: Create an ARMv8 assembly language program to accept as command line arguments two strings representing a date in the format mm dd.

/** Register uses **/

define(r_cmdarg, w18) // Command line argument
define(r_valarg, x20) // Value argument

define(r_month, w21)
define(r_day, w22)
define(r_season, w25)
define(r_placeholder_month, w26) 
define(r_suffix, w3) 

define(r_suffixbase, x22)
define(r_monthbase, x23)
define(r_seasonbase, x24)

/** Months **/

jan: .string "January"
feb: .string "February"
mar: .string "March"
apr: .string "April"
may: .string "May"
jun: .string "June"
jul: .string "July"
aug: .string "August"
sep: .string "September"
oct: .string "October"
nov: .string "November"
dec: .string "December"

/** Seasons **/

winter_st: .string "Winter"
spring_st: .string "Spring"
summer_st: .string "Summer"
fall_st: .string "Fall"

/** Suffix **/

st: .string "st"
nd: .string "nd"
rd: .string "rd"
th: .string "th"

/** Display **/

display_out: .string "%s %d%s is %s\n"
use_error: .string "Usage: a5b mm dd\n"

/** Initialize data and doubleword alignment **/

	.data
	.balign 8

months_double: .dword  jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec
suffix_double: .dword st, th, nd, rd
season_double: .dword winter_st, spring_st, summer_st, fall_st

			.text

	fp .req x29
	lr .req x30

	.balign 4
	.global main

main:

	stp fp, lr, [sp, -16]! // Allocation of memory
	mov fp, sp // Move FP to value of SP

	mov r_cmdarg, w0 // Move w0 into r_cmdarg
	mov r_valarg, x1 // Move x1 into r_valarg

	cmp r_cmdarg, 3 // Compare r_cmdarg with 3
	b.eq valid // Branch to valid if command line has 3 arguments

	b error // Branch to error

	b exit // Branch to exit

valid:

	ldr x0, [r_valarg, 8] // Load into x0 the first argument
	bl atoi // Change to integer
	mov r_month, w0 // Move integer into r_month

	ldr x0, [r_valarg, 16] // Load into x0 the second argument
	bl atoi // Change to integer
	mov r_day, w0 // Move integer into day

	cmp r_month, 1 // Compare month with 1
	b.lt error // Branch to error if less than 1
	cmp r_month, 12 // Compare month with 12
	b.gt error // Branch to error if greater than 12

	cmp r_day, 1 // Compare day with 1
	b.lt error // Branch to error if less than 1
	cmp r_day, 31 // Compare day with 31
	b.gt error // Branch to error if greater than 31

suffix_branch:

	cmp r_day, 1 // Compare r_day with 1
	b.eq suffix_one // Branch to suffix_one if equals

	cmp r_day, 31 // Compare r_day with 31
	b.eq suffix_one // Branch to suffix_one if equals

	cmp r_day, 2 // Compare r_day with 2
	b.eq suffix_two // Branch to suffix_two if equals

	cmp r_day, 3 // Compare r_day with 3
	b.eq suffix_four // Branch to suffix_four if equals

	cmp r_day, 20 // Compare r_day with 20
	b.le suffix_three // Branch to suffix_two if less than or equals

	cmp r_day, 21 // Compare r_day with 21
	b.eq suffix_one // Branch to suffix_one if equals

	cmp r_day, 22 // Compare r_day with 22
	b.eq suffix_two // Branch to suffix_two if equals

	cmp r_day, 23 // Compare r_day with 23
	b.eq suffix_four // Branch to suffix_four if equals

	cmp r_day, 24 // Compare r_day with 24
	b.ge suffix_three // Branch to suffix_one if less than or equals


suffix_one:

	mov r_suffix, 0 // Move r_suffix to 1
	b season // Branch to season

suffix_two:

	mov r_suffix, 2 // Move r_suffix to 2
	b season // Branch to season

suffix_three: 

	mov r_suffix, 1 // Move r_suffix to 1
	b season // Branch to season

suffix_four:

	mov r_suffix, 3 // Move r_suffix to 3
	b season // Branch to season

season:

	mov r_placeholder_month, r_month // r_placeholder_month = r_month
	
	cmp r_day, 21 // Compare r_day with 21
	b.lt season_cont // if less than 21 branch to season_cont
	add r_placeholder_month, r_placeholder_month, 1 // r_placeholder_month += 1

season_cont:

	cmp r_placeholder_month, 12 // Compare r_placeholder_month with 12
	b.le winter // Branch to winter if less than 12

	mov r_placeholder_month, 1 // Move r_placeholder_month to 1

winter: 

	cmp r_placeholder_month, 3 // Compare r_placeholder_month with 12
	b.gt spring // Branch to spring if > 3

	mov r_season, 0 // Move r_season to 0

	b printstatements // Branch to print statements

spring:

	cmp r_placeholder_month, 6 // Compare r_placeholder_month with 6
	b.gt summer // If >6 branch to summer

	mov r_season, 1 // Move r_season to 1

	b printstatements // Branch to print statements

summer:

	cmp r_placeholder_month, 9 // Compare r_placeholder_month with 9
	b.gt fall // Branch if >9 to fall

	mov r_season, 2 // Move r_season to 2

	b printstatements // Branch to print statements

fall:

	mov r_season, 3 // Move r_season to 3

	b printstatements

printstatements:

	adrp x0, display_out // Print statements
	add x0, x0, :lo12:display_out // More print statements

	adrp r_monthbase, months_double // Get address of month
	add r_monthbase, r_monthbase, :lo12:months_double // Add to r_monthbase it's value with month and format to 12 bits
	sub r_month, r_month, 1 // Subtract 1 from r_month (line 136)
	ldr x1, [r_monthbase, r_month, SXTW 3] // Load first argument

	mov w2, r_day // Day argument (2nd argument)

	adrp r_suffixbase, suffix_double // Base address of suffix
	add r_suffixbase, r_suffixbase, :lo12:suffix_double // Add to r_suffixbase it's value with suffix and format to 12 bits
	ldr x3, [r_suffixbase, r_suffix, SXTW 3] // Load third argument

	adrp r_seasonbase, season_double // Base address of season
	add r_seasonbase, r_seasonbase, :lo12:season_double // Add to r_seasonbase it's value with season and format to 12 bits
	ldr x4, [r_seasonbase, r_season, SXTW 3] // Load fourth argument
	bl printf // Print function

	b exit // Branch to exit

error:

	adrp x0, use_error // Print statements
	add x0, x0, :lo12:use_error // More print statements
	bl printf // Print function

	b exit // Branch to exit

exit:

	ldp fp, lr, [sp], 16 // Deallocate space
	ret // Return to OS
