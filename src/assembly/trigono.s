# Mips program to calculate trigonometric functions

#data declarations
	.data

	
.align 2

.globl main		# Make the label main globally visible
	.text		# Start of the code
	
main:

sin:
sin0:			# sin0 implements the algorithm "sum from 0 to infinity { (-1)^i * [x^(2i+1) / (2i+1)!] }"
	move $f0, $a0			# $f0 holds the sum value, initialized with x for the first iteration
	move $f1, $a0			# $f1 will hold the current value for x^(2i+1), initialized with x
	addi $t0, $zero, 1		# $t0 will hold the current value for (2i+1)!, initialized with 1
	addi $t1, $zero, 3		# $t1 holds i, the loop counter, initialized with 3 (first iteration already done
	addi $t2, $zero, 13		# $t2 is the loop limit, since we want 6 iterations it is 6*2+1 = 13
	addi $t9, $zero, 0		# $t9 is a flag indicating whether the intermediate result has to be
							#	added (0) to or subtracted (1) from the sum.
	
	loop:
		slt $t8, $t1, $t2
		beq $t8, $zero, end
		mul.s $f1, $f1, x		# to get to the next value for x^(2i+1), we have to multiply by x two times
		mul.s $f1, $f1, x
		
		addi $t3, $t1, -1		# to get to the next value for (2i+1)!, we have to multiply by (i-1)*i
		mul $t2, $t2, $t3
		mul $t2, $t2, $t1
		
		div.s $f3, $f1, $t2		# Make the division.    !!!!!!!!! NEEDS FIXING ($t2 is int) !!!!!!!!!!!!
		
		beq $t9, $zero, add		# if the flag indicates we should subtract the intermediate result, multiply by -1
		mul $f3, $f3, -1
		add:
		add $f0, $f0, $f3
		addi $t1, $t1, 2
	
	end: jr $ra
cos:
tan:
tan0: