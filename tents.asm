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
grid:
    .space  576

board_size:
    .space  1

tree_list:
	.space	150

row_sums_value:             # to store the row sums
    .space  50

column_sums_value:          # to store the row sums
    .space  50

board_input:
    .space  50

horizontal_grid_dash:   
    .asciiz "-"

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

    li  $t0, 1                  # t0 = low bound (2)

    slt $t9, $t0, $v0           # 1 < v0?
    beq $t9, $zero, bound_error
    
    li  $t0, 13                 # t1 = high bound (12)
    slt $t9, $v0, $t0           # v0 < 13
    beq $t9, $zero, bound_error

    move $s0, $v0               # s0 = BOARD SIZE

    la  $t0, board_size
    sb  $s0, 0($t0)

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
    beq $v0, $zero, done_main
   
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
    beq $v0, $zero, done_main

    
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
	beq	$v0, $zero, done_main

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
    li  $v0, PRINT_STRING
    la  $a0, initial_puzzle_heading
    syscall

	move    $a0, $s0
	jal display_board

    move	$a0, $s0
	jal	get_tree_positions

# Get tree_list addr and load the first position.
# Pass that as a parameter. 
    la  $a0, tree_list
    jal solve

    beq $v0, $zero, impossible_message_error

    # have the final things prompt here 

    li  $v0, PRINT_STRING
    la  $a0, final_puzzle_heading
    syscall

    la  $t0, board_size
    lb  $a0, 0($t0)             # gets the size of the board
    jal display_board

    j   done_main


#
#   Routine checks for the current cell's neighbors and tries to find a tent.
#   If a tent is present, it will return a 0, otherwise a 1. This will indicate
#   that the current cell can have a tent.
#
#   $a0: position of the current cell.
#
#   return: 0 -> no tent found near the current position
#           1 -> tent found near current position   
#
check_neighbors:
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

    la  $s0, grid           # starting addr of the grid
    move    $s1, $a0        # the current position of the cell in check
    li  $s2, 65             # ASCII (A) -> tent
    la  $s3, board_size     # gets the size of the board
    lb  $s3, 0($s3)

start_check:
    # checks if the pos has a left value
    move    $a0, $s1        
    jal left_checker

    bne $v0, $zero, left_present
    
    # no left position is present
    
    # checks if the pos has an up value when no left value
    move    $a0, $s1
    jal up_checker

    bne $v0, $zero, up_present

    move    $t1, $s1
    addi    $t1, $t1, 1     # right position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present
    
    move    $t1, $s1
    add $t1, $t1, $s3       # down position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    addi    $t1, $t1, 1     # down right corner position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    j   no_tent_present
    
    
up_present:
    move    $t1, $s1
    sub $t1, $t1, $s3       # up position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    # checks if the pos has a right value when there is up
    
    # Since there is no left, there is definitely a right value
    move    $t1, $s1
    addi    $t1, $t1, 1     # right position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    move    $t1, $s1
    sub $t1, $t1, $s3       # right up corner position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    # checks if the pos has a down value when there is up and right 
    move    $a0, $s1
    jal down_checker

    bne $v0, $zero, right_up_down_present

    # no down position is present when up and right are present
    j   no_tent_present
    

right_up_down_present:
    move    $t1, $s1
    add $t1, $t1, $s3       # down position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    move    $t1, $s1
    addi    $t1, $t1, 1     # right down corner position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    j   no_tent_present


left_present:
    move    $t1, $s1
    addi    $t1, $t1, -1    # left position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    # checks if the pos has an up value when left value present
    move    $a0, $s1        
    jal up_checker

    bne $v0, $zero, up_left_present
    
    # no up value present when left present

    # if there is no up value, there is definitely a down value
    move    $t1, $s1
    add $t1, $t1, $s3       # down position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    addi    $t1, $t1, -1    # left down corner position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present
    
    # checks if the pos has a right value when there is down and left
    move    $a0, $s1
    jal right_checker

    bne $v0, $zero, right_down_left_present
    
    # no right value present when there is down and left
    j   no_tent_present


right_down_left_present:
    move    $t1, $s1
    addi    $t1, $t1, 1     # right position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present
    
    add $t1, $t1, $s3       # right down corner position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present
    
    j   no_tent_present


up_left_present:
    move    $t1, $s1
    sub $t1, $t1, $s3       # up position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present
    
    addi    $t1, $t1, -1    # left up corner position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present
    

    # checks if the pos has a right value when there is up and left
    move    $a0, $s1
    jal right_checker

    bne $v0, $zero, right_up_left_present

    # no right value present when up and left present
    move    $a0, $s1
    jal down_checker

    bne $v0, $zero, down_up_left_present

    j   no_tent_present


down_up_left_present:
    move    $t1, $s1
    add $t1, $t1, $s3       # down position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    addi    $t1, $t1, -1    # left down corner position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    # no down value present when up and left present
    j   no_tent_present


right_up_left_present:
    move    $t1, $s1
    addi    $t1, $t1, 1     # right position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present
    
    sub $t1, $t1, $s3       # right up corner position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present


    # checks if the pos has a down value when there is up and left and right
    move    $a0, $s1
    jal down_checker

    bne $v0, $zero, down_right_up_left_present

    # no down value present when right, up and left present
    j   no_tent_present


down_right_up_left_present:
    move    $t1, $s1
    add $t1, $t1, $s3       # down position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    addi    $t1, $t1, -1    # left down corner position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    addi    $t1, $t1, 2     # right down corner position
    la  $t4, grid           # load the addr of the grid
    add $t4, $t1, $t4       # get the position on the board
    lb  $t2, 0($t4)         # getting the value
    beq $t2, $s2, tent_present

    j   no_tent_present    


tent_present:
    li  $v0, 1              # tent found near the position
    j   exit


no_tent_present:
    move    $v0, $zero      # no tent present near the position
    j   exit


#
#   Loads back all the registers that were being used currently so that the
#   previous registers are preserved and can be used.
#
done_check_neighbors:
    j   exit


#
#   Routine responsible to use the method of back tracking and figure out a way
#   to solve the board, if the board is solvable. It returns 1 if the board has
#   been solved otherwise a 0. This will then make the board go through added
#   recursive calls till all the future cases have been checked.
#   
#   $a0:    addr of tree list
#   
#   return: 0 -> no result for current configuration
#           1 -> board solved
#
solve:
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

    move    $s1, $a0            # starting addr for the tree_list
                                # this will allow me to not go about tracing
                                # back the memory addr for the tree_list    
    li  $t9, -1                 # limit for the tree_list

loop_solve:
    lb  $s3, 0($s1)             # position of the tree_list
    beq $s3, $t9, done_solve
    

check_left_exists:
    # check if left pos exist
    move    $a0, $s3
    jal left_checker
    bne $v0, $zero, left_exists
    lb  $s3, 0($s1)             # position of the tree_list
    j   check_up_exists_true


check_up_exists:
    # check if up pos exist
    addi    $s3, $s3, 1

check_up_exists_true:
    move    $a0, $s3
    jal up_checker
    bne $v0, $zero, up_exists
    lb  $s3, 0($s1)             # position of the tree_list
    j   check_right_exists_true


check_right_exists:
    # check if right pos exist
    la  $t0, board_size
    lb  $t0, 0($t0)
    add $s3, $s3, $t0

check_right_exists_true:
    move    $a0, $s3
    jal right_checker
    bne $v0, $zero, right_exists
    lb  $s3, 0($s1)             # position of the tree_list
    j   check_down_exists_true


check_down_exists:
    # check if down pos exist
    addi    $s3, $s3, -1

check_down_exists_true:
    move    $a0, $s3
    jal down_checker
    bne $v0, $zero, down_exists


no_tent_creation:    
    li  $v0, 0
    j   exit


