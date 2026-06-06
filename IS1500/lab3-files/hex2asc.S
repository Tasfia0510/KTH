  # hexmain.S
  # Written 2015-09-04 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

	.text
	.globl hex2asc

hex2asc:
	li	a0, 17		# test number (from 0 to 15)
	
	addi    sp,sp,-4
	sw      ra,0(sp)
	
	jal	hexasc		# call hexasc
	
	li	a7, 11	# write a0 to stdout
	ecall

	lw      ra,0(sp)
	addi    sp,sp,4
	jr      ra	

  # You can write your own code for hexasc here
  #
  
 hexasc:  
 	
 	andi a0, a0, 0xF 	# kollar på de sista fyra värderna (LSB) 
 	
 	li t0, 9		# kollar om värdet är 0-9
 	
 	ble a0, t0, help 	# mindre än eller lika med 9, om det är mindre än 9 går den till hjälpfunktionen
 	 
 	addi a0, a0, 55		# adderar med 55 till vårt tal så vi får bokstäver i ASCII 	
 	j done_for_now 
 	
 	help: 			# hjälp funktionen 
 	addi a0, a0, 48 	# adderar vårt tal med 48 så vi får vårt tal i ASCII
 	done_for_now:
 	
 	jr ra			
 	
 	
 	
 	
 	
 	
 	
