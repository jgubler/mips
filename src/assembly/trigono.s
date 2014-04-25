# Mips program to calculate trigonometric functions

#data declarations
	.data
PI:	.float 3.14159265359
	
.align 2

.globl main		# Make the label main globally visible
	.text		# Start of the code
	
main: 
	li.s $f12, 42.0
	jal sin
	
	li $v0, 2
	mov.s $f12, $f0
	syscall
	
	li   $v0, 10 
	syscall	           	# Ende
	
	
sin:
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $t0, 8($sp)
	s.s $f1, 0($sp)
	
	la $t0, PI				# load pi into $f0
	l.s $f0, 0($t0)
	li.s $f1, 2.0				# multiply by 2 (we need 2*PI)
	mul.s $f0, $f0, $f1
	div.s $f1, $f12, $f0	# divide x/2*PI
							
	cvt.w.s $f1, $f1		# convert the result to int to cut off decimal places
		
	cvt.s.w $f1, $f1		# convert back to float to calculate
	mul.s $f0, $f0, $f1		# y*b
	sub.s $f12, $f12, $f0	# a-y*b
	jal sin0
	l.s $f1, 0($sp)
	lw $t0, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	
	
sin0:			# sin0 implements the algorithm "sum from 0 to infinity { (-1)^i * [x^(2i+1) / (2i+1)!] }"
	
	mov.s $f0, $f12			# $f0 holds the sum value, initialized with x for the first iteration
	mov.s $f1, $f12			# $f1 will hold the current value for x^(2i+1), initialized with x
	addi $t0, $zero, 1		# $t0 will hold the current value for (2i+1)!, initialized with 1
	addi $t1, $zero, 3		# $t1 holds i, the loop counter, initialized with 3 (first iteration already done
	addi $t2, $zero, 13		# $t2 is the loop limit, since we want 6 iterations it is 6*2+1 = 13
	addi $t9, $zero, 1		# $t9 is a flag indicating whether the intermediate result has to be
							#	added (0) to or subtracted (1) from the sum.
	
	loop:
		slt $t8, $t1, $t2
		beq $t8, $zero, end
		mul.s $f1, $f1, $f12	# to get to the next value for x^(2i+1), we have to multiply by x two times
		mul.s $f1, $f1, $f12
		
		addi $t3, $t1, -1		# to get to the next value for (2i+1)!, we have to multiply by (i-1)*i
		mul $t0, $t0, $t3
		mul $t0, $t0, $t1
		
		mtc1 $t0, $f3			# Convert the faculty value to float
		cvt.s.w $f3, $f3
		div.s $f3, $f1, $f3		# Make the division.
		
		beq $t9, $zero, add_	# if the flag indicates we should subtract the intermediate result, multiply by -1
		sub.s $f0, $f0, $f3
		li $t9, 0
		j back
		add_:
		add.s $f0, $f0, $f3
		li $t9, 1
		back: 
		addi $t1, $t1, 2
		j loop
		
	end: jr $ra
cos:
tan:
tan0: