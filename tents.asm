#
# Author:   Nikhil Raina
# 
#
# Description:  The goal of this project is to write 
#       a complete MIPS program from scratch.
#       Using backtracking with severe pruning.
#


# syscall codes
PRINT_INT =	1
PRINT_STRING = 	4
READ_INT = 	5
READ_STRING =	8
PRINT_CHARACTER = 	11

# various frame sizes used by different routines

FRAMESIZE_8 = 	8
FRAMESIZE_24 =	24
FRAMESIZE_40 =	40
FRAMESIZE_48 =	48


    .data
    .align 2

#
#   Declaring and initialising constants that will be used in the program.
#
board_size:                 # To store the size of the board.
    .word   0

grid:
    .space  576

row_sums_value:             # to store the row sums
    .space  50

column_sums_value:          # to store the row sums
    .space  50

board_input:
    .space  50

horizontal_grid_dash:   
    .asciiz "-------------"

horizontal_grid_plus:
    .asciiz "+"

vertical_grid_bar:
    .asciiz "|"

banner_heading:
    .asciiz "******************\n"    

print_banner_name:
    .asciiz "**     TENTS    **\n"


initial_puzzle_heading:
    .asciiz "Initial Puzzle\n"

final_puzzle_heading:
    .asciiz "Final Puzzle\n"

newLine:
	.asciiz "\n"

space:
    .asciiz " "

err_impossible_message:
    .asciiz "Impossible Puzzle\n"

err_invalid_board_size:
    .asciiz "Invalid board size, Tents terminating\n"

err_sum_value:
    .asciiz "Illegal sum value, Tents terminating\n"

err_board_char:
    .asciiz "Illegal board character, Tents terminating\n"


    .text
        #
        # Global routines
        #
    
    .globl main



main:

    # storing all the $s registers

    addi    $sp, $sp,-FRAMESIZE_40
    sw      $ra, -4+FRAMESIZE_40($sp)
    sw      $s7, -8+FRAMESIZE_40($sp)        
    sw      $s6, -12+FRAMESIZE_40($sp)
    sw      $s5, -16+FRAMESIZE_40($sp)
    sw      $s4, -20+FRAMESIZE_40($sp)
    sw      $s3, -24+FRAMESIZE_40($sp)
    sw      $s2, -28+FRAMESIZE_40($sp)
    sw      $s1, -32+FRAMESIZE_40($sp)
    sw      $s0, -36+FRAMESIZE_40($sp)


#
#   Prints the banner and a new line at the end
#
print_banner:
    li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall

    li  $v0, PRINT_STRING
    la  $a0, banner_heading
    syscall

    li  $v0, PRINT_STRING
    la  $a0, print_banner_name
    syscall

    li  $v0, PRINT_STRING
    la  $a0, banner_heading
    syscall

    li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall


#
#   Function that readsd all the input from the user
#
read_input:

    #   Reads the size of the board
    li  $v0, READ_INT   
    syscall

    li  $t0, 2                  # t0 = low bound (2)

    slt $t9, $t0, $v0           # 2 < v0?
    beq $t9, $zero, bound_error
    
    li  $t0, 12                 # t1 = high bound (12)
    slt $t9, $v0, $t0           # v0 < 12
    beq $t9, $zero, bound_error

    move $s0, $v0               # s0 = BOARD SIZE

    #   Reads the row sums
    li  $v0, READ_STRING
    la  $a0, row_sums_value
    syscall

    
    # Parameters for the store_sum_values routine
    #   a0: addr pointer of the input list
    #   a1: board size
    la  $a0, row_sums_value
    move    $a1, $s0            # s0 = BOARD SIZE

    jal store_number_values     # calls the function to store the real values
    
   
    #   Reads the column sums
    li  $v0, READ_STRING
    la  $a0, column_sums_value
    add $a1, $a1, 2             # compensate the new line character for the
                                # funtion call
    syscall

    
    # Parameters for the store_sum_values routine
    #   a0: addr pointer of the input list
    #   a1: board size
    la  $a0, column_sums_value
    move    $a1, $s0            # s0 = BOARD SIZE

    jal store_number_values     # calls the function to store the real values
    
    
#   Read the inputs
#
#   Will use the grid to store each row at board size distances from each
#   other. Formula used:
#           grid + (Row counter * board size) 
#
    li  $s3, 0                  # ROW counter
    la  $s2, grid               # the addr of the grid from 0th pos
	add $a1, $a1, 2             # compensate the new line character for the
                                # funtion call
    
loop_read_inputs:
	beq $s3, $s0, done_read_inputs
    li  $v0, READ_STRING
    la  $a0, board_input
    syscall

    jal read_and_check_board_character

    la	$s1, board_input    # the current input for the board    
    mul $t9, $s3, $s0
    add $s5, $s2, $t9		# grid position 
	addi	$s3, $s3, 1
    li  $s4, 0                  # byte counter for the grid (i)


