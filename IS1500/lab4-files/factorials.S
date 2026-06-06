.text 

addi t0, zero, 8 		# t0 = input value, what we are taking factorial of 
addi t2, zero, 1		# let result value begin with 1 (t2)

base_cases: 	
	
	addi t1, zero, 1 	# let counter be 1 (t1)
	beq t0, t1, stop 	# if input number = 1 then done
	beq t0, zero, stop 	# if input number = 0 then done 
	
outer_loop:			# nested loop 
	
	addi ra, zero, 0
	add t1, t0, zero	# set counter t1 to input number (how many times we are adding)
	
repeat_add: 				# repeated addition 
	
	beq t1, zero, next_done 	# if t1 = 0 then done (cannot add)
	
	add ra, ra, t2 			# ra = ra + t2	
	addi t1, t1, -1 		# decremening the multiplication counter by 1 (n-1)
	
	beq zero, zero, repeat_add	# unconditional loop, jump back to the start until t1 = 0 
			
next_done: 

	add t2, ra, zero 		# we get the multiplication result which is in ra and copy it to t2 
	addi t0, t0, -1 		# decrementing the outer loop counter
	
	addi t1, zero, 1 
	beq t0, t1, stop 		# if input number = 1 (and t1 = 1) then stop, since we loop until n = 1 
	
	beq zero, zero, outer_loop 	# if we are not done, jump to the start of the outer loop 
	
stop: 
	beq zero, zero, stop 


	

