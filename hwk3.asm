# Gabriello Lima
# glima
# 112803276

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text
load_game:
	#save on stack
	addi $sp, $sp, -28 #save 4 s registers on stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	move $s0, $a0 #s0 stores the game state address
	move $s1, $a1 #s1 stores the filename address
	#check if file exists
	
	
	#open the file
	move $a0, $a1 #load the filename into a0
	li $a1, 0 #flag to read the file
	li $a2, 0 # mode is ignore
	li $v0, 13 #read the fill
	syscall
	move $s2, $v0 #saves the file descriptor
	#if the file descriptor is -1 jump
	li $t1, -1
	beq $s2, $t1, invalid_file_input
	
	move $fp, $sp #save the sp before we iterate through the double array onto fp
	
	#grab row and col off the stack and save in s2, s3
	li $t1, '\r' #character to skip over
	li $t2, '\n' #character to skip over							#HEREHEREHEREHEREHERE
	li $t3, 0 #number of chars we pulled out to make the row
	li $t6, 1 #used to do row and col
	get_row_from_file:
		li $t1, '\r' #character to skip over
		li $t2, '\n' #character to skip over	
		
		addi $sp, $sp, -4 #make space on the stack
		move $a0, $s2 #file descriptor
		move $a1, $sp #where we save the byte
		li $a2, 1 #1 character at a time
		li $v0, 14
		syscall
		lw $t4, 0($sp)
		
		#
		#lets print the characters as we grab them
		#li $v0, 1
		#lw $t9, 0($sp)
		#move $a0, $t9
		#syscall
		
		#li $a0, '_'
		#li $v0, 11
		#syscall
		
		#
		beq $t4, $t1, remove_endline_from_stack_row
		beq $t4, $t2, remove_endline_from_stack_row
		addi $t3, $t3, 1
		j get_row_from_file
		
		
		remove_endline_from_stack_row:
			addi $sp, $sp, 4 #deletes the allocated memory for the character we loaded so it goes bye bye
			beq $t3, $t1, get_row_from_file #accounts for \r and \n case then
			j get_row_decimal
		get_row_decimal:
			li $t4, 1
			beq $t3, $t4, one_row_decimal
			beqz $t3, get_row_from_file						#herhereherherer	HEREHERHEHERHGSDERTGRSETDHSEG
			j two_row_decimal
		one_row_decimal:
			lw $s3, 0($sp) #s3 stores the row now
			addi $s3, $s3, -48
			#
			#li $v0, 1
			#move $a0, $s3
			#syscall
			
			#li $a0, '_'
			#li $v0, 11
			#syscall
			#
													
			#																														#####
			j finished_row_get_col
		two_row_decimal:
			lw $s3, 0($sp) #s3 stores 10^0 of row now
			addi $s3, $s3, -48										####
			lw $t4, 4($sp) 
			addi $t4, $t4, -48 										#####
			li $t5, 10
			mul $t4, $t4, $t5 # t4 *=10
			add $s3, $s3, $t4 #s3 now stores the row value
			#
			#li $v0, 1
			#move $a0, $s3
			#syscall
			#li $a0, '_'
			#li $v0, 11
			#syscall
			
			#
			j finished_row_get_col
			
	finished_row_get_col:
		move $sp, $fp #deallocates the stack, now I just need to repeat above
		addi $t6, $t6, -1
		beqz $t6, store_row_get_col
		j finished_getting_row_and_col
		
		store_row_get_col:
			move $s4, $s3 #s4 now stores row
			li $t3, 0
			j get_row_from_file
		
		
	finished_getting_row_and_col: #s3 stores col s4 stores row
	sb $s4, 0($s0) #stores num rows 
	sb $s3, 1($s0) #stores num cols
	
	
	
	#read from the file
	li $t0, 0 #will be used to keep track of number of wall characters '#' found
	li $t1, '\r' #character to skip over
	li $t2, '\n' #character to skip over
	li $t4, '#' #wall character
	li $t5, 'a' #apple character
	li $t6, 0 #used to denote if we found an apple or not while reading
	li $t7, '1' #used to denote the head of the snake
	li $t8, 0 #will be used to keep track of how many times we've iterated through the rows/columns properly
	li $s5, 0 #s5 will denote the length of the snake
	move $s6, $s0 #s6 will be a copy of s0 for math purposes
	addi $s6, $s6, 5 #the place where we start storing values...
	#before we do the main loop store numrows and numcols then iterate 
	#we know max size is 99x99
	
	#gonna have to keep track of number of things we've stored so we can get the headrow and headcolumn using mod arithmetic
	read_from_file_load_game_loop:
		#li $t1, '\r' #character to skip over											KKKKKKKKKKKKKKKKK
		addi $sp, $sp, -4 #make space on the stack
		move $a0, $s2 #file descriptor
		move $a1, $sp #where we save the byte
		li $a2, 1 #1 character at a time
		li $v0, 14
		syscall
		beqz $v0, finished_reading_from_file_loop #we're done with the file if v0 is 0
		#addi $t8, $t8, 1 #increments number of times we've gone through double array...				#######1111111111
		lw $t3, 0($sp) #loads the character we just saved on the stack
		beq $t3, $t1, remove_endline_from_stack
		beq $t3, $t2, remove_endline_from_stack
		addi $t8, $t8, 1 #increments number of times we've gone through double array...
		#if its not an endline store it in the 6($s0) and increment s6 accordingly...
		sb $t3, 0($s6)
		addi $s6, $s6, 1 #increment s6 by one to store next string...
		
		#li $t1, 1													#KKKKKKKKKKKKKKKKKK
		beq $t3, $t4, increment_number_wall_characters_found
		beq $t3, $t5, found_an_apple_in_read_loop
		beq $t3, $t7, found_head_of_snake_in_loop									#t7 used to be t1
		li $t9, '.'
		beq $t3, $t9, read_from_file_load_game_loop
		#IF IT MAKES IT HEAR IT MEANS ITS A PART OF THE SNAKE
		addi $s5, $s5, 1 #increase the length of the snake
		#need something at the end here... if its none of the above just call read again
		j read_from_file_load_game_loop
		remove_endline_from_stack:
			#addi $t8, $t8, -1												#111111111111111111111111
			addi $sp, $sp, 4 #deletes the allocated memory for the character we loaded so it goes bye bye
			j read_from_file_load_game_loop
		increment_number_wall_characters_found:
			addi $t0, $t0, 1
			j read_from_file_load_game_loop
		found_an_apple_in_read_loop:
			li $t6, 1
			j read_from_file_load_game_loop
		found_head_of_snake_in_loop:
			addi $t8, $t8, -1
			div $t8, $s3 #divide total by col count
			#head row = quotient
			mflo $t9
			sb $t9, 2($s0)
			#head col = remainder
			mfhi $t9
			sb $t9, 3($s0)
			j read_from_file_load_game_loop
		
			
			
			
	finished_reading_from_file_loop:
		move $sp, $fp									#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		#since head isnt counted we increment by one
		addi $s5, $s5, 1
		sb $s5, 4($s0) #stores the length of the snake.
	    	li $v0, 16 #used to close the file
		move $a0, $s2 #a0 stores the file descriptor
		syscall
		
		move $v0, $t6
		move $v1, $t0 #v1 stores the number of wall characters we found
	
	
	#lb $t0, 0($s0) #t0 = number rows
	#lb $t1, 0($s0) #t1 = number cols
	#lb $t2, 0($s0) #t2 = head row
	#lb $t3, 0($s0) #t3 = head columns
		j deallocate_stack_load_game
    
    	invalid_file_input:
    		li $v0, 16 #used to close the file
		move $a0, $s2 #a0 stores the file descriptor
		syscall
    		li $v0, -1
		li $v1, -1
		j deallocate_stack_load_game
	deallocate_stack_load_game:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 28 #deallocates memory
		jr $ra
get_slot:
	addi $sp, $sp, -12 #save 4 s registers on stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	move $s0, $a0 #s0 stores game state
	move $s1, $a1 #s1 stores row... they're asking for
	move $s2, $a2 #s2 stores col... they're asking for
			
	lb $t0, 0($s0) #stores VALID num rows
	lb $t1, 1($s0) #stores VALID num col
	
	bltz $s1, invalid_input_slot #invalid if input row is < 0
	bltz $s2, invalid_input_slot #invalid if input col is < 0
	bgt $s1, $t0, invalid_input_slot #invalid if row we're getting is greater than rows we have
	bgt $s2, $t1, invalid_input_slot # same as above but with columns
	#if it makes it here its probably valid input
	#if row is 0
	beqz $s1, row_zero_case
	#if col is 0
	beqz $s2, col_zero_case
	
	#mul $t2, $s1, $s2 # s1 * s2 = t2
	mul $t2, $s1, $t1 # s1 * t1 = t2 #t2 now stores the proper row positioning...
	add $t2, $t2, $s2 #t2 now has the proper col positioning....
	jump_here_get_slot:
	move $t3, $s0 #creates a copy of s0
	addi $t3, $t3, 5 #gets to the base address of the string...
	add $t3, $t3, $t2 #get the address of the character we want
	#add $t3, $t3, $t1 #increment to get next row TEST 				XXXXXXXXX
	lb $t4, 0($t3) #load the character into t4
	move $v0, $t4
	
	j deallocate_stack_get


	invalid_input_slot:
		li $v0, -1
		j deallocate_stack_get
   	row_zero_case:
   		move $t2, $s2
   		j jump_here_get_slot
   	col_zero_case:
		mul $t2, $s1, $t1 
		j jump_here_get_slot
	deallocate_stack_get:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12 #deallocate stack
		
		#move $a0, $v0													#DELETE LATER
		#li $v0, 11													#DELETE LATER
		#syscall														#DELETE LATER
		
	 	jr $ra
set_slot:
	
	#save on stack
	addi $sp, $sp, -12 #save 4 s registers on stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)




	move $s0, $a0 #s0 stores game state
	move $s1, $a1 #s1 stores row... they're asking for
	move $s2, $a2 #s2 stores col... they're asking for
			
	lb $t0, 0($s0) #stores VALID num rows
	lb $t1, 1($s0) #stores VALID num col
	
	bltz $s1, invalid_input_slot_set #invalid if input row is < 0
	bltz $s2, invalid_input_slot_set #invalid if input col is < 0
	bgt $s1, $t0, invalid_input_slot_set #invalid if row we're getting is greater than rows we have
	bgt $s2, $t1, invalid_input_slot_set # same as above but with columns
	#if it makes it here its probably valid input
	#if row is 0
	beqz $s1, row_zero_case_set
	#if col is 0
	beqz $s2, col_zero_case_set
	
	#mul $t2, $s1, $s2 # s1 * s2 = t2
	mul $t2, $s1, $t1 # s1 * t1 = t2 #t2 now stores the proper row positioning...
	add $t2, $t2, $s2 #t2 now has the proper col positioning....
	jump_here_get_slot_set:
	move $t3, $s0 #creates a copy of s0
	addi $t3, $t3, 5 #gets to the base address of the string...
	add $t3, $t3, $t2 #get the address of the character we want
	#add $t3, $t3, $t1 #increment to get next row TEST 				XXXXXXXXX
	
	
	sb $a3, 0($t3) #stores the character we want in the proper position
	
	
	move $v0, $a3
	j deallocate_stack_set


	invalid_input_slot_set:
		li $v0, -1
		j deallocate_stack_set
   	row_zero_case_set:
   		move $t2, $s2
   		j jump_here_get_slot_set
   	col_zero_case_set:
		mul $t2, $s1, $t1 
		j jump_here_get_slot_set
	deallocate_stack_set:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12 #deallocate stack
	 	jr $ra

place_next_apple:
	addi $sp, $sp, -24 #save s registers on stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	move $s0, $a0 #s0 stores game state
	move $s1, $a1 #s1 stores the apple array we're given
	move $s2, $a2 #s2 stores the number of pairs in the array

	#li $t0, 0 #will keep track of how many pairs we've used
	get_pairs_loop:					#replace all t0's with s3, replace all t1's w/ s4
		li $t4, '.'
		lb $s3, 0($s1) #row
		addi $s1, $s1, 1
		lb $s4, 0($s1) #col
		addi $s1, $s1, 1
		#addi $t0, $t0, 1
		
		move $a0, $s0 #game structure
		move $a1, $s3 #row we wanna check
		move $a2, $s4 #col we wanna check
		jal get_slot

		move $t3, $v0 #t3 stores the value we receieved
		bltz $t3, get_pairs_loop #if t3 is less than zero that means it the input (row and col) was invalid and we should go next
		li $t4, '.'
		beq $t3, $t4, found_valid_pair_now_set
		#if its not a valid pair, check that t0 < s2
		#blt $t2, 
		j get_pairs_loop
	found_valid_pair_now_set:
		addi $s1, $s1, -1
		li $t9, -1
		sb $t9, 0($s1) #col = -1										
		addi $s1, $s1, -1
		sb $t9, 0($s1) #row = -1
		move $a0, $s0 #game structure
		move $a1, $s3 #row we wanna set
		move $a2, $s4 #col we wanna set
		li $a3, 'a' #character we wanna set
		jal set_slot
		j deallocate_stack_place_apple
		
	deallocate_stack_place_apple:
		move $v0, $s3 #row we placed
		move $v1, $s4 #col we placed
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $ra, 20($sp)
		addi $sp, $sp, 24 #save s registers on stack
    		jr $ra

find_next_body_part:
	addi $sp, $sp, -20 #save s registers on stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	
	
	move $s0, $a0 #game strucutre
	move $s1, $a1 #row given
	move $s2, $a2 #col given
	move $s3, $a3 #target given
	
	#state row col
	move $a0, $s0
	move $a1, $s1
	addi $s2, $s2, 1
	move $a2, $s2 #col + 1
	jal get_slot
	beq $v0, $s3, found_target_part
	
	
	#state row col
	move $a0, $s0
	move $a1, $s1
	addi $s2, $s2, -2
	move $a2, $s2 #col + 1
	jal get_slot
	beq $v0, $s3, found_target_part
		#state row col
	move $a0, $s0
	addi $s1, $s1, 1
	move $a1, $s1
	addi $s2, $s2, 1
	move $a2, $s2 #col + 1
	jal get_slot
	beq $v0, $s3, found_target_part
	
	move $a0, $s0
	addi $s1, $s1, -2
	move $a1, $s1
	move $a2, $s2 #col + 1
	jal get_slot
	beq $v0, $s3, found_target_part
	j didnt_find_target_part

	found_target_part:
		move $v0, $s1
		move $v1, $s2
		j deallocate_stack_find_target
	didnt_find_target_part:
		li $v0, -1
		li $v1, -1
		j deallocate_stack_find_target
	
	deallocate_stack_find_target:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $ra, 16($sp)
		addi $sp, $sp, 20 #save s registers on stack
    jr $ra

