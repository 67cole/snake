########################################################################
# COMP1521 21T2 -- Assignment 1 -- Snake!
# <https://www.cse.unsw.edu.au/~cs1521/21T2/assignments/ass1/index.html>
#
#
# !!! IMPORTANT !!!
# Before starting work on the assignment, make sure you set your tab-width to 8!
# For instructions, see: https://www.cse.unsw.edu.au/~cs1521/21T2/resources/mips-editors.html
# !!! IMPORTANT !!!
#
#
# This program was written by YOUR-NAME-HERE (z5555555)
# on INSERT-DATE-HERE
#
# Version 1.0 (2021-06-24): Team COMP1521 <cs1521@cse.unsw.edu.au>
#

	# Requires:
	# - [no external symbols]
	#
	# Provides:
	# - Global variables:
	.globl	symbols
	.globl	grid
	.globl	snake_body_row
	.globl	snake_body_col
	.globl	snake_body_len
	.globl	snake_growth
	.globl	snake_tail

	# - Utility global variables:
	.globl	last_direction
	.globl	rand_seed
	.globl  input_direction__buf

	# - Functions for you to implement
	.globl	main
	.globl	init_snake
	.globl	update_apple
	.globl	move_snake_in_grid
	.globl	move_snake_in_array

	# - Utility functions provided for you
	.globl	set_snake
	.globl  set_snake_grid
	.globl	set_snake_array
	.globl  print_grid
	.globl	input_direction
	.globl	get_d_row
	.globl	get_d_col
	.globl	seed_rng
	.globl	rand_value


########################################################################
# Constant definitions.

N_COLS          = 15
N_ROWS          = 15
MAX_SNAKE_LEN   = N_COLS * N_ROWS

EMPTY           = 0
SNAKE_HEAD      = 1
SNAKE_BODY      = 2
APPLE           = 3

NORTH       = 0
EAST        = 1
SOUTH       = 2
WEST        = 3


########################################################################
# .DATA
	.data

# const char symbols[4] = {'.', '#', 'o', '@'};
symbols:
	.byte	'.', '#', 'o', '@'

	.align 2
# int8_t grid[N_ROWS][N_COLS] = { EMPTY };
grid:
	.space	N_ROWS * N_COLS

	.align 2
# int8_t snake_body_row[MAX_SNAKE_LEN] = { EMPTY };
snake_body_row:
	.space	MAX_SNAKE_LEN

	.align 2
# int8_t snake_body_col[MAX_SNAKE_LEN] = { EMPTY };
snake_body_col:
	.space	MAX_SNAKE_LEN

# int snake_body_len = 0;
snake_body_len:
	.word	0

# int snake_growth = 0;
snake_growth:
	.word	0

# int snake_tail = 0;
snake_tail:
	.word	0

# Game over prompt, for your convenience...
main__game_over:
	.asciiz	"Game over! Your score was "


########################################################################
#
# Your journey begins here, intrepid adventurer!
#
# Implement the following 6 functions, and check these boxes as you
# finish implementing each function
#
#  - [X] main
#  - [X] init_snake
#  - [X] update_apple
#  - [X] update_snake
#  - [X] move_snake_in_grid
#  - [X] move_snake_in_array
#



########################################################################
# .TEXT <main>
	.text
main:

	# Args:     void
	# Returns:
	#   - $v0: int
	#
	# Frame:    $ra, [...]
	# Uses:	    $a0, $t0, $v0 
	# Clobbers: $a0, $t0, $v0 
	#
	# Locals:
	#   
	#  
	# Structure:
	#   main
	#   -> [prologue]
	#   -> main__body
	#   -> main__body__loop
	#   -> [epilogue]

	# Code:
main__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

main__body:

	jal	init_snake
	jal	update_apple

