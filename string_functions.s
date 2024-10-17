##############################################################################
#
#  KURS: 1DT093 2024.  Computer Architecture
#	
#  DATUM: 17-10-2024
#
#  NAMN: Ahmed  Radwan
#
##############################################################################

	j main		# Jump to the main function

	.data
	
ARRAY_SIZE:
	.word	10	# Change here to try other values (less than 10)
FIBONACCI_ARRAY:
	.word	1, 1, 2, 3, 5, 8, 13, 21, 34, 55
STR_str:
	.asciiz "Hunden, Katten, Glassen"

	.globl DBG
	.text

##############################################################################
#
# DESCRIPTION:  For an array of integers, returns the total sum of all
#		elements in the array.
#
# INPUT:        $a0 - address to first integer in array.
#		$a1 - size of array, i.e., numbers of integers in the array.
#
# OUTPUT:       $v0 - the total sum of all integers in the array.
#
##############################################################################
integer_array_sum:  

DBG:	##### DEBUGG BREAKPOINT ######

        addi    $v0, $zero, 0           # Initialize Sum to zero.
	add	$t0, $zero, $zero	# Initialize array index i to zero.
	
for_all_in_array:

	#### Append a MIPS-instruktion before each of these comments
	
	beq $t0,$a1,end_for_all #if index is 10 we jump to end for all calle
	
	sll $t1,$t0,2 #to temporary index t1 we save the array index with offset 4
	
	add $t2,$a0,$t1 # adds the offset to the adress of the current integer in the array, storing in t2
	
	lw $t3,0($t2) #load word, loads what's stored at t2 with offset 0 into t3 (an integer from our array)
       	
       	add $v0,$v0,$t3 #adds our integer in t3 to the sum v0 and stores/overwrites v0
        # i++ 
        addi $t0,$t0,1 #increments the index by 1
  	# next element
  	j for_all_in_array #loops back
	
end_for_all:
	
	jr	$ra			# Return to caller.
	
##############################################################################
#
# DESCRIPTION: Gives the length of a string.
#
#       INPUT: $a0 - address to a NUL terminated string.
#
#      OUTPUT: $v0 - length of the string (NUL excluded).
#
#    EXAMPLE:  string_length("abcdef") == 6.
#
##############################################################################	
string_length:
	#la $a0,STR_str #loading the adress of hunde katten glassen into a0
	#### Write your solution here ####
	addi $v0, $zero,0 #initializes the length of the string to 0
	add $t0,$zero,$a0 # here we add the adress of our string to t0
	
for_character_in_str:	
	lb $t1,0($t0) #load byte stored at t0 into t1
	 
	beq $t1,$zero,end_for_str #is the byte in question the NULL byte, if yes then we jump to end_for_str
	
	addi $v0,$v0,1 #increment the length counter by 1
	
	addi $t0,$t0,1 # Increments the adress by 1 byte, aka we go to the next letter
	j for_character_in_str #loops back 

end_for_str:
	jr	$ra
	
##############################################################################
#
#  DESCRIPTION: For each of the characters in a string (from left to right),
#		call a callback subroutine.
#
#		The callback suboutine will be called with the address of
#	        the character as the input parameter ($a0).
#	
#        INPUT: $a0 - address to a NUL terminated string.
#
#		$a1 - address to a callback subroutine.
#
##############################################################################	
string_for_each:
    addi    $sp, $sp, -12       #reserve space on the stack
    sw      $ra, 8($sp)         #save return address
    sw      $s0, 4($sp)         #save $s0 for string pointer
    sw      $s1, 0($sp)         #save $s1 for callback addres

    move    $s0, $a0            #copy the address of the string into $s0 for pointer traversal
    move    $s1, $a1            #store the callback address in $s1

loop_start:
    lb      $t0, 0($s0)         #load byte (the character) from adress s0 into t0
    beqz    $t0, loop_end       #If the character is NULL, exit loop

    # Call the callback with the address of the current character
    move    $a0, $s0            #Move the address of the current character to $a0
    jalr    $s1                 #Jump to the callback subroutine

    # next character
    addi    $s0, $s0, 1         #moving tto the next char by incrementing the pointer by 1
    j       loop_start          #Keep loopin

