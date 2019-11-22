#
# Author:   Nikhil Raina
# 
#
# Description:  T
#
#
#
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
board_size:             # To store the size of the board.
    .word   0


row_sums_value:         # to store the row sums
    .space  20

column_sums_value:      # to store the row sums
    .space  20

horizontal_grid_dash:   
    .asciiz "-"

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

    li  $t0, 2              # t0 = low bound (2)

    slt $t9, $t0, $v0       # 2 < s0?
    beq $t9, $zero, bound_error
    
    li  $t0, 12             # t1 = high bound (12)
    slt $t9, $v0, $t0       # s0 < 12
    beq $t9, $zero, bound_error

    move    $s0, $v0        # s0 = BOARD SIZE


    #   Reads the row sums
    li  $v0, READ_STRING
    la  $a0, row_sums_value
    li  $a1, 20             # has the length of the sum or the rows
    syscall

    move    $t0, $a0

    li  $v0, PRINT_STRING
    la  $a0, row_sums_value
    syscall

    #   Reads the column sums


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
