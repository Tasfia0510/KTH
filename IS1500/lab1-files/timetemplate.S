#############################################################
# Choose the macro syntax for RARS or DTEK-V board.         #
# The syntax for RARS is probably due to its MIPS heritage. #
#############################################################
###################
# Macros for RARS #
###################
.macro	PUSH (%reg)
	addi	sp,sp,-4
	sw	%reg,0(sp) 
.end_macro

.macro	POP (%reg)
	lw	%reg,0(sp)
	addi	sp,sp,4
.end_macro
###################
# Macros for DTEK #
###################
#.macro	PUSH reg
#	addi sp,sp,-4
#	sw \reg,0(sp) 
#.endm

#.macro	POP reg
#	lw	\reg,0(sp)
#	addi	sp,sp,4
#.endm
#############################################################

	.data
	.align 2
mytime:	.word 	0x5957
timstr:	.asciz 	"text more text lots of text\0"
	.text
	.globl timetemplate, tick, time2string

# Function for displaying a string with a newline at the end	
display_string:	
	li a7,4
	ecall
	li a0, 10
	li a7,11
	ecall
	jr ra
	
timetemplate:
	la	a0, timstr
	jal     display_string
	
	# wait a little
	li	a0, 2		# ms
	jal	delay
	
	# call tick
	la 	a0, mytime
	jal	tick
	
	# call your function time2string
	la	a0, timstr
	la	t0, mytime
	lw	a1, 0(t0)
	jal	time2string
	
	# go back and do it all again
	j	timetemplate

	
# tick: update time pointed to by $a0
tick:	lw	t0, 0(a0)	# get time
	addi	t0, t0, 1	# increase
	andi	t1, t0, 0xf	# check lowest digit
	sltiu	t2, t1, 0xa	# if digit < a, okay
	bnez	t2, tiend
	addi	t0, t0, 0x6	# adjust lowest digit
	
	andi	t1, t0, 0xf0	# check next digit
	sltiu	t2, t1, 0x60	# if digit < 6, okay
	bnez	t2, tiend
	addi	t0, t0, 0xa0	# adjust digit
	
	li	t3, 0xF
	slli	t3, t3, 0x8
	and	t1, t0, t3	# check minute digit
	addi	t3, x0, 0xA
	slli	t3, t3, 0x8
	slt	t2, t1, t3	# if digit < a, okay
	bnez	t2, tiend
	addi	t0, t0, 0x600	# adjust digit - this one's okay, it's lower than 0x7FF 
	
	li	t3, 0xF
	slli	t3, t3, 0xC
	and	t1, t0, t3	# check last digit
	addi	t3, x0, 0x6
	slli	t3, t3, 0xC
	slt	t2, t1, t3	# if digit < 6, okay
	bnez	t2, tiend
	
	li	t3, 0xA
	slli	t3, t3, 0xC
	add	t0, t0, t3	# adjust last digit
tiend:	sw	t0,0(a0)	# save updated result
	jr	ra		# return

#########################################################
# Place for your functions: time2string, hex2asc, delay.#
#########################################################

hex2asc:
	
	addi    sp,sp,-4
	sw      ra,0(sp)
	
	jal	hexasc		# call hexasc

	lw      ra,0(sp)
	addi    sp,sp,4
	jr      ra	

hexasc: 
	
	andi a0, a0, 0xF 	#sista 4 bits
	
	li t0, 9 		# temp värde 9
	ble a0, t0, help 	# mindre eller lika med 9 --> till hjälp funktionen
	
	addi a0, a0, 55 	# annars ska den addera a0 (minst 9) till decimalt startvärde så det blir A-F
	j done_for_now 		# om den gör det så är den klar och ska returnera värdet
	
	help: 			# hjälp funktion 
	addi a0, a0, 48 	# adderar a0 (0-9) till decimalt startvärde 48 (som korresponderar till 0 i ASCII) 
	
	done_for_now: 		# klar och returnerar värdet
	jr ra
	
delay:
	
	li a0, 250000		 
	
	while_loop:
	blez a0, done		# branch less or equal zero, om a0 <= 0 då körs inte while loopen och går direkt till done 
	addi a0, a0, -1 	# ms = ms - 1
	
	li a1, 0		# i = 0, kan vara temporärt 
	
	for_loop:
	beq a1, a0, done	# branch equal, om s1 och s2 är samma gå till while_loop 
	addi a1, a1, 1		# i = i + 1
	j for_loop
	
	done:
	jr ra
	
time2string:
	
	PUSH ra
	PUSH s0
	PUSH s1
	
	mv s1, a0 		# buffert, samma som att använda addi s7, a0, 0, flyttar bara över värdet "sparar", om vi inte använde detta så skulle allt annat försvinna när vi använder a0 
	mv s0, a1 		# tid i MMSS
	
	srli t0, s0, 12 	# flyttar ned byten till 0-3 plats 
	andi t0, t0, 0xF 	# minut tiotal - maskar ut de 4 lägsta bitarna (kollar endast dessa)
	
	srli t1, s0, 8		# minut ental  
	andi t1, t1, 0xF	# maskar ut 
	
	srli t2, s0, 4		#sekund tiotal
	andi t2, t2, 0xF	
	
	andi t3, s0, 0xF	#sekund ental

	mv a0, t0 		#minut tiotal skrivs ut
	jal hex2asc		
	sb a0, 0(s1)
		
	mv a0, t1 		#minut ental skrivs ut
	jal hex2asc
	sb a0, 1(s1)
	
	li t4, 0x3A 		#kolon skrivs ut 
	sb t4, 2(s1)
	
	# surprise assessment 
	andi a0, a1, 0xFF
	beqz a0, hour		# branch equal to zero 
	bnez a0, continue	# branch not equal to zero 
	
	hour:			# printar ut: "HOUR"
	li t0, 72
	li t1, 79
	li t2, 85
	li t3, 82
	
	sb t0, 0(s1)
	sb t1, 1(s1)
	sb t2, 2(s1)
	sb t3, 3(s1)
	
	sb x0, 4(s1)
	
	POP s1
	POP s0
	POP ra

	jr ra	
 
	
	continue:
	mv a0, t2 		#sekund tiotal skrivs ut 
	jal hex2asc
	sb a0, 3(s1)
	
	mv a0, t3 		#sekund ental skrivs ut 
	jal hex2asc
	sb a0, 4(s1)
	
	sb x0, 5(s1) 		# null byte 
			
	POP s1
	POP s0
	POP ra

	jr ra	