left_exists:
    # s3 -> position I will be using
    
    la  $s2, grid                   # starting addr for the grid
    add $s2, $s2, $s3               # get the tree position on the grid
    addi    $s3, $s3, -1            # goes to left position
    addi    $s2, $s2, -1            # goes to left position of the grid
    lb  $t0, 0($s2)                 # loads the left position from the grid
    
    li  $t1, 84                     # ASCII (T) -> tree
    beq $t0, $t1, check_up_exists   # t0 == tree?
    li  $t1, 65                     # ASCII (A) -> tent  
    beq $t0, $t1, check_up_exists   # t0 == tent?

    move    $a0, $s3
    jal check_neighbors

    bne $v0, $zero, check_up_exists  # go to another tree position
    
    # check if the tent can be added 
    # by looking at the row and column values
    la  $t0, row_sums_value         # row values
    la  $t1, column_sums_value      # column values
    la  $s0, board_size             # board size
    lb  $s0, 0($s0)                 
    
    rem $t2, $s3, $s0               # pos % board_size = col number
    div $t3, $s3, $s0               # pos / board_size = row number

    add $s6, $t0, $t3               # to get the required column addr
    add $s7, $t1, $t2               # to get the required row addr

    lb  $t0, 0($s6)                 # the value of the required row
    lb  $t1, 0($s7)                 # the value of the required column

    slt $t4, $zero, $t0             # 0 < col? 1 : 0
    beq $t4, $zero, check_up_exists # col == 0 -> go to the next side for the
                                    # tree
    
    slt $t4, $zero, $t1             # 0 < row? 1 : 0
    beq $t4, $zero, check_up_exists # row == 0 -> go to the next side for the
                                    # tree

    addi    $t0, $t0, -1            #   col--
    addi    $t1, $t1, -1            #   row--
    sb  $t0, 0($s6)                 # store the updated value of that col
    sb  $t1, 0($s7)                 # store the updated value of that row 
    move    $s4, $t0                # save col
    move    $s5, $t1                # save row
    li  $t1, 65                     # ASCII (A) -> tent  
    sb  $t1, 0($s2)                 # store a tent at the current position
    
##
    la  $t0, board_size
    lb  $a0, 0($t0)             # gets the size of the board
    jal display_board
##
    addi    $a0, $s1, 1             # next tree position 
    jal solve 

    bne $v0, $zero, done_solve

    # changing back to the previous board configuration
    move    $t0, $s4                # load col
    move    $t1, $s5                # load row
    addi    $t0, $t0, 1             #   col++
    addi    $t1, $t1, 1             #   row++
    sb  $t0, 0($s6)                 # store the updated value of that col
    sb  $t1, 0($s7)                 # store the updated value of that row 
    li  $t0, 46                     # ASCII (.)
    sb  $t0, 0($s2)                 # store a tent at the current position
   
##
    la  $t0, board_size
    lb  $a0, 0($t0)             # gets the size of the board
    jal display_board
##
    move    $a0, $s1             # previous tree position 
    j   check_up_exists