main__body__loop:
	# While loop
	jal	print_grid
	jal	input_direction

	move	$a0, $v0
	jal	update_snake
	move	$t0, $v0

	bnez	$t0, main__body__loop

	# Calculating score integer
	lw	$t0, snake_body_len
	div	$t0, $t0, 3


	# Printing game finished
	la   	$a0, main__game_over   
    	li  	$v0, 4
    	syscall

	move 	$a0, $t0       
    	li   	$v0, 1
   	syscall

    	li   	$a0, '\n'      
    	li   	$v0, 11
    	syscall


main__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 0
	jr	$ra			# return 0;



########################################################################
# .TEXT <init_snake>
	.text
init_snake:

	# Args:     void
	# Returns:  void
	#
	# Frame:    $ra, [...]
	# Uses:     $a0, $a1, $a2
	# Clobbers: $a0, $a1, $a2
	#
	# Locals:
	#
	# Structure:
	#   init_snake
	#   -> [prologue]
	#   -> body
	#   -> [epilogue]

	# Code:
init_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

init_snake__body:

	# Setting set_snake(7, 7, SNAKE_HEAD);
	li	$a0, 7
	li	$a1, 7
	li	$a2, SNAKE_HEAD
	jal     set_snake

	# Setting set_snake(7, 6, SNAKE_BODY);
	li	$a0, 7
	li	$a1, 6
	li 	$a2, SNAKE_BODY
	jal	set_snake

	# Setting set_snake(7, 5, SNAKE_BODY);
	li	$a0, 7
	li	$a1, 5
	li 	$a2, SNAKE_BODY
	jal	set_snake

	# Setting set_snake(7, 4, SNAKE_BODY);
	li	$a0, 7
	li	$a1, 4
	li 	$a2, SNAKE_BODY
	jal	set_snake


init_snake__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	jr	$ra			# return;



########################################################################
# .TEXT <update_apple>
	.text
update_apple:

	# Args:     void
	# Returns:  void
	#
	# Frame:    $ra, $s0, $s1
	# Uses:     $v0, $s0, $s1, $t0, $t1, $t2, $t3, $t4, $t5
	# Clobbers: $v0, $t0, $t1, $t2, $t3, $t4, $t5
	#
	# Locals:
	#   -> $s0 - int apple_row
	#   -> $s1 - int apple_col
	#
	# Structure:
	#   update_apple
	#   -> [prologue]
	#   -> body
	#   -> [epilogue]

	# Code:
update_apple__prologue:
	# set up stack frame
	addiu	$sp, $sp, -12
	sw	$ra, ($sp)
	sw      $s0, 4($sp)   # save $s0
	sw      $s1, 8($sp)   # save $s1

update_apple__body:

	# apple_row = rand_value(N_ROWS);
	li	$a0, N_ROWS
	jal	rand_value
	move	$s0, $v0

	# apple_col = rand_value(N_COLS);
	li	$a0, N_COLS
	jal	rand_value
	move	$s1, $v0


	# finding the index of the 2D array
	li	$t2, N_COLS
	mul	$t3, $t2, $s0
	add	$t4, $t3, $s1
	la	$t5, grid
	add	$t1, $t5, $t4
	lb      $t2, ($t1)

	# this creates the while loop condition
	bne	$t2, EMPTY, update_apple__body

	# end of while loop
	li	$t0, APPLE
	sb	$t0, ($t1)

update_apple__epilogue:
	# tear down stack frame
	lw      $s0, 4($sp)   # restore $s0
	lw      $s1, 8($sp)   # restore $s1
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 12

	jr	$ra			# return;



########################################################################
# .TEXT <update_snake>
	.text
update_snake:

	# Args:
	#   - $a0: int direction
	# Returns:
	#   - $v0: bool
	#
	# Frame:    $ra, $s3, $s4, $s5
	# Uses:     $s3, $s4, $s5, $a0, $a1, $v0, $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8
	# Clobbers: $a0, $a1, $v0, $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8
	#
	# Locals:
	#   -> $s3 - int new_head_row
	#   -> $s4 - int new_head_col
	#   -> $s5 - int apple - to check if snake is on apple
	#   
	# Structure:
	#   update_snake
	#   -> [prologue]
	#   -> body
	#   -> not_apple
	#   -> is_apple
	#   -> continue
	#   -> fail_condition (second epilogue)
	#   -> [epilogue]

	# Code:
update_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -16
	sw	$ra, ($sp)
	sw      $s3, 4($sp)   # save $s3
	sw      $s4, 8($sp)   # save $s4
	sw      $s5, 12($sp)   # save $s5

update_snake__body:

	# Finding d_row
	jal	get_d_row
	move	$t0, $v0

	# Finding d_col
	jal	get_d_col
	move	$t1, $v0

	# Finding head_row
	lb	$t5, snake_body_row($0)		# $t5 IS HEAD_ROW

	# Finding head_col
	lb	$t6, snake_body_col($0)		# $t6 IS HEAD_COL

	# Finding the index of the 2D array
	li	$t2, N_COLS
	mul	$t3, $t2, $t5
	add	$t4, $t3, $t6 
	la	$t7, grid
	add	$t2, $t7, $t4

	# Setting grid[head_row][head_col] = SNAKE_BODY;
	li	$t3, SNAKE_BODY
	sb      $t3, ($t2)

	# New_head_row
	add	$t0, $t5, $t0

	# New_head_col
	add	$t1, $t1, $t6

	# Conditions 
	blt	$t0, 0, fail_condition
	bge	$t0, N_ROWS, fail_condition
	blt	$t1, 0, fail_condition
	bge	$t1, N_COLS, fail_condition


	# Finding the index of the 2D array
	li	$t2, N_COLS
	mul	$t3, $t2, $t0
	add	$t4, $t3, $t1 
	la	$t7, grid
	add	$t2, $t7, $t4
	lb	$t3, ($t2)

	# Checking if position is an APPLE
	li	$t4, APPLE

	bne	$t3, $t4, not_apple
	beq	$t3, $t4, is_apple


# These two functions make the boolean of ($t4 MOVED TO $s5)
not_apple:
	li	$t4, 0
	move	$s5, $t4
	j	continue
	
	
is_apple:
	li	$t4, 1
	move	$s5, $t4
	j 	continue

continue:
	# Setting snake_tail = snake_body_len - 1;
	lw	$t3, snake_tail
	la	$t8, snake_tail

	lw	$t7, snake_body_len
	sub	$t4, $t7, 1
	sw	$t4, ($t8) 
	
	# Setting args
	move	$a0, $t0
	move	$a1, $t1

	# Saving them also
	move	$s3, $a0
	move	$s4, $a1

	# If move_snake_in_grid returns false
	jal	move_snake_in_grid
	beqz	$v0, fail_condition

	# Setting args
	move	$a0, $s3
	move	$a1, $s4

	jal	move_snake_in_array
	

	# If boolean of apple is false
	beqz	$s5, update_snake__epilogue

	lw	$t0, snake_growth
	la	$t8, snake_growth
	add	$t0, $t0, 3
	sw	$t0, ($t8)

	jal	update_apple
	j	update_snake__epilogue


# Fail condition, return 0 as is False in boolean 
fail_condition:
	# tear down stack frame
	lw      $s3, 4($sp)   # restore $s3
	lw      $s4, 8($sp)   # restore $s4
	lw      $s5, 12($sp)   # restore $s5
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 16

    	li	$v0, 0       # return false
   	jr	$ra


update_snake__epilogue:
	# tear down stack frame
	lw      $s3, 4($sp)   # restore $s3
	lw      $s4, 8($sp)   # restore $s4
	lw      $s5, 12($sp)   # restore $s5
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 16

	li	$v0, 1
	jr	$ra			# return true;



########################################################################
# .TEXT <move_snake_in_grid>
	.text
move_snake_in_grid:

	# Args:
	#   - $a0: new_head_row
	#   - $a1: new_head_col
	# Returns:
	#   - $v0: bool
	#
	# Frame:    $ra, [...]
	# Uses:     $a0, $v0, $t0, $t1, $t2, $t3, $t4, $t5, $t6 
	# Clobbers: $a0, $v0, $t0, $t1, $t2, $t3, $t4, $t5, $t6 
	#
	# Locals:
	#   - [...]
	#
	# Structure:
	#   move_snake_in_grid
	#   -> [prologue]
	#   -> body
	#   -> snake_growth_larger
	#   -> move_snake_in_grid_continue
	#   -> move_snake_in_grid_finish (second epilogue)
	#   -> [epilogue]

	# Code:
move_snake_in_grid__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

move_snake_in_grid__body:

	lw	$t0, snake_growth

	# Condition if snake_growth > 0
	bgt	$t0, 0, snake_growth_larger

	# Setting int tail // THIS IS $t1
	lw	$t1, snake_tail
	
	# Finding snake_body_row[tail] // THIS IS $t5
	lb	$t5, snake_body_row($t1)
	

	# Finding snake_body_col[tail] // THIS IS $t6
	lb	$t6, snake_body_col($t1)

	# Changing grid[tail_row][tail_col] = EMPTY
	li	$t0, N_COLS
	mul	$t1, $t0, $t5
	add	$t1, $t1, $t6    
	la	$t2, grid
	add	$t3, $t2, $t1

	li	$t4, EMPTY
	sb	$t4, ($t3)

	j	move_snake_in_grid_continue


snake_growth_larger:

	# Setting snake_tail++
	lw	$t1, snake_tail
	la	$t8, snake_tail
	addi	$t1, $t1, 1
	sw	$t1, ($t8)

	# Setting snake_body_len++
	lw	$t1, snake_body_len
	la	$t8, snake_body_len
	addi	$t1, $t1, 1
	sw	$t1, ($t8)

	# Setting snake_growth--
	lw	$t1, snake_growth
	la	$t8, snake_growth
	sub	$t1, $t1, 1
	sw	$t1, ($t8)

	j	move_snake_in_grid_continue


move_snake_in_grid_continue:
	# Finding the value of the 2D array
	move	$t6, $a1		# $t6 is new_head_col
	move	$t5, $a0		# $t5 is new_head_row

	li	$t0, N_COLS
	mul	$t1, $t0, $t5
	add	$t1, $t1, $t6 
	la	$t2, grid
	add	$t3, $t2, $t1
	lb	$t4, ($t3)


	li	$t5, SNAKE_BODY

	# Condition would return false in boolean
	beq	$t4, $t5, move_snake_in_grid_finish

	# Otherwise, grid[new_head_row][new_head_col] = SNAKE_HEAD;
	li	$t5, SNAKE_HEAD
	sb	$t5, ($t3)

	j	move_snake_in_grid__epilogue


move_snake_in_grid_finish:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 0
	jr	$ra			# return false;


move_snake_in_grid__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 1
	jr	$ra			# return true;



########################################################################
# .TEXT <move_snake_in_array>
	.text
move_snake_in_array:

	# Arguments:
	#   - $a0: int new_head_row
	#   - $a1: int new_head_col
	# Returns:  void
	#
	# Frame:    $ra, [...]
	# Uses:     $a0, $a1, $a2, $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8
	# Clobbers: $a0, $a1, $a2, $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8
	#
	# Locals:
	#   - [...]
	#
	# Structure:
	#   move_snake_in_array
	#   -> [prologue]
	#   -> body
	#   -> move_snake_loop
	#   -> move_snake_loop_end
	#   -> [epilogue]

	# Code:
move_snake_in_array__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

move_snake_in_array__body:

	lw	$t0, snake_tail
	move	$t7, $a0
	move	$t8, $a1

move_snake_loop:
	ble	$t0, 0, move_snake_loop_end

	# Finding snake_body_row[i - 1]
	sub	$t1, $t0, 1
	lb	$t5, snake_body_row($t1)

	# Finding snake_body_col[i - 1]
	sub	$t1, $t0, 1
	lb	$t6, snake_body_col($t1)

	# Setting the args
	move	$a0, $t5
	move	$a1, $t6
	move	$a2, $t0

	jal	set_snake_array

	# i--
	sub	$t0, $t0, 1

	j	move_snake_loop