slide_body: #state, row change, col change, apple[], apples length
	addi $sp, $sp, -36 #save s registers on stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp)


	move $s0, $a0 #state
	move $s1, $a1 #row movement
	move $s2, $a2 #col movement
	move $s3, $a3 #apple[] 
	lw $s4, 36($sp) # apple length
	
	lb $t0 2($s0) #t2 = headrow current
	lb $t1 3($s0) #t3 = headcol current

	add $s1, $s1, $t0 #new headrow
	add $s2, $s2, $t1 #new headcol
	
	#if apple is where new head is going to be, call place next apple
	move $a0, $s0 #state
	move $a1, $s1  #current head row 
	move $a2, $s2 #current head col
	jal get_slot
	#if return is not an apple and its not a . , then it's invalid and return -1 in v0
	move $t0, $v0 #t0 sotres the return
	li $t1, 'a'
	li $t2, '.'
	beq $t0, $t1, found_an_apple_slide
	beq $t0, $t2, found_a_valid_spot_slide
	j not_a_valid_spot_slide
	found_an_apple_slide:
		li $s7, 1 #s7 will store what we're going to return in $v0
		#place next apple
		move $a0, $s0 #state
		move $a1, $s3 #apple []
		move $a2, $s4 #apple length
		jal place_next_apple
		#now its a valid spot
		j found_a_valid_spot_slide_after
	found_a_valid_spot_slide:
		li $s7, 0 #s7 will store what we're going to return in $v0
		found_a_valid_spot_slide_after:

		move $a0, $s0 #state
		sb $s1, 2($s0) #store new headrow								#HERE MAYBE?
		sb $s2, 3($s0) #store new headcol								#used to be 0,1 respectively
		move $a1, $s1 #new headrow
		move $a2, $s2 #new headcol
		li $a3, '1'
		jal set_slot #new head is placed
		
		move $s4, $s1 #make a copy of the new headrow
		move $s5, $s2 #make a copy of the new headcol
		li $s6, '1' #s6 = 1 for iteration purposes
		li $t5, ':'
		j iterate_through_snake_slide_loop
		
		iterate_through_snake_slide_loop: #replace s7 with t5
			move $a0, $s0 #state
			move $a1, $s4 #new headrow
			move $a2, $s5 #new headcol
			move $a3, $s6 #what we're looking for
			jal find_next_body_part #v0 = row #v1 = col
			li $t5, ':'
			bltz $v0, replace_tail_with_period_slide
			bltz $v1, replace_tail_with_period_slide
			move $s4, $v0 #new row
			move $s5, $v1 #new col
			addi $s6, $s6, 1 #increment s6 by one...
			beq $s6, $s7, jump_to_uppercase_alphabet_slide
			return_to_slide_here:
			move $a0, $s0 #state
			move $a1, $s4 #row we're replacing
			move $a2, $s5 #col we're replacing
			move $a3, $s6 #charater we're replacing row and col with
			jal set_slot 
			j iterate_through_snake_slide_loop
			
			replace_tail_with_period_slide:
				move $a0, $s0 #state
				move $a1, $s4 #row
				move $a2, $s5 #col
				li $a3, '.'
				jal set_slot
				j finished_sliding_snake
			jump_to_uppercase_alphabet_slide:
				li $s6, 'A'
				j return_to_slide_here
	not_a_valid_spot_slide:
		li $s7, -1 #s7 will store what we're going to return in $v0
		j deallocate_stack_slide
	finished_sliding_snake:
		j deallocate_stack_slide
		
	deallocate_stack_slide:
		move $v0, $s7
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		lw $ra, 32($sp)
		addi $sp, $sp, 36 #save s registers on stack
		jr $ra