up_exists:
    # s3 -> position I will be using
    
    la  $s2, grid                   # starting addr for the grid
    add $s2, $s2, $s3               # get the tree position on the grid
    la  $t0, board_size
    lb  $t0, 0($t0)                 # got the board size for position change
    sub $s2, $s2, $t0               # goes up 1 position on the grid
    sub $s3, $s3, $t0               # goes up 1 position
    lb  $t0, 0($s2)                 # loads the up position from the grid
    
    li  $t1, 84                 # ASCII (T) -> tree
    beq $t0, $t1, check_right_exists   # t0 == tree?
    li  $t1, 65                 # ASCII (A) -> tent  
    beq $t0, $t1, check_right_exists   # t0 == tent?
    
    move    $a0, $s3
    jal check_neighbors

    bne $v0, $zero, check_right_exists  # go to another tree position
    
    # check if the tent can be added 
    # by looking at the row and column values
    la  $t0, row_sums_value         # row values
    la  $t1, column_sums_value      # column values
    la  $s0, board_size             # board size
    lb  $s0, 0($s0)                 
    
    rem $t2, $s3, $s0               # pos % board_size = col number
    div $t3, $s3, $s0               # pos / board_size = row number

    add $s6, $t0, $t3               # to get the required column addr
    add $s7, $t1, $t2               # to get the required row addr

    lb  $t0, 0($s6)                 # the value of the required row
    lb  $t1, 0($s7)                 # the value of the required column

    slt $t4, $zero, $t0             # 0 < col? 1 : 0
    beq $t4, $zero, check_right_exists  # col == 0 -> go to the next 
                                        # side for the tree
    
    slt $t4, $zero, $t1             # 0 < row? 1 : 0
    beq $t4, $zero, check_right_exists  # row == 0 -> go to the next 
                                        # side for the tree

    addi    $t0, $t0, -1            #   col--
    addi    $t1, $t1, -1            #   row--
    sb  $t0, 0($s6)                 # store the updated value of that col
    sb  $t1, 0($s7)                 # store the updated value of that row 
    move    $s4, $t0                # save col
    move    $s5, $t1                # save row
    li  $t1, 65                     # ASCII (A) -> tent  
    sb  $t1, 0($s2)                 # store a tent at the current position

##
    la  $t0, board_size
    lb  $a0, 0($t0)             # gets the size of the board
    jal display_board
##
    addi    $a0, $s1, 1             # next tree position 
    jal solve 

    bne $v0, $zero, done_solve

    # changing back to the previous board configuration
    move    $t0, $s4                # load col
    move    $t1, $s5                # load row
    addi    $t0, $t0, 1             #   col++
    addi    $t1, $t1, 1             #   row++
    sb  $t0, 0($s6)                 # store the updated value of that col
    sb  $t1, 0($s7)                 # store the updated value of that row 
    li  $t0, 46                     # ASCII (.)
    sb  $t0, 0($s2)                 # store a tent at the current position
    
##
    la  $t0, board_size
    lb  $a0, 0($t0)             # gets the size of the board
    jal display_board
##
    move    $a0, $s1            # previous tree position 
    j   check_right_exists


right_exists:
    # s3 -> position I will be using
    
    la  $s2, grid                   # starting addr for the grid
    add $s2, $s2, $s3               # get the tree position on the grid
    addi    $s3, $s3, 1             # goes to the right position
    addi    $s2, $s2, 1             # goes to right position on the grid
    lb  $t0, 0($s2)                 # loads the left position from the grid
    li  $t1, 84                     # ASCII (T) -> tree
    beq $t0, $t1, check_down_exists # t0 == tree?
    li  $t1, 65                     # ASCII (A) -> tent  
    beq $t0, $t1, check_down_exists # t0 == tent?
    
    move    $a0, $s3
    jal check_neighbors

    bne $v0, $zero, check_down_exists  # go to another tree position
    
    # check if the tent can be added 
    # by looking at the row and column values
    la  $t0, row_sums_value         # row values
    la  $t1, column_sums_value      # column values
    la  $s0, board_size             # board size
    lb  $s0, 0($s0)                 
    
    rem $t2, $s3, $s0               # pos % board_size = col number
    div $t3, $s3, $s0               # pos / board_size = row number

    add $s6, $t0, $t3               # to get the required column addr
    add $s7, $t1, $t2               # to get the required row addr

    lb  $t0, 0($s6)                 # the value of the required row
    lb  $t1, 0($s7)                 # the value of the required column

    slt $t4, $zero, $t0             # 0 < col? 1 : 0
    beq $t4, $zero, check_down_exists   # col == 0 -> go to the next 
                                        # side for the tree
    
    slt $t4, $zero, $t1             # 0 < row? 1 : 0
    beq $t4, $zero, check_down_exists   # row == 0 -> go to the next 
                                        # side for the tree

    addi    $t0, $t0, -1            #   col--
    addi    $t1, $t1, -1            #   row--
    sb  $t0, 0($s6)                 # store the updated value of that col
    sb  $t1, 0($s7)                 # store the updated value of that row 
    move    $s4, $t0                # save col
    move    $s5, $t1                # save row
    li  $t1, 65                     # ASCII (A) -> tent  
    sb  $t1, 0($s2)                 # store a tent at the current position

