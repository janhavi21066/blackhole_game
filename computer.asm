# CS/SE 2340 Term Project - Spring 2026
# Author: Janhavi Joshi
# computer.asm
# Computer AI: picks a random empty cell from the board (1-21).
# Uses syscall 42 (RandIntRange) with range 21, then adds 1
# to shift from 0-20 into 1-21.
#

.include "SysCalls.asm"
.globl getComputerMove
.globl seedRandom

.data
compMsg: .asciiz "Computer is thinking...\n"

.text

seedRandom:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li   $v0, SysTime       
    syscall                 # $a0 = low 32 bits of time
    move $a1, $a0
    li   $a0, 0             # Use ID 0
    li   $v0, SysRandSeed   
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# -------------------------------------------------------
# getComputerMove
# -------------------------------------------------------
getComputerMove:
    addi $sp, $sp, -8       # Make room for $ra and $s0
    sw   $ra, 4($sp)
    sw   $s0, 0($sp)        # Use $s0 to safely store our move

    li   $v0, SysPrintString
    la   $a0, compMsg
    syscall

tryRandom:
    li   $a0, 0             # Match the ID used in seedRandom (0)
    li   $a1, 21            # Range 0-20
    li   $v0, SysRandIntRange
    syscall
    
    addi $s0, $a0, 1        # Result is 1-21. Store in $s0 (preserved)
    
    move $a0, $s0
    jal  isEmptyCell        # Returns $v0 = 1 if empty
    beq  $v0, $zero, tryRandom

    move $v0, $s0           # Return the valid move
    lw   $s0, 0($sp)
    lw   $ra, 4($sp)
    addi $sp, $sp, 8
    jr   $ra