store_input_in_grid:
    beq $s4, $s0, loop_read_inputs  # i == board size? 
                                    #       read_next_input : continue 
    lb  $t3, 0($s1)
    sb  $t3, 0($s5)
    addi	$s5, $s5, 1
    addi    $s1, $s1, 1
    addi    $s4, $s4, 1     # i++
    j store_input_in_grid


done_read_inputs:
	move $a0, $s0
	jal display_board
	j done_main


#
#	Function will display the board to the user.
#	$a0: the size of the board
#		The grid, row and column values can be used by accessing the 
#		address of those labels.
#
display_board:
	addi    $sp, $sp,-FRAMESIZE_40
    sw      $ra, -4+FRAMESIZE_40($sp)
    sw      $s7, -8+FRAMESIZE_40($sp)        
    sw      $s6, -12+FRAMESIZE_40($sp)
    sw      $s5, -16+FRAMESIZE_40($sp)
    sw      $s4, -20+FRAMESIZE_40($sp)
    sw      $s3, -24+FRAMESIZE_40($sp)
    sw      $s2, -28+FRAMESIZE_40($sp)
    sw      $s1, -32+FRAMESIZE_40($sp)
    sw      $s0, -36+FRAMESIZE_40($sp)

	move $s0, $a0				# board size
	la	$s1, grid				# addr of grid
	la	$s2, row_sums_value		# addr of sum of rows
	la	$s3, column_sums_value	# addr of sum of columns
	li	$t0, 0					# ROW counter
	li	$t1, 0					# COLUMN counter

	li  $v0, PRINT_STRING
    la  $a0, initial_puzzle_heading
    syscall

	li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall

	jal	plus_dash_headings
	j	loop_display_outer

#
#	Routine function to print the plus and dashes 
#
#
plus_dash_headings:
	addi    $sp, $sp,-FRAMESIZE_40
    sw      $ra, -4+FRAMESIZE_40($sp)
    sw      $s7, -8+FRAMESIZE_40($sp)        
    sw      $s6, -12+FRAMESIZE_40($sp)
    sw      $s5, -16+FRAMESIZE_40($sp)
    sw      $s4, -20+FRAMESIZE_40($sp)
    sw      $s3, -24+FRAMESIZE_40($sp)
    sw      $s2, -28+FRAMESIZE_40($sp)
    sw      $s1, -32+FRAMESIZE_40($sp)
    sw      $s0, -36+FRAMESIZE_40($sp)

	li  $v0, PRINT_STRING
    la  $a0, horizontal_grid_plus
    syscall

	li  $v0, PRINT_STRING
    la  $a0, horizontal_grid_dash
    syscall

	li  $v0, PRINT_STRING
    la  $a0, horizontal_grid_plus
    syscall

	li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall

	lw      $ra, -4+FRAMESIZE_40($sp)
    lw      $s7, -8+FRAMESIZE_40($sp)
    lw      $s6, -12+FRAMESIZE_40($sp)
    lw      $s5, -16+FRAMESIZE_40($sp)
    lw      $s4, -20+FRAMESIZE_40($sp)
    lw      $s3, -24+FRAMESIZE_40($sp)
    lw      $s2, -28+FRAMESIZE_40($sp)
    lw      $s1, -32+FRAMESIZE_40($sp)
    lw      $s0, -36+FRAMESIZE_40($sp)
    addi    $sp, $sp, FRAMESIZE_40
	jr	$ra


#
#	This will loop through the board and print out the values in the grid
#
loop_display_outer:
	li  $v0, PRINT_STRING
    la  $a0, vertical_grid_bar
    syscall

	li  $v0, PRINT_STRING
    la  $a0, space
    syscall
	
	li	$t1, 0					# start from the begining for the counter

loop_display_inner:
	beq $t1, $s0, done_loop_display_inner
	lb	$t2, 0($s1)				# grid current value
	
	li  $v0, PRINT_CHARACTER
    move	$a0, $t2			# print current grid value
	syscall

	li  $v0, PRINT_STRING
    la  $a0, space
    syscall

    addi	$s1, $s1, 1			# next grid value
	addi	$t1, $t1, 1			# next column value
	j	loop_display_inner


done_loop_display_inner:
	li  $v0, PRINT_STRING
    la  $a0, vertical_grid_bar
    syscall

	li  $v0, PRINT_STRING
    la  $a0, space
    syscall

	lb	$t2, 0($s2)				# sum of rows current value
	
	li  $v0, PRINT_INT
    move	$a0, $t2
    syscall

	addi	$s2, $s2, 1			# next sum of rows value
	
	li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall

	addi	$t0, $t0, 1			# counter ++
	beq $t0, $s0, display_board_last
	j	loop_display_outer