##
    la  $t0, board_size
    lb  $a0, 0($t0)             # gets the size of the board
    jal display_board
##
    addi    $a0, $s1, 1             # next tree position 
    jal solve 

    bne $v0, $zero, done_solve

    # changing back to the previous board configuration
    move    $t0, $s4                # load col
    move    $t1, $s5                # load row
    addi    $t0, $t0, 1             #   col++
    addi    $t1, $t1, 1             #   row++
    sb  $t0, 0($s6)                 # store the updated value of that col
    sb  $t1, 0($s7)                 # store the updated value of that row 
    li  $t0, 46                     # ASCII (.)
    sb  $t0, 0($s2)                 # store a tent at the current position
    
##
    la  $t0, board_size
    lb  $a0, 0($t0)             # gets the size of the board
    jal display_board
##

    move    $a0, $s1            # previous tree position 
    j   check_down_exists


down_exists:
    # s3 -> position I will be using
    
    la  $s2, grid                   # starting addr for the grid
    add $s2, $s2, $s3               # get the tree position on the grid
    la  $t0, board_size
    lb  $t0, 0($t0)                 # got the board size for position change
    add $s2, $s2, $t0               # goes down 1 position on the grid
    add $s3, $s3, $t0               # goes down 1 position
    lb  $t0, 0($s2)                 # loads the down position from the grid
    li  $t1, 84                     # ASCII (T) -> tree
    beq $t0, $t1, no_tent_creation  # t0 == tree?
    li  $t1, 65                     # ASCII (A) -> tent  
    beq $t0, $t1, no_tent_creation  # t0 == tent?

    move    $a0, $s3
    jal check_neighbors

    bne $v0, $zero, no_tent_creation  # go to another tree position
    
    # check if the tent can be added 
    # by looking at the row and column values
    la  $t0, row_sums_value         # row values
    la  $t1, column_sums_value      # column values
    la  $s0, board_size             # board size
    lb  $s0, 0($s0)                 
    
    rem $t2, $s3, $s0               # pos % board_size = col number
    div $t3, $s3, $s0               # pos / board_size = row number

    add $s6, $t0, $t3               # to get the required column addr
    add $s7, $t1, $t2               # to get the required row addr

    lb  $t0, 0($s6)                 # the value of the required row
    lb  $t1, 0($s7)                 # the value of the required column

    slt $t4, $zero, $t0             # 0 < col? 1 : 0
    beq $t4, $zero, no_tent_creation    # col == 0 -> go to the next 
                                        # side for the tree
    
    slt $t4, $zero, $t1             # 0 < row? 1 : 0
    beq $t4, $zero, no_tent_creation    # row == 0 -> go to the next 
                                        # side for the tree

    addi    $t0, $t0, -1            #   col--
    addi    $t1, $t1, -1            #   row--
    sb  $t0, 0($s6)                 # store the updated value of that col
    sb  $t1, 0($s7)                 # store the updated value of that row 
    move    $s4, $t0                # save col
    move    $s5, $t1                # save row
    li  $t1, 65                     # ASCII (A) -> tent  
    sb  $t1, 0($s2)                 # store a tent at the current position

##
    la  $t0, board_size
    lb  $a0, 0($t0)             # gets the size of the board
    jal display_board
##
    addi    $a0, $s1, 1             # next tree position 
    jal solve 

    bne $v0, $zero, done_solve

    # changing back to the previous board configuration
    move    $t0, $s4                # load col
    move    $t1, $s5                # load row
    addi    $t0, $t0, 1             #   col++
    addi    $t1, $t1, 1             #   row++
    sb  $t0, 0($s6)                 # store the updated value of that col
    sb  $t1, 0($s7)                 # store the updated value of that row 
    li  $t0, 46                     # ASCII (.)
    sb  $t0, 0($s2)                 # store a tent at the current position
    