add_tail_segment: #dont forget to update structure
	#state, direction char, tailrow, tailcol
	addi $sp, $sp, -20 #save s registers on stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	
	
	
	move $s0, $a0 #state
	move $s1, $a1 # char
	move $s2, $a2 #tailrow
	move $s3, $a3 #tailcol
	
	li $t0, 'U'
	li $t1, 'D'
	li $t2, 'R'
	li $t3, 'L'
	
	li $t4, 35
	lb $t5, 4($s0)
	beq $t4, $t5, invalid_tail_position
	
	beq $t0, $s1, move_tail_up
	beq $t1, $s1, move_tail_down
	beq $t2, $s1, move_tail_right
	beq $t3, $s1, move_tail_left
	j invalid_tail_position
	move_tail_up:
		addi $s2, $s2, -1
		j check_if_tail_position_valid
	move_tail_down:
		addi $s2, $s2, 1
		j check_if_tail_position_valid
	move_tail_right:
		addi $s3, $s3, 1
		j check_if_tail_position_valid
	move_tail_left:
		addi $s3, $s3, -1
		j check_if_tail_position_valid
	check_if_tail_position_valid:
		move $a0, $s0 #structure
		move $a1, $s2 #row
		move $a2, $s3 #col
		jal get_slot
		li $t0, '.'
		beq $t0, $v0, valid_tail_position
		j invalid_tail_position
		
			
	valid_tail_position:	
		#set character update structure
		li $t0, '1'
		lb $t1, 4($s0) #length of tail
		addi $t1, $t1, 1 #increase length
		sb $t1, 4($s0) #store in structure again
		li $t2, 1
		li $t3, ':'
		get_character_for_tail_loop:
			addi $t0, $t0, 1	
			addi $t2, $t2, 1
			beq $t0, $t3, jump_to_uppercase_tail
			return_here_tail_character_loop:
			beq $t2, $t1, got_character_for_tail
			j get_character_for_tail_loop
			
			jump_to_uppercase_tail:
				li $t0, 'A'
				j return_here_tail_character_loop
		got_character_for_tail:
		#last thing we have to do is set it
			move $a0, $s0 #structure
			move $a1, $s2 #row
			move $a2, $s3 #col
			move $a3, $t0 #character
			jal set_slot
			lb $t1, 4($s0) #length of tail
			move $v0, $t1 #store length in v0
			j deallocate_stack_tail_segment
			
	invalid_tail_position:
		li $v0, -1
		j deallocate_stack_tail_segment
	
	deallocate_stack_tail_segment:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $ra, 16($sp)
		addi $sp, $sp, 20 #save s registers on stack
    		jr $ra

increase_snake_length:
	addi $sp, $sp, -28 #save s registers on stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp)






	move $s0, $a0 #state
	move $s1, $a1 # char
	
	#call find next body part UNTIL we have the tail ROW AND COL
	# i need to keep track of character
	li $s2, '1'
	lb $s3, 2($s0) #head row
	lb $s4, 3($s0) #head col
	find_tail_row_and_col_loop: #state row col target
		li $t0, ':'
		addi $s2, $s2, 1 #increment it by 1...
		beq $s2, $t0, jump_to_uppercase_tailrowcol_loop
		return_here_rowcol_loop:
		move $a0, $s0 #structure
		move $a1, $s3 #row
		move $a2, $s4  #col
		move $a3, $s2 #char we want
		jal find_next_body_part
		bltz $v0, found_tail_rowcol_loop
		bltz $v1, found_tail_rowcol_loop
		move $s3, $v0 #save newrow in s3
		move $s4, $v1 #save newcol in s4
		j find_tail_row_and_col_loop
	
		jump_to_uppercase_tailrowcol_loop:
			li $s2, 'A'
			j return_here_rowcol_loop
	found_tail_rowcol_loop: #S3 STORES TAIL ROW S4 STORES TAIL COL
	
	li $t0, 'U'
	li $t1, 'D'
	li $t2, 'R'
	li $t3, 'L'
	li $s5, 0 #used for counting how many attempts we've had
	#inverted
	beq $t1, $s1, move_tail_up_length
	beq $t0, $s1, move_tail_down_length
	beq $t3, $s1, move_tail_right_length
	beq $t2, $s1, move_tail_left_length
	j invalid_tail_position_inlength
	move_tail_up_length:
		#state, direction char, tailrow, tailcol
		move $a0, $s0 #state
		li $a1, 'U'
		move $a2, $s3
		move $a3, $s4
		jal add_tail_segment #if v0 is less than 0 its invalid
		bgtz $v0, properly_added_tail
		addi $s5, $s5, 1
		li $t0, 4
		beq $s5, $t0, invalid_tail_position_inlength
		#if i make it here just jump next
		j move_tail_left_length
	move_tail_down_length:
		#state, direction char, tailrow, tailcol
		move $a0, $s0 #state
		li $a1, 'D'
		move $a2, $s3
		move $a3, $s4
		jal add_tail_segment #if v0 is less than 0 its invalid
		bgtz $v0, properly_added_tail
		addi $s5, $s5, 1
		li $t0, 4
		beq $s5, $t0, invalid_tail_position_inlength
		#if i make it here just jump next
		j move_tail_right_length
	move_tail_right_length:
		#state, direction char, tailrow, tailcol
		move $a0, $s0 #state
		li $a1, 'R'
		move $a2, $s3
		move $a3, $s4
		jal add_tail_segment #if v0 is less than 0 its invalid
		bgtz $v0, properly_added_tail
		addi $s5, $s5, 1
		li $t0, 4
		beq $s5, $t0, invalid_tail_position_inlength
		#if i make it here just jump next
		j move_tail_up_length
	move_tail_left_length:
		#state, direction char, tailrow, tailcol
		move $a0, $s0 #state
		li $a1, 'L'
		move $a2, $s3
		move $a3, $s4
		jal add_tail_segment #if v0 is less than 0 its invalid
		bgtz $v0, properly_added_tail
		addi $s5, $s5, 1
		li $t0, 4
		beq $s5, $t0, invalid_tail_position_inlength
		#if i make it here just jump next
		j move_tail_down_length

	invalid_tail_position_inlength:
		li $v0, -1
		j deallocate_stack_tail_length
	properly_added_tail:
		lb $v0, 4($s0)
		j deallocate_stack_tail_length
	deallocate_stack_tail_length:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $ra, 24($sp)
		addi $sp, $sp, 28 #save s registers on stack
    		jr $ra

