# you must put here the necessary code to deal with the interrupts
.kdata
interrupt_counter: .word 0
	
	
# interrupt handler
.ktext 0x80000180

	# save all registers from the current process needed for context switching to the PCB (prepare to switch tasks)
	lw $k0, running
	sw $v0, V0($k0)
	sw $v1, V1($k0)
	sw $a0, A0($k0)
	sw $a1, A1($k0)
	sw $a2, A2($k0)
	sw $a3, A3($k0)
	sw $t0, T0($k0)
	sw $t1, T1($k0)
	sw $t2, T2($k0)
	sw $t3, T3($k0)
	sw $t4, T4($k0)
	sw $t5, T5($k0)
	sw $t6, T6($k0)
	sw $t7, T7($k0)
	sw $s0, S0($k0)
	sw $s1, S1($k0)
	sw $s2, S2($k0)
	sw $s3, S3($k0)
	sw $s4, S4($k0)
	sw $s5, S5($k0)
	sw $s6, S6($k0)
	sw $s7, S7($k0)
	sw $t8, T8($k0)
	sw $t9, T9($k0)
	sw $k0, K0($k0)
	sw $k1, K1($k0)
	sw $gp, GP($k0)
	sw $sp, SP($k0)
	sw $fp, FP($k0)
	sw $ra, RA($k0)
	# now use k1 to save registers that cannot be directly saved
	mfhi $k1
	sw $k1, HI($k0)
	mflo $k1
	sw $k1, LO($k0)
	mfc0 $k1, $14
	sw $k1, EPC($k0)
	move $k1, $at
	sw $k1, AT($k0)
	
	
	
	mfc0 $k0, $13
	srl $t1, $k0, 2
	andi $t1, $t1, 0x1f
	
	bnez $t1, non_int
	
	andi $t2, $k0, 0x00000400
	bnez $t2, counter_interrupt
	b iend
	
counter_interrupt:

	la $t0, interrupt_counter
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)
	
	li $t2, 4
	bne $t1, $t2, iend
	
	sw $zero, 0($t0)
	
tick:
	# switching logic
	lw $t1, running
	lw $t2, ready
	
	lw $t3, NEXT($t2) # remove the first element in the ready list
	sw $t3, ready
	
	lw $t4, lastready
	sw $t1, NEXT($t4)
	sw $t1, lastready
	sw $zero, NEXT($t1)
	
	sw $t2, running
	b iend

non_int:
	mfc0 $k0, $14
	addiu $k0, $k0, 4
	mtc0 $k0, $14
	
iend:
	# the new task must be changed to execution (running) before restoring the register values
	
	lw $k0, running
	lw $k1, HI($k0)
	mthi $k1
	lw $k1, LO($k0)
	mtlo $k1
	lw $k1, EPC($k0)
	mtc0 $k1, $14
	lw $k1, A0($k0)
	move $at, $k1
	# now load the rest of the registers directly
	lw $v0, V0($k0)
	lw $v1, V1($k0)
	lw $a0, A0($k0)
	lw $a1, A1($k0)
	lw $a2, A2($k0)
	lw $a3, A3($k0)
	lw $t0, T0($k0)
	lw $t1, T1($k0)
	lw $t2, T2($k0)
	lw $t3, T3($k0)
	lw $t4, T4($k0)
	lw $t5, T5($k0)
	lw $t6, T6($k0)
	lw $t7, T7($k0)
	lw $s0, S0($k0)
	lw $s1, S1($k0)
	lw $s2, S2($k0)
	lw $s3, S3($k0)
	lw $s4, S4($k0)
	lw $s5, S5($k0)
	lw $s6, S6($k0)
	lw $s7, S7($k0)
	lw $t8, T8($k0)
	lw $t9, T9($k0)
	lw $k1, K1($k0)
	lw $gp, GP($k0)
	lw $sp, SP($k0)
	lw $fp, FP($k0)
	lw $ra, RA($k0)
	lw $k0, K0($k0) # since k0 is used for addressing, it must be the last register to be restored

	mtc0 $zero, $13
	mfc0 $k0, $12
	andi $k0, 0xfffd
	ori $k0, 0x0001
	mtc0 $k0, $12
	eret

	
