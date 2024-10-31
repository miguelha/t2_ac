# you must put here the necessary code to deal with the interrupts

# enable interrupts
.data
ALL_INT_MASK: .word 0x0000ff00
KBD_INT_MASK: .word 0x00000100
RCR:	.word 	0xffff0000
RDR:	.word	0xffff0004


.text
int_enable:
	mfc0 $t0, $12
	lw $t1, ALL_INT_MASK
	not $t1, $t1
	and $t0, $t0, $t1
	lw $t1, KBD_INT_MASK
	or $t0, $t0, $t1
	mtc0 $t0, $12
	
	# now enable interrupts on the KBD
	lw $t0, RCR
	li $t1, 0x00000002
	sw $t1, 0($t0)
	jr $ra
	
	
# interrupt handler
.ktext 0x80000180

	# save all registers from the current process needed for context switching to the PCB (prepare to switch tasks)
	lw $k0, running
	sw $v0, 4($k0)
	sw $v1, 8($k0)
	sw $a0, 12($k0)
	sw $a1, 16($k0)
	sw $a2, 20($k0)
	sw $a3, 24($k0)
	sw $t0, 28($k0)
	sw $t1, 32($k0)
	sw $t2, 36($k0)
	sw $t3, 40($k0)
	sw $t4, 44($k0)
	sw $t5, 48($k0)
	sw $t6, 52($k0)
	sw $t7, 56($k0)
	sw $s0, 60($k0)
	sw $s1, 64($k0)
	sw $s2, 68($k0)
	sw $s3, 72($k0)
	sw $s4, 76($k0)
	sw $s5, 80($k0)
	sw $s6, 84($k0)
	sw $s7, 88($k0)
	sw $t8, 92($k0)
	sw $t9, 96($k0)
	sw $k0, 100($k0)
	sw $k1, 104($k0)
	sw $gp, 108($k0)
	sw $sp, 112($k0)
	sw $fp, 116($k0)
	sw $ra, 120($k0)
	# now use k1 to save registers that cannot be directly saved
	mfhi $k1
	sw $k1, 124($k0)
	mflo $k1
	sw $k1, 128($k0)
	mfc0 $k1, $14
	sw $k1, 132($k0)
	move $k1, $at
	sw $k1, 0($k0)
	
	
	
	mfc0 $k0, $13
	srl $t1, $k0, 2
	andi $t1, $t1, 0x1f
	
	bnez $t1, non_int
	
	andi $t2, $k0, 0x00000100
	bnez $t2, tick
	b iend
	
tick:
	lw $s1, RCR
	lw $t1, 0($s1)
	beqz $t1, iend
	
	# switching logic
	lw $t1, running
	lw $t2, ready
	
	lw $t3, 140($t2) # remove the first element in the ready list
	sw $t3, ready
	
	lw $t4, lastready
	sw $t1, 140($t4)
	sw $t1, lastready
	sw $zero, 140($t1)
	
	sw $t2, running
	b iend

non_int:
	mfc0 $k0, $14
	addiu $k0, $k0, 4
	mtc0 $k0, $14
	
iend:
	# the new task must be changed to execution (running) before restoring the register values
	
	lw $k0, running
	lw $k1, 124($k0)
	mthi $k1
	lw $k1, 128($k0)
	mtlo $k1
	lw $k1, 132($k0)
	mtc0 $k1, $14
	lw $k1, 0($k0)
	move $at, $k1
	# now load the rest of the registers directly
	lw $v0, 4($k0)
	lw $v1, 8($k0)
	lw $a0, 12($k0)
	lw $a1, 16($k0)
	lw $a2, 20($k0)
	lw $a3, 24($k0)
	lw $t0, 28($k0)
	lw $t1, 32($k0)
	lw $t2, 36($k0)
	lw $t3, 40($k0)
	lw $t4, 44($k0)
	lw $t5, 48($k0)
	lw $t6, 52($k0)
	lw $t7, 56($k0)
	lw $s0, 60($k0)
	lw $s1, 64($k0)
	lw $s2, 68($k0)
	lw $s3, 72($k0)
	lw $s4, 76($k0)
	lw $s5, 80($k0)
	lw $s6, 84($k0)
	lw $s7, 88($k0)
	lw $t8, 92($k0)
	lw $t9, 96($k0)
	lw $k1, 104($k0)
	lw $gp, 108($k0)
	lw $sp, 112($k0)
	lw $fp, 116($k0)
	lw $ra, 120($k0)
	lw $k0, 100($k0) # since k0 is used for addressing, it must be the last register to be restored

	mtc0 $zero, $13
	mfc0 $k0, $12
	andi $k0, 0xfffd
	ori $k0, 0x0001
	mtc0 $k0, $12
	eret

	