##
    la  $t0, board_size
    lb  $a0, 0($t0)             # gets the size of the board
    jal display_board
##

    move    $a0, $s1            # previous tree position 
    j   no_tent_creation

#
#   Loads back all the registers that were being used currently so that the
#   previous registers are preserved and can be used.
#
done_solve:
    li  $v0, 1
    j   exit


#
#   Routine that takes the index and the size and checks if 
#   the cell has a left space
#           index % size != 0? 1 : 0
#               1: (left space present)  
#               0: (left space not there)              
#   $a0: current index
#
left_checker:
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

    la  $t0, board_size
    lb  $s0, 0($t0)
    move    $s1, $a0            # index on the board
    
    rem $t3, $s1, $s0           # index % board size
    bne $t3, $zero, return_one
    
    move    $v0, $zero
    j   exit


#
#   Routine that takes the index and the size and checks if 
#   the cell has a down space
#           (index + size) / size != size? 1 : 0
#               1: (down space present)  
#               0: (down space not there)              
#   $a0: current index
#
down_checker:
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

    la  $t0, board_size
    lb  $s0, 0($t0)
    move    $s1, $a0            # index on the board    

    add $t3, $s1, $s0           # index + size
    div $t3, $t3, $s0           # (index + size) / size
    bne $t3, $s0, return_one    # (index + size) / size != size?
    
    move    $v0, $zero
    j   exit


#
#   Routine that takes the index and the size and checks if 
#   the cell has a up space
#           index - size < 0? 0 : 1
#               0: (up space not there)
#               1: (up space present)  
#   $a0: current index
#
up_checker:
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

    la  $t0, board_size
    lb  $s0, 0($t0)
    move    $s1, $a0            # index on the board
    li  $s2, 1

    sub $t3, $s1, $s0           # index - size
    sra $t3, $t3, 31            # shifting 31 bits to get the sign bit -> 0, 1
                                # 0 = +ve number
                                # -1 = -ve number
    # slt $t3, $t3, $zero         # (index - size) < 0?
    beq $t3, $zero, return_one    # t3 != 0? 1 : 0
        
    move    $v0, $zero
    j   exit


#
#   Routine the takes the index and the size and checks if
#   the cell has a right space
#           (index + 1) % size != 0? 1 : 0
#               1: (right space present)  
#               0: (right space not there)
#   $a0: current index
#
right_checker:
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

    la  $t0, board_size
    lb  $s0, 0($t0)
    move    $s1, $a0            # index on the board
    
    addi    $t3, $s1, 1         # index + 1
    rem $t3, $t3, $s0           # (index + 1) % size
    bne $t3, $zero, return_one
        
    move    $v0, $zero
    j   exit

    
return_one:
    li  $v0, 1
    j   exit


#
#   Routine that gets all the tree positions in the official grid
#	and stores it in the tree_list label.
#   $a0:    size of board
#
get_tree_positions:
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

    move    $s0, $a0        # board size
    mul	$s0, $s0, $s0		# loop limit
	la  $s1, grid           # official grid starting addr
	la	$s2, tree_list		# addr to store the list of trees
	li	$t0, 0				# cell counter (i)
    li	$t1, -1				# ending number
	li  $t2, 84             # ACSII (T)


loop_get_tree_positions:
	beq	$s0, $t0, done_get_tree_positions
	lb	$t3, 0($s1)			# gets the value in the current cell
	beq	$t3, $t2, add_to_tree_list
	j	continue_loop_get_tree_positions


add_to_tree_list:
	sb	$t0, 0($s2)			# stores the position number of the tree in the
                            # tree_list
	addi    $s2, $s2, 1     # next position for the tree_list


