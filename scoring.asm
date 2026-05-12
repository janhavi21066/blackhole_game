# CS/SE 2340 Term Project - Spring 2026
# Author: Janhavi Joshi
# scoring.asm
# Scoring logic for Black Hole:
#   1. Find the black hole (last empty cell after 20 moves).
#   2. For each neighbor of the black hole, add its display
#      value to the owning player's score.
#   3. Announce the winner (lowest score wins).
#

.include "SysCalls.asm"
.globl calculateScores

.data
p1ScoreMsg:  .asciiz "\nPlayer 1 score (tiles touching Black Hole): "
p2ScoreMsg:  .asciiz "\nComputer score (tiles touching Black Hole): "
bhMsg:       .asciiz "\n*** Black Hole is at cell "
bhMsg2:      .asciiz " ***\n"
p1WinsMsg:   .asciiz "\nYou win! Congratulations!\n"
p2WinsMsg:   .asciiz "\nComputer wins! Better luck next time.\n"
tieMsg:      .asciiz "\nIt's a tie!\n"
divider:     .asciiz "\n==================================\n"
adjDebug:    .asciiz "  Adjacent tile value: "
newline:     .asciiz "\n"

.text

# -------------------------------------------------------
# calculateScores:
#   Reads blackHoleIndex (already set by findBlackHole
#   in main.asm after all rounds complete), iterates its
#   neighbors, sums scores, and announces the winner.
# Args: none
# Returns: none
# Calls: getNeighbors (board.asm)
# -------------------------------------------------------
calculateScores:
    addi $sp, $sp, -16
    sw   $ra, 12($sp)
    sw   $s0, 8($sp)
    sw   $s1, 4($sp)
    sw   $s2, 0($sp)

    # --- read the already-computed black hole index ---
    lw   $s0, blackHoleIndex    # set by findBlackHole in main.asm

    # print which cell it landed on (1-indexed for display)
    li   $v0, SysPrintString
    la   $a0, divider
    syscall
    li   $v0, SysPrintString
    la   $a0, bhMsg
    syscall
    li   $v0, SysPrintInt
    move $a0, $s0           # already 1-based
    syscall
    li   $v0, SysPrintString
    la   $a0, bhMsg2
    syscall

    # --- iterate neighbors and accumulate scores ---
    li   $s1, 0             # player 1 score
    li   $s2, 0             # computer score

    move $a0, $s0
    jal  getNeighbors       # $v0 = addr of neighbor list, $v1 = count
    move $t0, $v0           # $t0 = neighbor list address
    move $t1, $v1           # $t1 = neighbor count
    li   $t2, 0             # j = 0

scoreLoop:
    bge  $t2, $t1, scoreDone

    sll  $t3, $t2, 2
    add  $t4, $t0, $t3
    lw   $t5, 0($t4)        # $t5 = neighbor cell index
    blt  $t5, 0, nextNeighbor   # skip -1 sentinels

    # get board value at neighbor
    la   $t6, board
    sll  $t7, $t5, 2
    add  $t8, $t6, $t7
    lw   $t9, 0($t8)        # $t9 = board[neighbor]

    beq  $t9, $zero, nextNeighbor   # empty (shouldn't happen, but safe)

    # player 1 tiles: 1-10
    bgt  $t9, 10, isCompTile
    add  $s1, $s1, $t9      # add to player 1 score
    j    nextNeighbor

isCompTile:
    # computer tiles: 11-20, display value = stored-10
    addi $t9, $t9, -10
    add  $s2, $s2, $t9      # add to computer score

nextNeighbor:
    addi $t2, $t2, 1
    j    scoreLoop

scoreDone:
    # print scores
    li   $v0, SysPrintString
    la   $a0, p1ScoreMsg
    syscall
    li   $v0, SysPrintInt
    move $a0, $s1
    syscall

    li   $v0, SysPrintString
    la   $a0, p2ScoreMsg
    syscall
    li   $v0, SysPrintInt
    move $a0, $s2
    syscall

    li   $v0, SysPrintString
    la   $a0, newline
    syscall

    # --- determine winner (lowest score wins) ---
    blt  $s1, $s2, p1Wins
    bgt  $s1, $s2, p2Wins

    # tie
    li   $v0, SysPrintString
    la   $a0, tieMsg
    syscall
    j    scoreEnd

p1Wins:
    li   $v0, SysPrintString
    la   $a0, p1WinsMsg
    syscall
    jal  soundWin
    j    scoreEnd

p2Wins:
    li   $v0, SysPrintString
    la   $a0, p2WinsMsg
    syscall
    jal  soundLose

scoreEnd:
    li   $v0, SysPrintString
    la   $a0, divider
    syscall

    lw   $ra, 12($sp)
    lw   $s0, 8($sp)
    lw   $s1, 4($sp)
    lw   $s2, 0($sp)
    addi $sp, $sp, 16
    jr   $ra