loop_end:
    lw      $s1, 0($sp)         #Restore $s1
    lw      $s0, 4($sp)         #Restore $s0
    lw      $ra, 8($sp)         #Restore return address
    addi    $sp, $sp, 12        #Restore stack pointer
    jr      $ra                 #Return to caller

##############################################################################
#
#  DESCRIPTION: Transforms a lower case character [a-z] to upper case [A-Z].
#	
#        INPUT: $a0 - address of a character 
#
##############################################################################		
to_upper:

	#### Write your solution here ####

    	lb      $t0, 0($a0)         #Loads the byte stored at adress a0 and putting it in t0

    	# Check if the character is lowercase (between 'a' and 'z')
    	li      $t1, 'a'            #Load Immediate of 'a' into t1 (97) ASCII
    	li      $t2, 'z'            #Load Immediate of 'z' into t2 (122)
	#This checks if t0 is smaller than a or greater than z (if true then it's already uppercase)
    	blt     $t0, $t1, end_to_upper    #If t0 is less than t1, end loop
    	bgt     $t0, $t2, end_to_upper    #If t0 greater than t2, end loop 

    	#Converting to upper by clearing the 6th bit (subtracting 32)
    	andi    $t0, $t0, 0xDF      #Clear the 6th bit (0xDF = 11011111 in binary) thus changing to uppercase

    	#Store the modified character back to the same address
    	sb      $t0, 0($a0) #Storing uppercase letter ($t0) back into same spot (adress $a0)

end_to_upper:
    	jr      $ra                 # Return to caller
    	
##############################################################################
#
#  DESCRIPTION: Reverses a string.
#	
#        INPUT: $a0 - address of a character 
#
##############################################################################
reverse_string:
    addi    $sp, $sp, -16       #allocate stack space
    sw      $ra, 12($sp)        #saving return address on the stack
    sw      $s0, 8($sp)         #saving $s0 (string start)
    sw      $s1, 4($sp)         #saving $s1 (string end)
    sw      $s2, 0($sp)         #saving $s2 (length of the string)

    move    $s0, $a0            # we save the character adress to $s0

    # Calling string_length to get the length of the string
    jal     string_length 	#uses string length to calculate length of string, returns v0
    move    $s2, $v0            #save string length v0 (in $s2)

    add     $s1, $s0, $s2       #calculate the end address (start + length) into s1 so ex 0 + 32 = 32
    addi    $s1, $s1, -1        #adjust to point to the last character and not next one

swap_loop:
    bge     $s0, $s1, end_reverse  #Branch if greater or equal to each other the start and end pointers, end the reverse loop

    # Swap characters
    lb      $t0, 0($s0)         #load character from start (adress s0)
    lb      $t1, 0($s1)         #load character from end (adress s1)
    sb      $t1, 0($s0)         #store end $t1 into start $s0
    sb      $t0, 0($s1)         #store start $t0 into end $s1

    # Move pointers closer to the center
    addi    $s0, $s0, 1         #increments the start pointer by 1
    addi    $s1, $s1, -1        #decrements end pointer by 1

    j       swap_loop           #Continue swap

end_reverse:
    lw      $s2, 0($sp)         #restore $s2
    lw      $s1, 4($sp)         #restore $s1
    lw      $s0, 8($sp)         #restore $s0
    lw      $ra, 12($sp)        #restore return address
    addi    $sp, $sp, 16        #deallocate stack space
    jr      $ra                 #Return




##############################################################################
#
# Strings used by main:
#
##############################################################################

	.data

NLNL:	.asciiz "\n\n"
	
STR_sum_of_fibonacci_a:	
	.asciiz "The sum of the " 
STR_sum_of_fibonacci_b:
	.asciiz " first Fibonacci numbers is " 

STR_string_length:
	.asciiz	"\n\nstring_length(str) = "