display_board_last:
	jal	plus_dash_headings

	li  $v0, PRINT_STRING
    la  $a0, space
    syscall

	li  $v0, PRINT_STRING
    la  $a0, space
    syscall

	li	$t1, 0


loop_vertical_values:
	beq	$t1, $s0, done_display_board
	lb	$t2, 0($s3)				# sum of columns current value	

	li  $v0, PRINT_INT
    move	$a0, $t2
    syscall

	li  $v0, PRINT_STRING
    la  $a0, space
    syscall


	addi	$s3, $s3, 1			# next sum of columns value
	addi	$t1, $t1, 1			# counter ++

	j	loop_vertical_values
#
#   Loads back all the registers that were being used currently so that the
#   previous registers are preserved and can be used.
#
done_display_board:
	li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall
	
	li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall

	li  $v0, PRINT_STRING
    la  $a0, final_puzzle_heading
    syscall

	li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall

	lw      $ra, -4+FRAMESIZE_40($sp)
    lw      $s7, -8+FRAMESIZE_40($sp)
    lw      $s6, -12+FRAMESIZE_40($sp)
    lw      $s5, -16+FRAMESIZE_40($sp)
    lw      $s4, -20+FRAMESIZE_40($sp)
    lw      $s3, -24+FRAMESIZE_40($sp)
    lw      $s2, -28+FRAMESIZE_40($sp)
    lw      $s1, -32+FRAMESIZE_40($sp)
    lw      $s0, -36+FRAMESIZE_40($sp)
    addi    $sp, $sp, FRAMESIZE_40
	jr	$ra

#
#   Function to figure out what number is being stored and returns a list of
#   the numbers that were read. Handles errors where necessary.
#   
#   $a0:    contains the number list in ascii
#   $a1:    board size
#
store_number_values:
    addi    $sp, $sp,-FRAMESIZE_40
    sw      $ra, -4+FRAMESIZE_40($sp)
    sw      $s7, -8+FRAMESIZE_40($sp)        
    sw      $s6, -12+FRAMESIZE_40($sp)
    sw      $s5, -16+FRAMESIZE_40($sp)
    sw      $s4, -20+FRAMESIZE_40($sp)
    sw      $s3, -24+FRAMESIZE_40($sp)
    sw      $s2, -28+FRAMESIZE_40($sp)
    sw      $s1, -32+FRAMESIZE_40($sp)
    sw      $s0, -36+FRAMESIZE_40($sp)

    move    $s0, $a0        # input number is in s0
    move    $s1, $a1        # board size
    li  $t0, 48             # stores the value of 0. 
                            # subtracting the value with 0 will give me the
                            # number to do math with.
    li  $t1, 10             # to check for space and sub for null


    li  $t9, 0              # counter var


loop_storing_numbers:
    lb  $s2, 0($s0)         # takes the current byte in the list(numbers)
    beq $s2, $t1, good_to_go_storing_numbers
    sub $s2, $s2, $t0       # x - 48 = number -> s1
    sb  $s2, 0($s0)         # swapped the ascii value with the original 
                            # number
    addi    $s0, $s0, 1     # next ascii value
    addi    $t9, $t9, 1     # adds 1 to find the length of the string
    j   loop_storing_numbers


good_to_go_storing_numbers:
    sb  $zero, 0($s0)
    bne $t9, $s1, sum_value_error   # board size == calculated board size?
    li  $t1, 1
    add $t9, $t1, $t9               #   (n + 1)
    div $t9, $t9, 2                 #   (n + 1) / 2
    
    addi    $t9, $t9, 1             # upper bound for exclusion
    li  $t1, -1
    li  $t2, 0                      #  counter variable


each_digit_tester:
    beq $s1, $t2, done_store_number_values
    lb  $s2, 0($s0)                 # takes the current byte in the 
                                    # list(numbers)
    slt $t8, $t1, $s2               # -1 < x
    beq $t8, $zero, sum_value_error
    slt $t8, $s2, $t9               # x < [(n + 1) / 2]
    beq $t8, $zero, sum_value_error
    addi    $s2, $s2, 1             # go to next byte in the list(numbers)
    addi    $t2, $t2, 1     
    j   each_digit_tester