move_snake_loop_end:
	# Setting the args
	move	$a0, $t7
	move	$a1, $t8
	li	$a2, 0

	jal	set_snake_array

move_snake_in_array__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	jr	$ra			# return;


########################################################################
####                                                                ####
####        STOP HERE ... YOU HAVE COMPLETED THE ASSIGNMENT!        ####
####                                                                ####
########################################################################

##
## The following is various utility functions provided for you.
##
## You don't need to modify any of the following.  But you may find it
## useful to read through --- you'll be calling some of these functions
## from your code.
##

	.data

last_direction:
	.word	EAST

rand_seed:
	.word	0

input_direction__invalid_direction:
	.asciiz	"invalid direction: "

input_direction__bonk:
	.asciiz	"bonk! cannot turn around 180 degrees\n"

	.align	2
input_direction__buf:
	.space	2



########################################################################
# .TEXT <set_snake>
	.text
set_snake:

	# Args:
	#   - $a0: int row
	#   - $a1: int col
	#   - $a2: int body_piece
	# Returns:  void
	#
	# Frame:    $ra, $s0, $s1
	# Uses:     $a0, $a1, $a2, $t0, $s0, $s1
	# Clobbers: $t0
	#
	# Locals:
	#   - `int row` in $s0
	#   - `int col` in $s1
	#
	# Structure:
	#   set_snake
	#   -> [prologue]
	#   -> body
	#   -> [epilogue]

	# Code:
set_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s0, 4($sp)
	sw	$s1,  ($sp)

set_snake__body:
	move	$s0, $a0		# $s0 = row
	move	$s1, $a1		# $s1 = col

	jal	set_snake_grid		# set_snake_grid(row, col, body_piece);

	move	$a0, $s0
	move	$a1, $s1
	lw	$a2, snake_body_len
	jal	set_snake_array		# set_snake_array(row, col, snake_body_len);

	lw	$t0, snake_body_len
	addiu	$t0, $t0, 1
	sw	$t0, snake_body_len	# snake_body_len++;

set_snake__epilogue:
	# tear down stack frame
	lw	$s1,  ($sp)
	lw	$s0, 4($sp)
	lw	$ra, 8($sp)
	addiu 	$sp, $sp, 12

	jr	$ra			# return;



########################################################################
# .TEXT <set_snake_grid>
	.text
set_snake_grid:

	# Args:
	#   - $a0: int row
	#   - $a1: int col
	#   - $a2: int body_piece
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $a0, $a1, $a2, $t0
	# Clobbers: $t0
	#
	# Locals:   None
	#
	# Structure:
	#   set_snake
	#   -> body

	# Code:
	li	$t0, N_COLS
	mul	$t0, $t0, $a0		#  15 * row
	add	$t0, $t0, $a1		# (15 * row) + col
	sb	$a2, grid($t0)		# grid[row][col] = body_piece;

	jr	$ra			# return;



########################################################################
# .TEXT <set_snake_array>
	.text
set_snake_array:

	# Args:
	#   - $a0: int row
	#   - $a1: int col
	#   - $a2: int nth_body_piece
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $a0, $a1, $a2
	# Clobbers: None
	#
	# Locals:   None
	#
	# Structure:
	#   set_snake_array
	#   -> body

	# Code:
	sb	$a0, snake_body_row($a2)	# snake_body_row[nth_body_piece] = row;
	sb	$a1, snake_body_col($a2)	# snake_body_col[nth_body_piece] = col;

	jr	$ra				# return;



########################################################################
# .TEXT <print_grid>
	.text
print_grid:

	# Args:     void
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $v0, $a0, $t0, $t1, $t2
	# Clobbers: $v0, $a0, $t0, $t1, $t2
	#
	# Locals:
	#   - `int i` in $t0
	#   - `int j` in $t1
	#   - `char symbol` in $t2
	#
	# Structure:
	#   print_grid
	#   -> for_i_cond
	#     -> for_j_cond
	#     -> for_j_end
	#   -> for_i_end

	# Code:
	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# putchar('\n');

	li	$t0, 0			# int i = 0;