STR_for_each_ascii:	
	.asciiz "\n\nstring_for_each(str, ascii)\n"

STR_for_each_to_upper:
	.asciiz "\n\nstring_for_each(str, to_upper)\n\n"	

	#.text
	#.globl main
	
STR_reverse_string:
	.asciiz "\n\nreverse_string(str,ascii)\n\n"	

	.text
	.globl main

##############################################################################
#
# MAIN: Main calls various subroutines and print out results.
#
##############################################################################	
main:
	addi	$sp, $sp, -4	# PUSH return address
	sw	$ra, 0($sp)

	##
	### integer_array_sum
	##
	
	li	$v0, 4
	la	$a0, STR_sum_of_fibonacci_a
	syscall

	lw 	$a0, ARRAY_SIZE
	li	$v0, 1
	syscall

	li	$v0, 4
	la	$a0, STR_sum_of_fibonacci_b
	syscall
	
	la	$a0, FIBONACCI_ARRAY
	lw	$a1, ARRAY_SIZE
	jal 	integer_array_sum

	# Print sum
	add	$a0, $v0, $zero
	li	$v0, 1
	syscall

	li	$v0, 4
	la	$a0, NLNL
	syscall
	
	la	$a0, STR_str
	jal	print_test_string

	##
	### string_length 
	##
	
	li	$v0, 4
	la	$a0, STR_string_length
	syscall

	la	$a0, STR_str
	jal 	string_length

	add	$a0, $v0, $zero
	li	$v0, 1
	syscall

	##
	### string_for_each(string, ascii)
	##
	
	li	$v0, 4
	la	$a0, STR_for_each_ascii
	syscall
	
	la	$a0, STR_str
	la	$a1, ascii
	jal	string_for_each

	##
	### string_for_each(string, to_upper)
	##
	
	li	$v0, 4
	la	$a0, STR_for_each_to_upper
	syscall

	la	$a0, STR_str
	la	$a1, to_upper
	jal	string_for_each
	
	la	$a0, STR_str
	jal	print_test_string
	
	
	lw	$ra, 0($sp)	# POP return address
	addi	$sp, $sp, 4
	
	##
	### reverse_string
	##
	#la	$a0, STR_str
	#jal reverse_string
	
	li      $v0, 4              # syscall for print string
    	la      $a0, STR_reverse_string  # load address of the message
    	syscall                      # print the message


    	la      $a0, STR_str          # Load address of the string to reverse
    	jal     reverse_string        # Call reverse_string

    	jal     print_test_string     # Print the reversed string
	
	li	$v0, 10		# Exit syscall
	syscall			# End execution
	
	#jr	$ra

##############################################################################
#
#  DESCRIPTION : Prints out 'str = ' followed by the input string surronded
#		 by double quotes to the console. 
#
#        INPUT: $a0 - address to a NUL terminated string.
#
##############################################################################
print_test_string:	

	.data
STR_str_is:
	.asciiz "str = \""
STR_quote:
	.asciiz "\""	

	.text

	add	$t0, $a0, $zero
	
	li	$v0, 4
	la	$a0, STR_str_is
	syscall

	add	$a0, $t0, $zero
	syscall

	li	$v0, 4	
	la	$a0, STR_quote
	syscall
	
	jr	$ra
	

##############################################################################
#
#  DESCRIPTION: Prints out the Ascii value of a character.
#	
#        INPUT: $a0 - address of a character 
#
##############################################################################
ascii:	
	.data
STR_the_ascii_value_is:
	.asciiz "\nAscii('X') = "

	.text

	la	$t0, STR_the_ascii_value_is

	# Replace X with the input character
	
	add	$t1, $t0, 8	# Position of X
	lb	$t2, 0($a0)	# Get the Ascii value
	sb	$t2, 0($t1)

	# Print "The Ascii value of..."
	
	add	$a0, $t0, $zero 
	li	$v0, 4
	syscall

	# Append the Ascii value
	
	add	$a0, $t2, $zero
	li	$v0, 1
	syscall


	jr	$ra
	