move_snake: #state, char direction, apple[], apples length
	addi $sp, $sp, -20 #save s registers on stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	#slide_body: state, headrow, headcol, apple[], apples length
	#Up: headrow = -1, headocl = 0
	#Down: headrow = 1, headcol = 0
	#Right: headrow = 0, headcol = 1
	#Left: headrow = 0, headcol = -1
	move $s0, $a0 #state
	move $s1, $a1 #direction UDRL
	move $s2, $a2 #apple[]
	move $s3, $a3 #apple length
	
	li $t0, 'U'
	li $t1, 'D'
	li $t2, 'R'
	li $t3, 'L'
	
	li $t4, -1
	li $t5, 0
	beq $t0, $s1, move_snake_slide_call
	li $t4, 1
	li $t5, 0
	beq $t1, $s1, move_snake_slide_call
	li $t4, 0
	li $t5, 1
	beq $t2, $s1, move_snake_slide_call
	li $t4, 0
	li $t5, -1
	beq $t3, $s1, move_snake_slide_call
	j unsuccessful_movement
	move_snake_slide_call:
		move $a0, $s0 #state
		move $a1, $t4 #row move value
		move $a2, $t5 #col mov value
		move $a3, $s2 #apple array
		addi $sp, $sp, -4
		move $t0, $s3
		sw $t0, 0($sp)
		li $t0, 7918273    # putting some random garbage in $t0
		jal slide_body
		addi $sp, $sp, 4
		bltz $v0, unsuccessful_movement								#UUUUUUUUUUUUUUUUUUUUUUUUUUU
		bgtz $v0, snake_ate_apple
		#else its 0
		li $v0, 0
		li $v1, 1
		j deallocate_stack_move_snake


	unsuccessful_movement:
		li $v0, 0
		li $v1, -1
		j deallocate_stack_move_snake
	snake_ate_apple:
		move $a0, $s0 #state
		move $a1, $s1 #head movement
		jal increase_snake_length
		bltz $v0, unsuccessful_movement #increase returned -1
		#else it was a success
		li $v0, 100
		li $v1, 1
		j deallocate_stack_move_snake
		
	deallocate_stack_move_snake:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20 #save s registers on stack
	jr $ra

