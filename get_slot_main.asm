.data
#row: .byte 1
#col: .byte 5

#row: .byte 2
#col: .byte 3

row: .byte -3
col: .byte 5




.align 2
state:
.byte 5  # num_rows
.byte 12  # num_cols
.byte 1  # head_row
.byte 5  # head_col
.byte 7  # length
# Game grid:
.asciiz ".............a.#.1..#......#.2..#......#.3..#........4567..."

.text
.globl main
main:
la $a0, state
lb $a1, row
lb $a2, col
jal get_slot

# You must write your own code here to check the correctness of the function implementation.
	move $a0, $v0
	li $v0, 1
	syscall

li $v0, 10
syscall

.include "hwk3.asm"
