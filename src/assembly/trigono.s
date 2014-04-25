# Mips program to calculate trigonometric functions

#data declarations
	.data
PI:	.float 3.14159265359
	
.align 2

.globl main		# Make the label main globally visible
	.text		# Start of the code
	
main: 
	li.s $f12, -123.0
	jal sin
	
	li $v0, 2
	mov.s $f12, $f0
	syscall
	
	li   $v0, 10 
	syscall	           	# Ende
	
	
sin:
	addi $sp, $sp, -12		# save the registers that are to be used to the stack
	sw $ra, 8($sp)
	sw $t0, 4($sp)
	s.s $f1, 0($sp)
	
	la $t0, PI				# load pi into $f0
	l.s $f0, 0($t0)
	li.s $f1, 2.0			# multiply by 2 (we need 2*PI)
	mul.s $f0, $f0, $f1
	
	# implementing a%b for floats in order to transform them into one interval
	div.s $f1, $f12, $f0	# divide x/2*PI
	cvt.w.s $f1, $f1		# convert the result to int to cut off decimal places
	cvt.s.w $f1, $f1		# convert back to float to calculate
	mul.s $f0, $f0, $f1		# y*b
	sub.s $f12, $f12, $f0	# a-y*b
	
	jal sin0
	
	l.s $f1, 0($sp)			# load the saved values
	lw $t0, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16		# reset the stack pointer
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
		li $t9, 0				# reset the flag to 0 (add)
		j back					# jump to the end of the loop
		add_:					# was brached, so we need to add
		add.s $f0, $f0, $f3		
		li $t9, 1				# reset the flag to 1 (subtract)
		back: 
		addi $t1, $t1, 2		# increment the loop variable by 2
		j loop					# continue the loop
		
	end: jr $ra

cos:	
		addi $sp, $sp, -12		# save registers to the stack
		sw $ra, 8($sp)
		sw $t0, 4($sp)
		s.s $f0, 0($sp)
		
		la $t0, PI				# load pi into $f0
		l.s $f0, 0($t0)			
		div.s $f0, $f0, 2		# divide by 2 to get pi/2
		add.s $f12, $f12, $f0	# add pi/2 to x
		jal sin					# call sin with x+pi/2
		
		l.s $f0, 0($sp)			# restore the saved registers
		lw $t0, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12		# reset the stack pointer
		
		jr $ra
		
tan:	la $t0, PI				# load pi into $f4
		l.s $f4, 0($t0)
		
		move $f3, $f4			# save pi/2 into $f3
		li $f1, 0.5
		mul.s $f3, $f3, $f1
		
		# implementing a%b for floats in order to transform x into the defined interval
		div.s $f1, $f12, $f4	# divide x/PI
		cvt.w.s $f1, $f1		# convert the result to int to cut off decimal places
		cvt.s.w $f1, $f1		# convert back to float to calculate
		mul.s $f0, $f0, $f1		# y*b
		sub.s $f12, $f12, $f0	# a-y*b
		
		slt $f0, $f3, $f12		# if x>pi/2, set $f0
		bne $f0, $zero, toobig	# jump to 'toobig' if x is too big
		neg.s $f3, $f3			# negate pi/2 to -pi/2
		slt $f0, $f12, $f3		# if x<-pi/2, set $f0
		bne $f0, $zero, toosmall# jump to 'toosmall if x is too big
		j calc					# x is already inbounds, jump to calc
		toobig:
		sub.s $f12, $f12, $f4	# subtract pi from x and jump to calc
		j calc
		toosmall:
		add.s $f12, $f12, $f4	# add pi to x
		calc:
		jal tan0				# calc tan0 for x
		jr $ra
		
tan0:	jal sin0				# calc sin for x
		mov.s $f1, $f0			# save the result in $f1
		
		la $t0, PI				# load pi into $f2
		l.s $f2, 0($t0)
		li.s $f3, 0.5			
		mul.s $f2, $f2, $f3		# divide pi by 2
		add.s $f12, $f12, $f2	# add pi/2 to x
		jal sin0				# calc sin for pi/2 + x
		
		div.s $f1, $f1, $f12	# divide sin(x)/sin(pi/2 + x)
		mov.s $f0, $f1			# move it into the return register
		jr $ra 