##############################################################################
#
#  KURS: 1DT093 2024.  Computer Architecture
#	
# DATUM: 12-10-2024
#
#  NAMN: Ahmed Radwan
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
	
	# Done if i == N
	beq	$t0, $a1, end_for_all	# If i == N, exit the loop
	
	# 4*i
	sll	$t1, $t0, 2		# Multiply i by 4 (shift left by 2) to get byte offset for the current index that we want to get its value
	
	# address = ARRAY + 4*i
	add	$t2, $a0, $t1		# Calculate the address of the current index 
	
	# n = A[i]
	lw	$t3, 0($t2)		# Load the value at address A[i] into $t3

       	# Sum = Sum + n
       	add	$v0, $v0, $t3		# Add the value of A[i] to sum

        # i++ 
        addi	$t0, $t0, 1		# Increment index i
        
  	# next element
  	j	for_all_in_array	# Jump back to the start of the loop
	
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

	# Initialize the length counter to 0
	addi    $v0, $zero, 0           # Initialize length to 0
	
	# Initialize the address pointer
	add	$t0, $zero, $a0	        # Set $t0 to the starting address of the string
	
for_characters_in_str:

	# Load the byte at the current address
	lb	$t1, 0($t0)	        # Load the byte (character) at address $t0 into $t1 because it's not a word, it's a byte
	
	# Check if the byte is the NULL terminator
	beq	$t1, $zero, end_for_str	# If it's NULL (0x00), exit the loop
	
	# Increment the length counter
	addi	$v0, $v0, 1	        # Increment the length
	
	# Move to the next byte (next character in the string)
	addi	$t0, $t0, 1	        # Increment the pointer to the next byte by adding 1 not 4!
	
	# Repeat the loop for the next character
	j	for_characters_in_str	# Jump back to the start of the loop
	
end_for_str:
	jr	$ra		        # Return to the caller
	
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
    addi    $sp, $sp, -12       # Reserve space on the stack for return address, $s0, and $s1
    sw      $ra, 8($sp)         # Save return address
    sw      $s0, 4($sp)         # Save $s0 (for string pointer)
    sw      $s1, 0($sp)         # Save $s1 (for callback address)

	#### Write your solution here ####
	### Hint: Since you're calling another function, do you need to store 
	### some registers somewhere, read more about caller saved and callee 
	### saved registers in the MIPS calling conventions.

	### Hint: If you store to a callee saved register, do you need to 
	### store the previous value to restore the old value for your caller?
	
    move    $s0, $a0            # Copy the address of the string into $s0 for pointer traversal
    move    $s1, $a1            # Store the callback address in $s1

loop_start:
    lb      $t0, 0($s0)         # Load the current character (byte) from the string into $t0
    beqz    $t0, loop_end       # If the character is NUL (end of string), exit loop

    # Call the callback with the address of the current character
    move    $a0, $s0            # Move the address of the current character to $a0
    jalr    $s1                 # Jump to the callback subroutine

    # Advance to the next character
    addi    $s0, $s0, 1         # Move to the next character (increment pointer)
    j       loop_start          # Repeat for the next character

loop_end:
    lw      $s1, 0($sp)         # Restore $s1
    lw      $s0, 4($sp)         # Restore $s0
    lw      $ra, 8($sp)         # Restore return address
    addi    $sp, $sp, 12        # Restore stack pointer
    jr      $ra                 # Return to caller
	

##############################################################################
#
#  DESCRIPTION: Transforms a lower case character [a-z] to upper case [A-Z].
#	
#        INPUT: $a0 - address of a character 
#
##############################################################################		
to_upper:
    lb      $t0, 0($a0)         # Load the byte (character) from the address in $a0

    # Check if the character is lowercase (between 'a' and 'z')
    li      $t1, 'a'            # Load ASCII value of 'a' (97)
    li      $t2, 'z'            # Load ASCII value of 'z' (122)
    
    blt     $t0, $t1, end_to_upper    # If char < 'a', it's not lowercase, so skip
    bgt     $t0, $t2, end_to_upper    # If char > 'z', it's not lowercase, so skip

    # Convert to uppercase by clearing the 6th bit (subtracting 32)
    andi    $t0, $t0, 0xDF      # Clear the 6th bit (0xDF = 11011111 in binary)

    # Store the modified character back to the same address
    sb      $t0, 0($a0)

end_to_upper:
    jr      $ra                 # Return to caller


##############################################################################
#
# DESCRIPTION: Reverses a string in place.
#
#       INPUT: $a0 - address to a NUL terminated string.
#
#      OUTPUT: The string at the input address is reversed in place.
#
##############################################################################
reverse_string:
    addi    $sp, $sp, -16       # Allocate stack space for 4 words
    sw      $ra, 12($sp)        # Save return address
    sw      $s0, 8($sp)         # Save $s0 (will be used for string start)
    sw      $s1, 4($sp)         # Save $s1 (will be used for string end)
    sw      $s2, 0($sp)         # Save $s2 (will be used for string length)

    move    $s0, $a0            # Save string start address (pointer to the start of the string)

    # Call string_length to get the length of the string
    jal     string_length
    move    $s2, $v0            # Save string length (in $s2)

    add     $s1, $s0, $s2       # Calculate the end address (start + length)
    addi    $s1, $s1, -1        # Adjust to point to the last character

swap_loop:
    bge     $s0, $s1, end_reverse  # If start >= end, we're done

    # Swap characters
    lb      $t0, 0($s0)         # Load character from start
    lb      $t1, 0($s1)         # Load character from end
    sb      $t1, 0($s0)         # Store end character at start
    sb      $t0, 0($s1)         # Store start character at end

    # Move pointers closer to the center
    addi    $s0, $s0, 1         # Increment start pointer
    addi    $s1, $s1, -1        # Decrement end pointer

    j       swap_loop           # Continue swapping

end_reverse:
    lw      $s2, 0($sp)         # Restore $s2
    lw      $s1, 4($sp)         # Restore $s1
    lw      $s0, 8($sp)         # Restore $s0
    lw      $ra, 12($sp)        # Restore return address
    addi    $sp, $sp, 16        # Deallocate stack space
    jr      $ra                 # Return to caller

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
	
STR_reverse_string:
	.asciiz "\n\nReversed string:\n\n"
	
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

	
	#jr	$ra
	
	##
	### reverse_string
	##

    	li      $v0, 4              # syscall for print string
    	la      $a0, STR_reverse_string  # load address of the message
    	syscall                      # print the message


	la      $a0, STR_str          # Load address of the string to reverse
	jal     reverse_string        # Call reverse_string

	jal     print_test_string     # Print the reversed string

    	li      $v0, 10             # exit syscall
   	syscall
    
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
	