simulate_game: #state, string filename, string directions, int num_moves_to_execute, apples[], apples length
	addi $sp, $sp, -36 #save s registers on stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp)
	
	
	
	move $s0, $a0 #state
	move $s1, $a1 #filename 
	move $s2, $a2 #directions
	move $s3, $a3 #num moves
	move $s7, $s3 #copy of num moves value
	lw $s4, 36($sp) #apples[]                                                            xxxxxxxxxxxxxxxxxx HAVE TO CHANGE AFTER ALLOCATING STACK
	lw $s5, 40($sp) #apples length 							XXXXXXXXXXXXXXXXXXXX HAVE TO CHANGE AFTER ALLOCATING STACK.
	
	
	#1. Call load Game (state, filename)
	#move $a0, $s0
	#move $a1, $s1
	
	#lets print headrow and headcol b4 and after
	#lb $a0, 2($s0)
	#li $v0, 1
	#syscall
	
	#li $a0, '_'
	#li $v0, 11
	#syscall
	
	#lb $a0, 3($s0)
	#li $v0, 1
	#syscall
	
	move $a0, $s0				########
	move $a1, $s1				##########
	jal load_game
	
	#	li $a0, '_'
	#li $v0, 11
	#syscall
	
	#lb $a0, 2($s0)
	#li $v0, 1
	#syscall
	
	#li $a0, '_'
	#li $v0, 11
	#syscall
	
	#lb $a0, 3($s0)
	#li $v0, 1
	#syscall
	
	
	
	
	bltz $v0, failed_to_load_game
	bltz $v1, failed_to_load_game
	beqz $v0, place_apple_simulate #2
	j apple_was_found_simulate #2
	
	
	place_apple_simulate:
		#call palce next apple
		#state apple[] apple length
		move $a0, $s0
		move $a1, $s4
		move $a2, $s5
		jal place_next_apple
		j apple_was_found_simulate
	 apple_was_found_simulate:
	 #3 Initial a variable to store the total score to 0.
	li $s6, 0 #stores total score
	#4 big loop
	big_while_simulate_loop:
		#check if snakes length is less than 35
		li $t6, 35
		lb $t7, 4($s0) #length
		beq $t6, $t7, break_out_of_loop
		lb $t0, 0($s2) #get direction from directions
		addi $s2, $s2, 1 #increment direction to get
		li $t9, '\0'
		beq $t0, $t9, break_out_of_loop #break if its a null terminated string
		#call move_snake
		move $a0, $s0 #state
		move $a1, $t0 #character direction
		move $a2, $s4 #apple[]
		move $a3, $s5 #apples length
		jal move_snake
		bltz $v1, break_out_of_loop						#USED TO BE V0 TO CHECK
		li $t1, 100
		beq $v0, $t1, add_to_score
		j decrement_num_moves
	
		add_to_score:
			lb $t2, 4($s0) #length
			addi $t2, $t2, -1 #length-1
			mult $t2, $t1 # score * length-1 			#used to be s6 not t1
			mflo $t3
			add $s6, $t3, $s6 #s6 = s6 + s6 * length-1 where s6 = score
			j decrement_num_moves
	decrement_num_moves:
		addi $s3, $s3, -1
		beqz $s3, break_out_of_loop
		j big_while_simulate_loop
	
	break_out_of_loop:
		#li $t0, 35
		sub $v0, $s7, $s3 #number of executed moves
		move $v1, $s6
		j deallocate_stack_simulate_game
	
	failed_to_load_game:
		li $v0, -1
		li $v1, -1
		j deallocate_stack_simulate_game
		
	deallocate_stack_simulate_game:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		lw $ra, 32($sp)
		
		addi $sp, $sp, 36 #save s registers on stack
		jr $ra

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