print_grid__for_i_cond:
	bge	$t0, N_ROWS, print_grid__for_i_end	# while (i < N_ROWS)

	li	$t1, 0			# int j = 0;

print_grid__for_j_cond:
	bge	$t1, N_COLS, print_grid__for_j_end	# while (j < N_COLS)

	li	$t2, N_COLS
	mul	$t2, $t2, $t0		#                             15 * i
	add	$t2, $t2, $t1		#                            (15 * i) + j
	lb	$t2, grid($t2)		#                       grid[(15 * i) + j]
	lb	$t2, symbols($t2)	# char symbol = symbols[grid[(15 * i) + j]]

	li	$v0, 11			# syscall 11: print_character
	move	$a0, $t2
	syscall				# putchar(symbol);

	addiu	$t1, $t1, 1		# j++;

	j	print_grid__for_j_cond

print_grid__for_j_end:

	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# putchar('\n');

	addiu	$t0, $t0, 1		# i++;

	j	print_grid__for_i_cond

print_grid__for_i_end:
	jr	$ra			# return;



########################################################################
# .TEXT <input_direction>
	.text
input_direction:

	# Args:     void
	# Returns:
	#   - $v0: int
	#
	# Frame:    None
	# Uses:     $v0, $a0, $a1, $t0, $t1
	# Clobbers: $v0, $a0, $a1, $t0, $t1
	#
	# Locals:
	#   - `int direction` in $t0
	#
	# Structure:
	#   input_direction
	#   -> input_direction__do
	#     -> input_direction__switch
	#       -> input_direction__switch_w
	#       -> input_direction__switch_a
	#       -> input_direction__switch_s
	#       -> input_direction__switch_d
	#       -> input_direction__switch_newline
	#       -> input_direction__switch_null
	#       -> input_direction__switch_eot
	#       -> input_direction__switch_default
	#     -> input_direction__switch_post
	#     -> input_direction__bonk_branch
	#   -> input_direction__while

	# Code:
input_direction__do:
	li	$v0, 8			# syscall 8: read_string
	la	$a0, input_direction__buf
	li	$a1, 2
	syscall				# direction = getchar()

	lb	$t0, input_direction__buf

input_direction__switch:
	beq	$t0, 'w',  input_direction__switch_w	# case 'w':
	beq	$t0, 'a',  input_direction__switch_a	# case 'a':
	beq	$t0, 's',  input_direction__switch_s	# case 's':
	beq	$t0, 'd',  input_direction__switch_d	# case 'd':
	beq	$t0, '\n', input_direction__switch_newline	# case '\n':
	beq	$t0, 0,    input_direction__switch_null	# case '\0':
	beq	$t0, 4,    input_direction__switch_eot	# case '\004':
	j	input_direction__switch_default		# default:

input_direction__switch_w:
	li	$t0, NORTH			# direction = NORTH;
	j	input_direction__switch_post	# break;

input_direction__switch_a:
	li	$t0, WEST			# direction = WEST;
	j	input_direction__switch_post	# break;

input_direction__switch_s:
	li	$t0, SOUTH			# direction = SOUTH;
	j	input_direction__switch_post	# break;

input_direction__switch_d:
	li	$t0, EAST			# direction = EAST;
	j	input_direction__switch_post	# break;

input_direction__switch_newline:
	j	input_direction__do		# continue;

input_direction__switch_null:
input_direction__switch_eot:
	li	$v0, 17			# syscall 17: exit2
	li	$a0, 0
	syscall				# exit(0);

input_direction__switch_default:
	li	$v0, 4			# syscall 4: print_string
	la	$a0, input_direction__invalid_direction
	syscall				# printf("invalid direction: ");

	li	$v0, 11			# syscall 11: print_character
	move	$a0, $t0
	syscall				# printf("%c", direction);

	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# printf("\n");

	j	input_direction__do	# continue;

