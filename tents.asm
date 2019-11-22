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

# banner_heading:
#     .asciiz "******************"    

# banner_heading:
#     .asciiz "**     TENTS    **"

initial_puzzle_heading:
    .asciiz "Initial Puzzle"

final_puzzle_heading:
    .asciiz "Final Puzzle"

newLine:
	.asciiz "\n"

err_impossible_message:
    .asciiz "Impossible Puzzle"

err_invalid_board_size:
    .asciiz "Invalid board size, Tents terminating"

err_sum_value:
    .asciiz "Illegal sum value, Tents terminating"

err_board_char:
    .asciiz "Illegal board character, Tents terminating"


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
#   Function that readsd all the input from the user
#
read_input:

    #   Reads the size of the board
    li  $v0, READ_INT   
    syscall
    move    $s0, $v0        # s0 = BOARD SIZE

    li  $t0, 2              # t0 = low bound (2)

    slt $t9, $t0, $s0       # 2 < s0?
    bne $t9, $zero, bound_error
    
    li  $t0, 12             # t1 = high bound (12)
    slt $t9, $s0, $t0       # s0 < 12
    bne $t9, $zero, bound_error


    #   Reads the row sums
    li  $v0, READ_STRING
    la  $a0, row_sums_value
    li  $a1, 20
    syscall



    #   Reads the column sums


# 
#   If there is a bound error, print the err statement and go to done_main
#
bound_error:
    li  $v0, PRINT_STRING
    la  $a0, err_invalid_board_size
    syscall

    li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall
    
    j   done_main




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