#
#   Loads back all the registers that were being used currently so that the
#   previous registers are preserved and can be used.
#
done_store_number_values:
    lw      $ra, -4+FRAMESIZE_40($sp)
    lw      $s7, -8+FRAMESIZE_40($sp)
    lw      $s6, -12+FRAMESIZE_40($sp)
    lw      $s5, -16+FRAMESIZE_40($sp)
    lw      $s4, -20+FRAMESIZE_40($sp)
    lw      $s3, -24+FRAMESIZE_40($sp)
    lw      $s2, -28+FRAMESIZE_40($sp)
    lw      $s1, -32+FRAMESIZE_40($sp)
    lw      $s0, -36+FRAMESIZE_40($sp)
    addi    $sp, $sp, FRAMESIZE_40
	jr	$ra


#
#   Function to figure out whether the input for the tents is correct.
#   The input should be only (T) and (.)
#
#   $a0: The input string of the board
#
read_and_check_board_character:
    addi    $sp, $sp,-FRAMESIZE_40
    sw      $ra, -4+FRAMESIZE_40($sp)
    sw      $s7, -8+FRAMESIZE_40($sp)        
    sw      $s6, -12+FRAMESIZE_40($sp)
    sw      $s5, -16+FRAMESIZE_40($sp)
    sw      $s4, -20+FRAMESIZE_40($sp)
    sw      $s3, -24+FRAMESIZE_40($sp)
    sw      $s2, -28+FRAMESIZE_40($sp)
    sw      $s1, -32+FRAMESIZE_40($sp)
    sw      $s0, -36+FRAMESIZE_40($sp)

    li  $t0, 46             # ASCII (.)
    li  $t1, 84             # ACSII (T)
    li  $t2, 10             # ASCII (new line character)
    move    $s0, $a0


loop_board_checker_and_store:
    lb  $s1, 0($s0)             # takes the current byte in the list(numbers)
    beq $s1, $t2, done_read_and_check_board_character
    bne $s1, $t0, next_character_check
    addi    $s0, $s0, 1         # next ascii value
    j   loop_board_checker_and_store


next_character_check:
    bne $s1, $t1, board_character_error
    addi    $s0, $s0, 1         # next ascii value
    j   loop_board_checker_and_store


#
#   Loads back all the registers that were being used currently so that the
#   previous registers are preserved and can be used.
#
done_read_and_check_board_character:
    sb  $zero, 0($s0)           # swapping new line character with 0 
    lw      $ra, -4+FRAMESIZE_40($sp)
    lw      $s7, -8+FRAMESIZE_40($sp)
    lw      $s6, -12+FRAMESIZE_40($sp)
    lw      $s5, -16+FRAMESIZE_40($sp)
    lw      $s4, -20+FRAMESIZE_40($sp)
    lw      $s3, -24+FRAMESIZE_40($sp)
    lw      $s2, -28+FRAMESIZE_40($sp)
    lw      $s1, -32+FRAMESIZE_40($sp)
    lw      $s0, -36+FRAMESIZE_40($sp)
    addi    $sp, $sp, FRAMESIZE_40
	jr	$ra

#
#   Prints the initial puzzle prompt
#
print_initial_puzzle_prompt:
    li  $v0, PRINT_STRING
    la  $a0, initial_puzzle_heading
    syscall
    
    li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall

    # jal     print_initial_board


#
#   Prints the final puzzle prompt
#
print_final_puzzle_prompt:
    li  $v0, PRINT_STRING
    la  $a0, final_puzzle_heading
    syscall

    li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall

    j   done_main


# 
#   If there is a bound error, print the err statement and go to done_main
#
bound_error:
    li  $v0, PRINT_STRING
    la  $a0, err_invalid_board_size
    syscall

    j   done_main

#
#   If there is impossible board to solve, print the err statement and go to done_main
#
impossible_message_error:
    li  $v0, PRINT_STRING
    la  $a0, err_impossible_message
    syscall

    j   done_main


#
#   If there is a sum error, print the err statement and go to done_main
#
sum_value_error:
    li  $v0, PRINT_STRING
    la  $a0, err_sum_value
    syscall

    j   done_main
    

#
#   If there is a board character error, print the err statement and go to done_main
#
board_character_error:
    li  $v0, PRINT_STRING
    la  $a0, err_board_char
    syscall

    j   done_main



#
#   This routine is called when the program is done and the stack needs
#   to remove the registers.
#
done_main:
    lw      $ra, -4+FRAMESIZE_40($sp)
    lw      $s7, -8+FRAMESIZE_40($sp)
    lw      $s6, -12+FRAMESIZE_40($sp)
    lw      $s5, -16+FRAMESIZE_40($sp)
    lw      $s4, -20+FRAMESIZE_40($sp)
    lw      $s3, -24+FRAMESIZE_40($sp)
    lw      $s2, -28+FRAMESIZE_40($sp)
    lw      $s1, -32+FRAMESIZE_40($sp)
    lw      $s0, -36+FRAMESIZE_40($sp)
    addi    $sp, $sp, FRAMESIZE_40
	jr	$ra
