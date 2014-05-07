# Mips program to calculate trigonometric functions

#data declarations
	.data
welcome:.asciiz "This program calculates the trigonometric values for n equidistant x values in a given interval.\n---\n" 
lower:	.asciiz "Lower limit of interval: "
upper:	.asciiz "\nUpper limit of interval: "
n:		.asciiz "\nn:                       "
sinstr:	.asciiz "\nsin("
cosstr: .asciiz "\tcos("
tanstr: .asciiz "\ttan("
shared: .asciiz ") = "
PI:	.float 3.14159265359
.align 2

.globl main		# Make the label main globally visible
	.text		# Start of the code
	
main: 
	
	jal getUserInput	# get the user input
	mov.s $f3, $f0		# save n in $f3, because $f0 will get overwritten
	sub.s $f4, $f2, $f1	# $f4 = upper limit - lower limit
	
	li.s $f5, 1.0		# n = n-1
	sub.s $f3, $f3, $f5
	
	div.s $f4, $f4, $f3	# $f4 = $f4/n
	mov.s $f12, $f1		# x = lower limit
	
	loop1:
		jal sin				# call sin(x)
		mov.s $f13, $f0		# save the result in $f13
		jal cos				# call cos(x)
		mov.s $f14, $f0		# save the result in $f14	
		jal tan				# call tan(x)
		mov.s $f15, $f0		# save the result in $f15

		jal print			# fancy result printout
		
		add.s $f12, $f12, $f4 	# x = x + $f4
		sub.s $f3, $f3, $f5		# n = n-1
		
		li.s $f6, 0.0
		c.lt.s $f3, $f6		# if n<0, set the special register to 1	
		bc1f loop1			# if special register is false, continue loop1
	
	li $v0, 10 			# terminate
	syscall
	
	
getUserInput:	# Gets n, the lower limit and the upper limit from the user and returns them in $f0, $f1 and $f2
	
	la $a0, welcome		# print welcome message
	li $v0, 4
	syscall
	
	# Lower limit
	
	la $a0, lower		# ask for lower limit
	li $v0, 4
	syscall
	
	li $v0, 6			# read user input for lower limit
	syscall
	mov.s $f1, $f0		# save the value in $f1
	
	# Upper limit
	
	la $a0, upper		# ask for upper limit
	li $v0, 4
	syscall
	
	li $v0, 6			# read user input for upper limit
	syscall
	mov.s $f2, $f0		# save the value in $f2
	
	# n
	
	la $a0, n			# ask for n
	li $v0, 4
	syscall
	
	li $v0, 6			# read user input for n
	syscall				# n stays in $f0
	
	jr $ra
	
sin:
	# save the registers that are to be used to the stack: $ra, $f1, $f2, $f4, $f8, $f9, $f10, $f12
	addi $sp, $sp, -32
	sw $ra, 28($sp)	
	s.s $f1, 24($sp)
	s.s $f2, 20($sp)
	s.s $f4, 16($sp)
	s.s $f8, 12($sp)
	s.s $f9, 8($sp)
	s.s $f10, 4($sp)
	s.s $f12, 0($sp)
	
	la $t0, PI				# load pi into $f8
	l.s $f8, 0($t0)
	
	li.s $f2, 2.0			# load 2*pi into $f9
	mul.s $f9, $f8, $f2

	div.s $f10, $f8, $f2	# load pi/2 into $f10
	
	# implementing a%b for floats in order to transform x into the well defined interval
	div.s $f2, $f12, $f9	# divide x/2*PI
	cvt.w.s $f2, $f2		# convert the result to int to cut off decimal places
	cvt.s.w $f2, $f2		# convert back to float to calculate
	mul.s $f2, $f2, $f9		# y*b
	sub.s $f12, $f12, $f2	# x = a-y*b
	
	# x is now in [-2*pi; 2*pi]
	# we will now transform this onto [-pi/2; 2*pi] by adding 2*pi if x<-pi/2
	neg.s $f4, $f10			# load -pi/2 into $f4
	c.lt.s $f12, $f4		# if x<-pi/2, set the special register to 1
	bc1f continue			# if special register is false, jump to continue
	add.s $f12, $f12, $f9	# was true, add 2*pi to x
	continue:

	# x is now in [-pi/2; 2*pi]
	# we will now transform this onto [-pi/2; 1.5*pi] by subtracting 2*pi if 1.5*pi<x
	li.s $f4, 1.5			# load 1.5 into $f4
	mul.s $f4, $f4, $f8		# multiply 1.5 by pi
	c.lt.s $f4, $f12		# if 1.5*pi < x, set the special register to 1
	bc1f next				# if special register is false, jump to next
	sub.s $f12, $f12, $f9	# x = x - 2*pi
	next:
	
	# x is now in [-pi/2; 1.5*pi]
	# we will now finally transform this onto [-pi/2; pi/2] by flipping horizontally at pi/2 if pi/2<x
	c.lt.s $f10, $f12		# if pi/2 < x, set the special register to 1
	bc1f calc				# if special register is false, jumpt to calc
	sub.s $f12, $f8, $f12	# flip horizontally at pi/2 with:	x = pi - x
	calc:
	
	# x is now in [-pi/2; pi/2], we can finally call sin0 to calculate the value
	jal sin0
	
	# restore the saved registers
	lw $ra, 28($sp)	
	l.s $f1, 24($sp)
	l.s $f2, 20($sp)
	l.s $f4, 16($sp)
	l.s $f8, 12($sp)
	l.s $f9, 8($sp)
	l.s $f10, 4($sp)
	l.s $f12, 0($sp)
	addi $sp, $sp, 32
	jr $ra
	
	
