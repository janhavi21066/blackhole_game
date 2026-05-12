# CS/SE 2340 Term Project - Spring 2026
# Author: Janhavi Joshi
# input.asm
# Handles player input: prompt, range validation (1-21),
# and occupied-cell check.
# No index conversion needed — board is 1-based internally.

.include "SysCalls.asm"
.globl getPlayerMove

.data
promptMsg: .asciiz "Your turn! Enter a cell number (1-21): "
rangeErr:  .asciiz "  Invalid! Please enter a number between 1 and 21.\n"
takenErr:  .asciiz "  That cell is already taken! Try another.\n"

.text

# -------------------------------------------------------
# getPlayerMove: prompt until a valid, empty cell is chosen
# Args:   none
# Returns $v0 = cell index (1-21)
# Calls:  isEmptyCell (board.asm)
# -------------------------------------------------------
getPlayerMove:
    addi $sp, $sp, -8
    sw   $ra, 4($sp)
    sw   $s0, 0($sp)        # save $s0 so we can use it safely

askAgain:
    li   $v0, SysPrintString
    la   $a0, promptMsg
    syscall

    li   $v0, SysReadInt
    syscall
    move $s0, $v0           # $s0 = player input (1-21), safe across jal

    blt  $s0, 1,  badRange
    bgt  $s0, 21, badRange

    # check if cell is empty (index is already 1-based)
    move $a0, $s0
    jal  isEmptyCell        # $v0 = 1 if empty, 0 if taken
    beq  $v0, $zero, cellTaken

    move $v0, $s0           # return the valid cell index
    lw   $s0, 0($sp)
    lw   $ra, 4($sp)
    addi $sp, $sp, 8
    jr   $ra

badRange:
    li   $v0, SysPrintString
    la   $a0, rangeErr
    syscall
    j    askAgain

cellTaken:
    li   $v0, SysPrintString
    la   $a0, takenErr
    syscall
    j    askAgain
