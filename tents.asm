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


row_sums_value:             # to store the row sums
    .space  50

column_sums_value:          # to store the row sums
    .space  50

initial_sum_values:
    .space  50

horizontal_grid_dash:   
    .asciiz "-------------"

horizontal_grid_plus:
    .asciiz "+"

vertical_grid_bar:
    .asciiz " | "

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

    sw  $v0, -40+FRAMESIZE_40($sp)  # added the boardsize to the stack

    move $s0, $v0

    #   Reads the row sums
    li  $v0, READ_STRING
    la  $a0, initial_sum_values
    syscall

    
    # Parameters for the store_sum_values routine
    #   a0: addr pointer of the input list
    #   a1: board size
    la  $a0, initial_sum_values
    move    $a1, $s0            # a1 = BOARD SIZE

    jal store_number_values     # calls the function to store the real values
    sw  $v0, -44+FRAMESIZE_40($sp)  # store the sum of rows in the stack.
    

    li  $v0, PRINT_STRING
    la  $a0, initial_sum_values
    syscall
    
   
    #   Reads the column sums
    li  $v0, READ_STRING
    la  $a0, initial_sum_values
    add $a1, $a1, 2             # compensate the new line character for the
                                # funtion call
    syscall

    
    # Parameters for the store_sum_values routine
    #   a0: addr pointer of the input list
    #   a1: board size
    la  $a0, initial_sum_values
    move    $a1, $s0            # a1 = BOARD SIZE

    jal store_number_values     # calls the function to store the real values
    sw  $v0, -48+FRAMESIZE_40($sp)  # store the sum of rows in the stack.
    



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
    # beq $s2, $zero, good_to_go_storing_numbers
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
    beq $s1, $t2, good_to_go_storing_numbers_continue
    lb  $s2, 0($s0)                 # takes the current byte in the 
                                    # list(numbers)
    slt $t8, $t1, $s2               # -1 < x
    beq $t8, $zero, sum_value_error
    slt $t8, $s2, $t9               # x < [(n + 1) / 2]
    beq $t8, $zero, sum_value_error
    addi    $s2, $s2, 1             # go to next byte in the list(numbers)
    addi    $t2, $t2, 1     
    j   each_digit_tester

good_to_go_storing_numbers_continue:
    move    $v0, $s0                # the new list is getting returned
    j   done_store_number_values

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
impossinle_message_error:
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