sin0:	# sin0 implements the algorithm "sum from i=0 to infinity { (-1)^i * [x^(2i+1) / (2i+1)!] }"
	
	# save the registers that are to be used to the stack: $ra, $f1, $f3, $f12 
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	s.s $f1, 8($sp)
	s.s $f3, 4($sp)
	s.s $f12, 0($sp)


	mov.s $f0, $f12			# $f0 holds the sum value, initialized with x for the first iteration
	mov.s $f1, $f12			# $f1 will hold the current value for x^(2i+1), initialized with x
	addi $t0, $zero, 1		# $t0 will hold the current value for (2i+1)!, initialized with 1
	addi $t1, $zero, 3		# $t1 holds i, the loop counter, initialized with 3 (first iteration already done
	addi $t2, $zero, 15		# $t2 is the loop limit, since we want 7 iterations it is 7*2+1 = 15
	addi $t9, $zero, 1		# $t9 is a flag indicating whether the intermediate result has to be
								# 	added (0) to or subtracted (1) from the sum.
	
	loop:
		slt $t8, $t1, $t2		# set $t8 to 1, if the loop variable is less than the loop limit
		beq $t8, $zero, end		# if $t8 is 0, we need to exit the loop
		
		mul.s $f1, $f1, $f12	# to get to the next value for x^(2i+1), we have to multiply by x two times
		mul.s $f1, $f1, $f12
		
		addi $t3, $t1, -1		# to get to the next value for (2i+1)!, we have to multiply by (i-1)*i
		mul $t0, $t0, $t3
		mul $t0, $t0, $t1
		
		mtc1 $t0, $f3			# Convert the faculty value to float
		cvt.s.w $f3, $f3
		div.s $f3, $f1, $f3		# Make the division.
		
		beq $t9, $zero, add_	# if the flag indicates we should subtract the intermediate result, multiply by -1
		sub.s $f0, $f0, $f3		# was not branched, so we need to subtract
		li $t9, 0			# reset the flag to 0 (add)
		j back				# jump to the end of the loop
		add_:				# was brached, so we need to add
		add.s $f0, $f0, $f3		
		li $t9, 1			# reset the flag to 1 (subtract)
		back: 
		addi $t1, $t1, 2	# increment the loop variable by 2
		j loop				# continue the loop
		
	end: 
		# restore the saved registers
		lw $ra, 12($sp)
		l.s $f1, 8($sp)
		l.s $f3, 4($sp)
		l.s $f12, 0($sp)
		addi $sp, $sp, 16
		jr $ra

cos:	
	# save the registers that are to be used to the stack: $ra, $f1, $f12
	addi $sp, $sp, -12		
	sw $ra, 8($sp)
	s.s $f1, 4($sp)
	s.s $f12, 0($sp)		
	
	la $t0, PI				# load pi into $f0
	l.s $f0, 0($t0)

	li.s $f1, 0.5			# divide pi by 2
	mul.s $f0, $f0, $f1
	
	sub.s $f12, $f0, $f12	# x = x - pi/2

	jal sin					# call sin with pi/2 - x for cos(x)
	
	# restore the saved registers		
	lw $ra, 8($sp)
	l.s $f1, 4($sp)
	l.s $f12, 0($sp)
	addi $sp, $sp, 12		
	
	jr $ra
		
