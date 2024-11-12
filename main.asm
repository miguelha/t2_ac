#this is the entry point of the program
	.data
PCB: .space 1560 # 36*4 bytes per PCB for 10 PCBs
freepcb: .word 0
running: .word 0
readyHi: .word 0
readyLo: .word 0
lastreadyHi: .word 0
lastreadyLo: .word 0
waiting: .word 0
idle: .word 0

counter_interrupt_addr: .word 0xFFFF0013

ready: .word 0
lastready: .word 0

pcbstack: .space 320 # 8*4 bytes per stack for 10 tasks
freestack: .word 0
	
STRING_done: .asciiz "Multitask started\n"
STRING_main: .asciiz "\nTask Zero"
	
.eqv INCR_PCB 156
.eqv INCR_SP 32

.eqv AT 0
.eqv V0 4
.eqv V1 8
.eqv A0 12
.eqv A1 16
.eqv A2 20
.eqv A3 24
.eqv T0 28
.eqv T1 32
.eqv T2 36
.eqv T3 40
.eqv T4 44
.eqv T5 48
.eqv T6 52
.eqv T7 56
.eqv S0 60
.eqv S1 64
.eqv S2 68
.eqv S3 72
.eqv S4 76
.eqv S5 80
.eqv S6 84
.eqv S7 88
.eqv T8 92
.eqv T9 96
.eqv K0 100
.eqv K1 104
.eqv GP 108
.eqv SP 112
.eqv FP 116
.eqv RA 120
.eqv HI 124
.eqv LO 128
.eqv EPC 132
.eqv PID 136
.eqv TICKS_TO_SWITCH 140
.eqv PRIORITY 144
.eqv TICKS_TO_WAIT 148
.eqv NEXT 152

	.text
main:
# prepare the structures
	jal prep_multi
	
# newtask (t0)
	la $a0, t0
	li $a1, 1
	jal newtask
	
# newtask(t1)	
	la $a0, t1
	li $a1, 2
	jal newtask
	
# newtask(t2)
	la $a0, t2
	li $a1, 3
	jal newtask

# startmulti() and continue to 
# the infinit loop of the main function
	jal start_multi
	
	la $a0, STRING_done
	li $v0, 4
	syscall
	
infinit: 
	# Reapeatedly print a string
	la $a0, STRING_main
	li $v0, 4
	syscall
	b infinit

# the support functions	
prep_multi:
	la $t1, PCB
	sw $t1, running # put pcb of main task in execution
	sw $zero, ready # ready list starts empty since main task is already in execution
	sw $zero, lastready
	
	la $t2, pcbstack # store stack pointer, PID (0) and next PCB (0) in PCB (no EPC anymore!)
	sw $t2, SP($t1)
	sw $zero, PID($t1)
	sw $zero, NEXT($t1)
	
	addiu $t1, $t1, INCR_PCB # increment 1 position in PCB and stack
	addiu $t2, $t2, INCR_SP
	sw $t1, freepcb # store new freepcb and freestack addresses
	sw $t2, freestack
	
	jr $ra
	
newtask:
	lw $t1, freepcb # load freepcb and freestack addresses
	lw $t2, freestack
	
	sw $t2, SP($t1) # set new task PCB stack pointer, EPC, PID and next PCB
	sw $a0, EPC($t1) 
	sw $a1, PID($t1)
	li $t3, 3
	sw $t3, TICKS_TO_SWITCH($t1)
	sw $zero, NEXT($t1)
	
	lw $t3, ready # load ready list and check if its the first task
	beqz $t3, firsttask
	
	lw $t4, lastready # not the first task, process accordingly
	sw $t1, NEXT($t4)
	sw $t1, lastready
	b newtaskend
	
firsttask: 
	sw $t1, ready # is the first task, process accordingly
	sw $t1, lastready
	
newtaskend:
	addiu $t1, $t1, INCR_PCB # increment 1 position in PCB and stack
	addiu $t2, $t2, INCR_SP
	sw $t1, freepcb # store new freepcb and freestack addresses
	sw $t2, freestack

	jr $ra
    
    
start_multi:
	li $t0, 1
	la $t1, counter_interrupt_addr # enable digital lab sim counter interrupts (30/inst)
	lw $t1, 0($t1)
	sb $t0, 0($t1)
	jr $ra 

	.globl main
	.include "interrupt.asm"
	.include "t0.asm"
	.include "t1.asm"
	.include "t2.asm"
#END