input_direction__switch_post:
	blt	$t0, 0, input_direction__bonk_branch	# if (0 <= direction ...
	bgt	$t0, 3, input_direction__bonk_branch	# ... && direction <= 3 ...

	lw	$t1, last_direction	#     last_direction
	sub	$t1, $t1, $t0		#     last_direction - direction
	abs	$t1, $t1		# abs(last_direction - direction)
	beq	$t1, 2, input_direction__bonk_branch	# ... && abs(last_direction - direction) != 2)

	sw	$t0, last_direction	# last_direction = direction;

	move	$v0, $t0
	jr	$ra			# return direction;

input_direction__bonk_branch:
	li	$v0, 4			# syscall 4: print_string
	la	$a0, input_direction__bonk
	syscall				# printf("bonk! cannot turn around 180 degrees\n");

input_direction__while:
	j	input_direction__do	# while (true);



########################################################################
# .TEXT <get_d_row>
	.text
get_d_row:

	# Args:
	#   - $a0: int direction
	# Returns:
	#   - $v0: int
	#
	# Frame:    None
	# Uses:     $v0, $a0
	# Clobbers: $v0
	#
	# Locals:   None
	#
	# Structure:
	#   get_d_row
	#   -> get_d_row__south:
	#   -> get_d_row__north:
	#   -> get_d_row__else:

	# Code:
	beq	$a0, SOUTH, get_d_row__south	# if (direction == SOUTH)
	beq	$a0, NORTH, get_d_row__north	# else if (direction == NORTH)
	j	get_d_row__else			# else

get_d_row__south:
	li	$v0, 1
	jr	$ra				# return 1;

get_d_row__north:
	li	$v0, -1
	jr	$ra				# return -1;

get_d_row__else:
	li	$v0, 0
	jr	$ra				# return 0;



########################################################################
# .TEXT <get_d_col>
	.text
get_d_col:

	# Args:
	#   - $a0: int direction
	# Returns:
	#   - $v0: int
	#
	# Frame:    None
	# Uses:     $v0, $a0
	# Clobbers: $v0
	#
	# Locals:   None
	#
	# Structure:
	#   get_d_col
	#   -> get_d_col__east:
	#   -> get_d_col__west:
	#   -> get_d_col__else:

	# Code:
	beq	$a0, EAST, get_d_col__east	# if (direction == EAST)
	beq	$a0, WEST, get_d_col__west	# else if (direction == WEST)
	j	get_d_col__else			# else

get_d_col__east:
	li	$v0, 1
	jr	$ra				# return 1;

get_d_col__west:
	li	$v0, -1
	jr	$ra				# return -1;

get_d_col__else:
	li	$v0, 0
	jr	$ra				# return 0;



########################################################################
# .TEXT <seed_rng>
	.text
seed_rng:

	# Args:
	#   - $a0: unsigned int seed
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $a0
	# Clobbers: None
	#
	# Locals:   None
	#
	# Structure:
	#   seed_rng
	#   -> body

	# Code:
	sw	$a0, rand_seed		# rand_seed = seed;

	jr	$ra			# return;



########################################################################
# .TEXT <rand_value>
	.text
rand_value:

	# Args:
	#   - $a0: unsigned int n
	# Returns:
	#   - $v0: unsigned int
	#
	# Frame:    None
	# Uses:     $v0, $a0, $t0, $t1
	# Clobbers: $v0, $t0, $t1
	#
	# Locals:
	#   - `unsigned int rand_seed` cached in $t0
	#
	# Structure:
	#   rand_value
	#   -> body

	# Code:
	lw	$t0, rand_seed		#  rand_seed

	li	$t1, 1103515245
	mul	$t0, $t0, $t1		#  rand_seed * 1103515245

	addiu	$t0, $t0, 12345		#  rand_seed * 1103515245 + 12345

	li	$t1, 0x7FFFFFFF
	and	$t0, $t0, $t1		# (rand_seed * 1103515245 + 12345) & 0x7FFFFFFF

	sw	$t0, rand_seed		# rand_seed = (rand_seed * 1103515245 + 12345) & 0x7FFFFFFF;

	rem	$v0, $t0, $a0
	jr	$ra			# return rand_seed % n;

