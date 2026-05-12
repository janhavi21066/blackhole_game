# CS/SE 2340 Term Project - Spring 2026
# Author: Janhavi Joshi
# display.asm
# Prints the 21-cell triangular game board in ASCII art.
#
# Board layout (1-based):
#                +----+
#                |  1 |
#             +----+----+
#             |  2 |  3 |
#          +----+----+----+
#          |  4 |  5 |  6 |
#       +----+----+----+----+
#       |  7 |  8 |  9 | 10 |
#    +----+----+----+----+----+
#    | 11 | 12 | 13 | 14 | 15 |
# +----+----+----+----+----+----+
# | 16 | 17 | 18 | 19 | 20 | 21 |
# +----+----+----+----+----+----+
#
# Cell encoding displayed as:
#   empty           ->  |    |
#   black hole      ->  | BH |
#   player tile N   ->  |(N) |
#   computer tile N ->  |[N] |   (N = stored value - 10)
#


.include "SysCalls.asm"
.globl drawBoard

.data
hLine:      .asciiz "+----"
hCap:       .asciiz "+"
cellEmpty:  .asciiz "|    "
cellBH:     .asciiz "| BH "
p1Open:     .asciiz "| ("
p1Close:    .asciiz ")"
p2Open:     .asciiz "| ["
p2Close:    .asciiz "]"
space5:     .asciiz "     "
newline:    .asciiz "\n"
boardTitle: .asciiz "\n===== BLACK HOLE GAME BOARD =====\n"
legend:     .asciiz "  (N)=You  [N]=Computer  | BH |=Black Hole\n\n"

.text

# -------------------------------------------------------
# drawBoard: print the full triangular board
# Reads global board[] (indices 1-21) and blackHoleIndex.
# $s0 = base address of board array
# $s1 = row counter
# $s3 = cell index counter
# -------------------------------------------------------
drawBoard:
    addi $sp, $sp, -36
    sw   $ra, 32($sp)
    sw   $s0, 28($sp)
    sw   $s1, 24($sp)
    sw   $s2, 20($sp)
    sw   $s3, 16($sp)
    sw   $s4, 12($sp)
    sw   $s5, 8($sp)
    sw   $s6, 4($sp)
    sw   $s7, 0($sp)

    li   $v0, SysPrintString
    la   $a0, boardTitle
    syscall
    li   $v0, SysPrintString
    la   $a0, legend
    syscall

    la   $s0, board
    lw   $s7, blackHoleIndex    # -1 if no black hole yet

    li   $s1, 0                 # row (0-based, 0..5)
    li   $s3, 1                 # current cell index (starts at 1)

rowLoop:
    bge  $s1, 6, drawDone

    # cells in this row = s1 + 1
    addi $s2, $s1, 1

    # indent = (5 - s1) groups of 5 spaces
    li   $s4, 5
    sub  $s4, $s4, $s1
    jal  printIndent

    # top border
    li   $s5, 0
topBorder:
    bge  $s5, $s2, topBorderDone
    li   $v0, SysPrintString
    la   $a0, hLine
    syscall
    addi $s5, $s5, 1
    j    topBorder
topBorderDone:
    li   $v0, SysPrintString
    la   $a0, hCap
    syscall
    li   $v0, SysPrintString
    la   $a0, newline
    syscall

    # indent again for cell content
    li   $s4, 5
    sub  $s4, $s4, $s1
    jal  printIndent

    # cell content
    li   $s5, 0
cellLoop:
    bge  $s5, $s2, cellDone

    sll  $t0, $s3, 2
    add  $t1, $s0, $t0
    lw   $t2, 0($t1)            # board[s3]

    beq  $s3, $s7, printBH      # black hole cell
    beq  $t2, $zero, printEmpty
    bgt  $t2, 10, printComp

    # player tile
    li   $v0, SysPrintString
    la   $a0, p1Open
    syscall
    li   $v0, SysPrintInt
    move $a0, $t2
    syscall
    li   $v0, SysPrintString
    la   $a0, p1Close
    syscall
    j    nextCell

printComp:
    li   $v0, SysPrintString
    la   $a0, p2Open
    syscall
    li   $v0, SysPrintInt
    addi $a0, $t2, -10
    syscall
    li   $v0, SysPrintString
    la   $a0, p2Close
    syscall
    j    nextCell

printEmpty:
    li   $v0, SysPrintString
    la   $a0, cellEmpty
    syscall
    j    nextCell

printBH:
    li   $v0, SysPrintString
    la   $a0, cellBH
    syscall

nextCell:
    addi $s3, $s3, 1
    addi $s5, $s5, 1
    j    cellLoop

cellDone:
    li   $v0, SysPrintChar
    li   $a0, '|'
    syscall
    li   $v0, SysPrintString
    la   $a0, newline
    syscall

    # bottom border on last row only
    bne  $s1, 5, skipBottom
    li   $s4, 5
    sub  $s4, $s4, $s1
    jal  printIndent
    li   $s5, 0
botBorder:
    bge  $s5, $s2, botBorderDone
    li   $v0, SysPrintString
    la   $a0, hLine
    syscall
    addi $s5, $s5, 1
    j    botBorder
botBorderDone:
    li   $v0, SysPrintString
    la   $a0, hCap
    syscall
    li   $v0, SysPrintString
    la   $a0, newline
    syscall

skipBottom:
    addi $s1, $s1, 1
    j    rowLoop

drawDone:
    li   $v0, SysPrintString
    la   $a0, newline
    syscall

    lw   $ra, 32($sp)
    lw   $s0, 28($sp)
    lw   $s1, 24($sp)
    lw   $s2, 20($sp)
    lw   $s3, 16($sp)
    lw   $s4, 12($sp)
    lw   $s5, 8($sp)
    lw   $s6, 4($sp)
    lw   $s7, 0($sp)
    addi $sp, $sp, 36
    jr   $ra

# -------------------------------------------------------
# printIndent: print $s4 copies of space5
# -------------------------------------------------------
printIndent:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    li   $t8, 0
indentLoop:
    bge  $t8, $s4, indentDone
    li   $v0, SysPrintString
    la   $a0, space5
    syscall
    addi $t8, $t8, 1
    j    indentLoop
indentDone:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
