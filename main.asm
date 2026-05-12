# CS/SE 2340 Term Project - Spring 2026
# Author: Janhavi Joshi
# main.asm
# Entry point and main game loop for the Black Hole game.
#
# Game flow:
#   1. Seed RNG
#   2. Reset board
#   3. Draw board
#   4. Alternate turns: player places tile, computer places tile
#      - Player tiles stored as 1-10 (round number)
#      - Computer tiles stored as 11-20 (round number + 10)
#   5. After 10 rounds (20 tiles placed), 1 cell remains = Black Hole
#   6. Calculate and display scores; announce winner
#   7. Ask to play again
#

.include "SysCalls.asm"
.globl main

.data
welcomeMsg:   .asciiz "\n========================================\n"
welcomeMsg2:  .asciiz "   Welcome to BLACK HOLE - MIPS Edition!\n"
welcomeMsg3:  .asciiz "========================================\n"
rulesMsg:     .asciiz "\nRules:\n"
rulesMsg2:    .asciiz "  - You and the computer each place tiles 1-10.\n"
rulesMsg3:    .asciiz "  - The last empty cell becomes the Black Hole.\n"
rulesMsg4:    .asciiz "  - Tiles touching the Black Hole score points.\n"
rulesMsg5:    .asciiz "  - LOWEST score wins!\n\n"
p1TurnMsg:    .asciiz "\n--- Round "
p1TurnMsg2:   .asciiz " | YOUR TURN (Tile "
p1TurnMsg3:   .asciiz ") ---\n"
compTurnMsg:  .asciiz "\n--- Computer places Tile "
compTurnMsg2: .asciiz " at cell "
compTurnMsg3: .asciiz " ---\n"
playAgainMsg: .asciiz "\nPlay again? (1=Yes, 0=No): "
byeMsg:       .asciiz "\nThanks for playing Black Hole! Goodbye!\n"
newline:      .asciiz "\n"

.text
main:
    # --- Welcome ---
    li   $v0, SysPrintString
    la   $a0, welcomeMsg
    syscall
    li   $v0, SysPrintString
    la   $a0, welcomeMsg2
    syscall
    li   $v0, SysPrintString
    la   $a0, welcomeMsg3
    syscall
    li   $v0, SysPrintString
    la   $a0, rulesMsg
    syscall
    li   $v0, SysPrintString
    la   $a0, rulesMsg2
    syscall
    li   $v0, SysPrintString
    la   $a0, rulesMsg3
    syscall
    li   $v0, SysPrintString
    la   $a0, rulesMsg4
    syscall
    li   $v0, SysPrintString
    la   $a0, rulesMsg5
    syscall

    # --- Seed RNG once ---
    jal  seedRandom

gameStart:
    # --- Reset board ---
    jal  resetBoard

    li   $s6, 1             # $s6 = current round (1..10)

    # Draw initial empty board
    jal  drawBoard

gameLoop:
    bgt  $s6, 10, gameOver  # all 10 rounds played

    # ---- Player 1 turn ----
    li   $v0, SysPrintString
    la   $a0, p1TurnMsg
    syscall
    li   $v0, SysPrintInt
    move $a0, $s6
    syscall
    li   $v0, SysPrintString
    la   $a0, p1TurnMsg2
    syscall
    li   $v0, SysPrintInt
    move $a0, $s6
    syscall
    li   $v0, SysPrintString
    la   $a0, p1TurnMsg3
    syscall

    jal  getPlayerMove      # $v0 = 0-based chosen cell
    move $s0, $v0

    # store player tile: value = round number (1-10)
    move $a0, $s0
    move $a1, $s6
    jal  placeTile

    jal  soundPlayerMove    # sound feedback

    jal  drawBoard

    # ---- Computer turn ----
    li   $v0, SysPrintString
    la   $a0, compTurnMsg
    syscall
    li   $v0, SysPrintInt
    move $a0, $s6
    syscall
    li   $v0, SysPrintString
    la   $a0, compTurnMsg2
    syscall

    jal  getComputerMove    # $v0 = 0-based chosen cell
    move $s1, $v0

    # print cell number (1-based)
    li   $v0, SysPrintInt
    move $a0, $s1           # already 1-based
    syscall
    li   $v0, SysPrintString
    la   $a0, compTurnMsg3
    syscall

    # store computer tile: value = round + 10 (11-20)
    move $a0, $s1
    addi $a1, $s6, 10
    jal  placeTile

    jal  soundComputerMove  # sound feedback

    jal  drawBoard

    addi $s6, $s6, 1        # next round
    j    gameLoop

gameOver:
    # All 10 rounds done. Find the black hole now (only once),
    # play reveal sound, redraw board, then score.
    jal  findBlackHole      # sets blackHoleIndex - called ONCE here only
    jal  soundBlackHole
    jal  drawBoard          # redraw showing {BH}
    jal  calculateScores    # reads blackHoleIndex, prints scores and winner

    # --- Play again? ---
    li   $v0, SysPrintString
    la   $a0, playAgainMsg
    syscall
    li   $v0, SysReadInt
    syscall
    beq  $v0, 1, gameStart

    li   $v0, SysPrintString
    la   $a0, byeMsg
    syscall

    li   $v0, SysExit
    syscall