continue_loop_get_tree_positions:
	addi	$t0, $t0, 1     # i++
	addi	$s1, $s1, 1     # next position for the grid
	j	loop_get_tree_positions


#
#   Loads back all the registers that were being used currently so that the
#   previous registers are preserved and can be used.
#
done_get_tree_positions:
    sb	$t1, 0($s2)
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
#   Routine checks whether the entered tree position 
#
#
neighbours_checker:



#
#   Loads back all the registers that were being used currently so that the
#   previous registers are preserved and can be used.
#
done_neighbours_checker:
	
    # j done_main


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
	li	$t1, 0					# COLUMN counter

	li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall

    move    $a0, $s0
	jal	plus_dash_headings
	
    j	loop_display_outer

#
#	Routine function to print the plus and dashes 
#   $a0: board size
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

    move    $s0, $a0
    add $s0, $s0, $s0
    addi    $s0, $s0, 1
    li  $t0, 0
    
	li  $v0, PRINT_STRING
    la  $a0, horizontal_grid_plus
    syscall


loop_dashes:
    beq $t0, $s0, done_loop_dashes
	li  $v0, PRINT_STRING
    la  $a0, horizontal_grid_dash
    syscall

    addi    $t0, $t0, 1
    j   loop_dashes


done_loop_dashes:
	li  $v0, PRINT_STRING
    la  $a0, horizontal_grid_plus
    syscall

	li  $v0, PRINT_STRING
    la  $a0, newLine
    syscall

    li	$t0, 0					# ROW counter
	
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
    move    $a0, $s0
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

    move    $s0, $a0        # input number list is in s0
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
    move    $s0, $a0        # input number list is in s0


each_digit_tester:
    beq $s1, $t2, done_store_number_values
    lb  $s2, 0($s0)                 # takes the current byte in the 
                                    # list(numbers)
    slt $t8, $t1, $s2               # -1 < x
    beq $t8, $zero, sum_value_error
    slt $t8, $s2, $t9               # x < [(n + 1) / 2]
    beq $t8, $zero, sum_value_error
    addi    $s0, $s0, 1             # go to next byte in the list(numbers)
    addi    $t2, $t2, 1     
    j   each_digit_tester

#
#   If there is a sum error, print the err statement and go to done_main
#
sum_value_error:
    li  $v0, PRINT_STRING
    la  $a0, err_sum_value
    syscall

	move	$v0, $zero
    j   exit


#
#   Loads back all the registers that were being used currently so that the
#   previous registers are preserved and can be used.
#
done_store_number_values:
	li	$t0, 1
	move $v0, $t0


exit:
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
#	Routine to get the specific index from the grid
#	$a0: row value
#	$a1: col value
#	$a2: size of board
#
#		return: The required value from the grid.
#
get_index:
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

	move	$s0, $a0				# row value
	move	$s1, $a1				# col value
	move	$s2, $a2				# board size
	la	$t0, grid

	mul	$t1, $s0, $s2				# row * board size
	add	$t1, $s1, $t1				# (row * board size) + column
	add	$t0, $t0, $t1

	lb	$v0, 0($t0)					# return required value from grid.

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
#   If there is a board character error, print the err statement and go to 
#   done_main
#
board_character_error:
    li  $v0, PRINT_STRING
    la  $a0, err_board_char
    syscall

	move	$v0, $zero

	j	exit
	


#
#   Loads back all the registers that were being used currently so that the
#   previous registers are preserved and can be used.
#
done_read_and_check_board_character:
    sb  $zero, 0($s0)           # swapping new line character with 0 
    li $t0, 1
	move $v0, $t0
	j	exit


# 
#   If there is a bound error, print the err statement and go to done_main
#
bound_error:
    li  $v0, PRINT_STRING
    la  $a0, err_invalid_board_size
    syscall

    j   done_main

#
#   If there is impossible board to solve, print the err statement and go to 
#   done_main
#
impossible_message_error:
    li  $v0, PRINT_STRING
    la  $a0, err_impossible_message
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
