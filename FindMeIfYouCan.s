
# Find Me if You Can
.eqv	c_range_xy	10
#.eqv	c_range_xy	11
	.data
seed:	.word 13207
msg:	.asciiz "Please enter a number: "
msg0:	.asciiz "What is the x coordinate of the treasure (0-9)? "
msg1:	.asciiz "What is the y coordinate of the treasure (0-9)? "
msg2:	.asciiz "The x coordinate of the treasure is larger than your guess. ("
msg3:	.asciiz "The x coordinate of the treasure is smaller than your guess. ("
msg4:	.asciiz "The x coordinate of the treasure is correct. ("
msg5:	.asciiz "The y coordinate of the treasure is larger than your guess. ("
msg6:	.asciiz "The y coordinate of the treasure is smaller than your guess. ("
msg7:	.asciiz "The y coordinate of the treasure is correct. ("
msg8:	.asciiz "You get the treasure!!! ("
msg9:	.asciiz "Do you want to EXIT??(0:No, play again.  1:Yes, stop the game.) "
msg10:	.asciiz "Wrong message! Only (1) or (0)!!!!\n"
msg11:	.asciiz "Play with me next time. See YOU!!\n"
msg12:	.asciiz "Out of Range!!\n"
c_bkt:	.asciiz ")\n"
comma:	.asciiz ","
space:	.asciiz " "
newline:.asciiz "\n"

	.text
	.globl __start
__start:
main:
# Print "Please enter a number: \n"
	la	$a0, msg
	li	$v0, 4
	syscall
# Get the seed from the user and store in seed
	li	$v0, 5
	syscall
	sw	$v0, seed

#--------------------------------------------------------------------------
#-------Calculate the treasure x and treasure y, stored in $a2 and $a3 respectively
	jal	rand			# its result stored in $v0
	add	$a2, $zero, $v0		# treasure x
	jal 	rand
	add	$a3, $zero, $v0		# treasure y
	
#-------Get input x and check if in range
# Print "What is the x coordinate of the treasure (0-9)?"
AskX:	la	$a0, msg0
	li	$v0, 4
	syscall
# Get the guess x from user
	li	$v0, 5
	syscall
	add	$t9, $zero, $v0
# sltiu to check 0<=i<a, use a = 10 a.k.a c_range_xy
	#addi	$t3, $t9, 5
	#sltiu	$t0, $t3, c_range_xy
	sltiu	$t0, $t9, c_range_xy
	bne 	$t0, $zero, AskY	# if true in range, go for y
# if out of range, print "Out of Range", then AskX again	
	la	$a0, msg12
	li	$v0, 4
	syscall
	
	j	AskX
	
#-------Get input y and check if in range
# Print "What is the y coordinate of the treasure (0-9)?"
#Storing:add	$s0, $zero, $a0	# $a0 later used for printing
AskY:	la	$a0, msg1
	li	$v0, 4
	syscall
# Get the guess y from user, store in $a1
	li	$v0, 5
	syscall
	add	$a1, $zero, $v0
# sltiu to check 0<=i<a, use a = 10 a.k.a c_range_xy
	#addi	$t6, $a1, 5
	#sltiu	$t0, $t6, c_range_xy
	sltiu	$t0, $a1, c_range_xy
	bne	$t0, $zero, Continue	# if true in range, Continue
# if out of range, print "Out of Range", then AskY again	
	la	$a0, msg12
	li	$v0, 4
	syscall
	
	j	AskY
	
Continue:
	add	$a0, $zero, $t9	# guess x for argument of Check_coordinate
#------Matching treasure x and treasure y with guess x and guess y
	jal 	Check_coordinate
	addi	$t1, $zero, 1	# unique values
	addi	$t2, $zero, 2
	addi	$t4, $zero, 4	# if both equal
	
# check if both matches
	add	$t5, $v0, $v1
	beq	$t5, $t4, Win		# 2+2 = 4, highest possible
	
# check x through $v0
xCheck:	beq	$v0, $zero, xSmall	#[$v0] = 0 if treasure x < guess x
	beq	$v0, $t1, xBig		# =1 if treasure x > guess x
				
	la	$a0, msg4		# if same x
	li	$v0, 4
	syscall	
	j	xGuess
	
xBig:	la	$a0, msg2		# the x of treasure is larger
	li	$v0, 4
	syscall	
	j	xGuess
	
xSmall:	la	$a0, msg3		# the x of treasure is smaller
	li	$v0, 4
	syscall
	j	xGuess
	
xGuess: li 	$v0, 1
	add 	$a0, $zero, $t9		# print guess x, remember in $t9
	syscall
	
	la	$a0, c_bkt		# print ")\n"
	li	$v0, 4
	syscall
	
	# Then continue checking yCheck
	
# check y
yCheck:	beq	$v1, $zero, ySmall	# [$v1] = 0 if treasure y < guess y
	beq 	$v1, $t1, yBig
	
	la	$a0, msg7		# if same y
	li	$v0, 4
	syscall	
	j	yGuess 
	