tan:	
	# save the registers that are to be used to the stack: $ra, $f1, $f2, $f3, $f8, $f9, $f10, $f12
	addi $sp, $sp, -32	
	sw $ra, 28($sp)	
	s.s $f1, 24($sp)
	s.s $f2, 20($sp)
	s.s $f3, 16($sp)
	s.s $f8, 12($sp)
	s.s $f9, 8($sp)
	s.s $f10, 4($sp)
	s.s $f12, 0($sp)
	
	la $t0, PI				# $f8 = pi
	l.s $f8, 0($t0)
	
	li.s $f2, 2.0			# $f9 = 2*pi
	mul.s $f9, $f8, $f2

	div.s $f10, $f8, $f2	# $f10 = pi/2
	
	# implementing x%PI for floats in order to transform x into the well defined interval
	div.s $f2, $f12, $f8	# $f2 = x/PI
	cvt.w.s $f2, $f2		# convert the result to int to cut off decimal places
	cvt.s.w $f2, $f2		# convert back to float to calculate
	mul.s $f2, $f2, $f8		# $f2 = $f2*pi
	sub.s $f12, $f12, $f2	# $f12 (x) = $f12 - $f2 
	
	# x is now in [-pi; pi]
	# we will now transform this onto [-pi/2; pi/2] by adding pi if x<-pi/2 and subtracting pi if x>pi/2
	neg.s $f3, $f10			# $f3 = -pi/2
	c.lt.s $f12, $f3		# if $f12<$f4 (x<-pi/2), set the special register to 1
	bc1f continue1			# if special register is 0, jump to continue
	add.s $f12, $f12, $f8	# was true, x = x + pi
	continue1:

	mov.s $f3, $f10			# load pi/2 into $f3
	c.lt.s $f3, $f12		# if pi/2 < x, set the special register to 1
	bc1f next1				# if special register is 0, jump to next
	sub.s $f12, $f12, $f8	# was true, x = x - pi
	next1:
	
	# x is now in [-pi/2; pi/2], we can finally call tan0 to calculate the value
	jal tan0
	
	# restore the saved registers
	lw $ra, 28($sp)	
	l.s $f1, 24($sp)
	l.s $f2, 20($sp)
	l.s $f3, 16($sp)
	l.s $f8, 12($sp)
	l.s $f9, 8($sp)
	l.s $f10, 4($sp)
	l.s $f12, 0($sp)
	addi $sp, $sp, 28
	jr $ra
		
tan0:		# save the registers that are to be used to the stack:  $ra, $f1, $f2, $f3, $f12
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	s.s $f1, 12($sp)
	s.s $f2, 8($sp)
	s.s $f3, 4($sp)
	s.s $f12, 0($sp)
	
	jal sin0				# calc sin for x
	mov.s $f1, $f0			# $f1 <- $f0 (sin(x))
	
	la $t0, PI				# $f2 = pi
	l.s $f2, 0($t0)
	
	li.s $f3, 0.5			# $f3 = 0.5
	mul.s $f3, $f3, $f2		# $f3 = $f3 * $f2 (0.5 * pi)
	sub.s $f12, $f3, $f12	# $f12 = $f12-$f3 (x = pi/2 - x), as cos(x) = sin(pi/2 - x)

	jal sin0				# calc cos(x) via sin0(pi/2 - x)
	
	div.s $f0, $f1, $f0		# $f0 = $f1/$f0 (sin(x)/cos(x))
	
	# restore the saved registers
	lw $ra, 16($sp)
	l.s $f1, 12($sp)
	l.s $f2, 8($sp)
	l.s $f3, 4($sp)
	l.s $f12, 0($sp)
	addi $sp, $sp, 20

	jr $ra

print:	# Fancy printout of the results for the trigonomeric functions
	# save the registers that are to be used to the stack:  $ra, $f1, $f12
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	s.s $f1, 4($sp)
	s.s $f12, 0($sp)

	mov.s $f1, $f12		# save x to $f1, because $f12 will be needed for the syscalls

	# ------------
	#    sinus
	# ------------
	li $v0, 4			# print "\nsin("
	la $a0, sinstr
	syscall

	li $v0, 2			# print x
	mov.s $f12, $f1
	syscall

	li $v0, 4			# print ") = "
	la $a0, shared
	syscall

	li $v0, 2			# print the result (sin(x))
	mov.s $f12, $f13
	syscall

	# ------------
	#   cosinus
	# ------------
	li $v0, 4			# print "\ncos("
	la $a0, cosstr
	syscall

	li $v0, 2			# print x
	mov.s $f12, $f1
	syscall

	li $v0, 4			# print ") = "
	la $a0, shared
	syscall

	li $v0, 2			# print the result (cos(x))
	mov.s $f12, $f14
	syscall

	# ------------
	#   tangent
	# ------------
	li $v0, 4			# print "\ntan("
	la $a0, tanstr
	syscall

	li $v0, 2			# print x
	mov.s $f12, $f1
	syscall

	li $v0, 4			# print ") = "
	la $a0, shared
	syscall

	li $v0, 2			# print the result (tan(x))
	mov.s $f12, $f15
	syscall
	
	# restore the saved registers
	lw $ra, 8($sp)
	l.s $f1, 4($sp)
	l.s $f12, 0($sp)
	addi $sp, $sp, 12

	jr $ra
	