yBig:	la	$a0, msg5		# the y of treasure is larger
	li	$v0, 4
	syscall	
	j	yGuess

ySmall:	la	$a0, msg6		# the y of treasure is smaller
	li	$v0, 4
	syscall	
	j	yGuess
	
yGuess:	li 	$v0, 1
	add 	$a0, $zero, $a1		# print guess y, remember in $a1
	syscall
	
	la	$a0, c_bkt		# print ")\n"
	li	$v0, 4
	syscall
	j	AskX			# repeat input guess x and guess y
	
#-------Found the treasure

Win:	la	$a0, msg8		# print "You get the treasure"
	li	$v0, 4
	syscall
	
	li 	$v0, 1
	add 	$a0, $zero, $a2		# print treasure x in $a2
	syscall
	
	la	$a0, comma		# print ","
	li	$v0, 4
	syscall
	
	li 	$v0, 1
	add 	$a0, $zero, $a3		# print treasure y in $a3
	syscall
	
	la	$a0, c_bkt		# print ")\n"
	li	$v0, 4
	syscall
	
#-------Play again or not?
#-------0 = play again, 1 = exit

Option:	la	$a0, msg9		# print "Do you want to exit or play again?"
	li	$v0, 4
	syscall
	
# Get the option from user, $v0 no longer used
	li	$v0, 5
	syscall
	
# sltiu to check 0<=i<a, use a = 2, only 0 or 1
	sltiu	$t0, $v0, 2
	bne	$t0, $zero, Decide	# include in 0 or 1
	
	#Not 0 or 1
	la	$a0, msg10		# print "WRONG message, ..."
	li	$v0, 4
	syscall
	j	Option			# ask option again
	
Decide:	beq	$v0, $zero, main	# 0 means play again, ask for another seed

	# not equal can only mean option is 1, stop playing
	la	$a0, msg11		# print "Play with me next time. See YOU!!"
	li	$v0, 4
	syscall
	
	# proceed to terminate program
#--------------------------------------------------------------------------

# Terminate the program
	li	$v0, 10
	syscall


#--------------------------------------------------------------------------
# function for determine the correctness of the coordinate
# Assume:
#	1. Guess x and y are stored in $a0, $a1 respectively
#	2. Treasure x and y are stored in $a2, $a3 respectively
# Outputs:
#	1. v0 (2: when treasure x = guess x, 1: treasure x > guess x, 0: treasure x < guess x)
#	2. v1 (2: when treasure y = guess y, 1: treasure y > guess y, 0: treasure y < guess y)
#
Check_coordinate:

#--------------------------------------------------------------------------
#--------- check for x, $a0 vs $a2, result in $v0
	bne	$a0, $a2, DiffX		# different x
	addi	$v0, $zero, 2		# if equal, [$v0] = 2
	j	ExitX
	
DiffX:	slt	$t8, $a0, $a2		# check if guess<treasure
	beq	$t8, $zero, BigX	# if false, BigX
	addi	$v0, $zero, 1		# if guess<treasure, [$v0] = 1
	j	ExitX
	
BigX:	addi	$v0, $zero, 0		# if guess>treasure, [$v0] = 0
ExitX:	
#--------- check for y, $a1 vs $a3, result in $v1
	bne	$a1, $a3, DiffY		# different y
	addi	$v1, $zero, 2		# if equal, [$v1] = 2
	j	ExitY
	
DiffY:	slt	$t8, $a1, $a3		# check if guess<treasure
	beq	$t8, $zero, BigY	# if false, BigY
	addi	$v1, $zero, 1		# if guess<treasure, [$v1] = 1
	j	ExitY
	
BigY:	addi	$v1, $zero, 0		# if guess>treasure, [$v1]=0
ExitY:
#--------------------------------------------------------------------------

	jr	$ra
#--------------------------------------------------------------------------


#--------------------------------------------------------------------------
# function for generating random number (0 - 9), return in $v0
rand:	addi	$sp, $sp, -8	# adjust the stack pointer
	sw	$t0, 4($sp)	# store registers' value to stack
	sw	$ra, 0($sp)
	addu	$t0, $t0, $ra
	jal	randnum
	addi	$t0, $0, c_range_xy
	remu	$v0, $v0, $t0	# get the reminder of division
	lw	$ra, 0($sp)	# load the values from the stack to registers
	lw	$t0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
randnum:addi	$sp, $sp, -8	# adjust the stack pointer
	sw	$t0, 4($sp)	# store registers' value to stack
	sw	$t1, 0($sp)
	lw	$v0, seed
	addu	$v0, $v0, $t0
	addiu	$t0, $0, 13	# Load in first prime
	addiu	$t1, $0, 3147	# Load in the first mod value
	multu	$v0, $t0	# seed = seed * 13
	mflo	$v0		# Get the LO result of the multiply
	addiu	$v0, $v0, 14689	# seed = seed + 14689
	remu	$v0, $v0, $t1	# seed = seed % 3147
	sw	$v0, seed	# Save the new seed
	lw	$t1, 0($sp)	# load the values from the stack to registers
	lw	$t0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
#------------------------------------------------------------------------------
