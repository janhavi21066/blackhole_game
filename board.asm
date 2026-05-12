# CS/SE 2340 Term Project - Spring 2026
# Author: Janhavi Joshi
# board.asm
# Board data, adjacency lookup table, and board utility functions.
# Handles: place tile, check if empty, reset board, find black hole.
#
# Board layout (1-indexed, cells 1-21):
#
#              [ 1]
#           [ 2][ 3]
#        [ 4][ 5][ 6]
#      [ 7][ 8][ 9][10]
#   [11][12][13][14][15]
# [16][17][18][19][20][21]
#
# Encoding:
#   0       = empty
#   1-10    = Player 1 tiles  (display as-is)
#   11-20   = Computer tiles  (display as stored-10)
#
# Array is 22 words (index 0 unused; cells at indices 1-21).
#

.include "SysCalls.asm"
.globl board
.globl blackHoleIndex
.globl resetBoard
.globl isEmptyCell
.globl placeTile
.globl findBlackHole
.globl getNeighbors
.globl adjTable

.data

# board[0] unused; board[1]..board[21] are the 21 cells
board:          .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

# Index of the black hole (1-21, -1 if not yet found)
blackHoleIndex: .word -1

# -------------------------------------------------------
# Adjacency lookup table  (1-based cell indices)
#
# Cell  1: neighbors  2, 3
# Cell  2: neighbors  1, 3, 4, 5
# Cell  3: neighbors  1, 2, 5, 6
# Cell  4: neighbors  2, 5, 7, 8
# Cell  5: neighbors  2, 3, 4, 6, 8, 9
# Cell  6: neighbors  3, 5, 9,10
# Cell  7: neighbors  4, 8,11,12
# Cell  8: neighbors  4, 5, 7, 9,12,13
# Cell  9: neighbors  5, 6, 8,10,13,14
# Cell 10: neighbors  6, 9,14,15
# Cell 11: neighbors  7,12,16,17
# Cell 12: neighbors  7, 8,11,13,17,18
# Cell 13: neighbors  8, 9,12,14,18,19
# Cell 14: neighbors  9,10,13,15,19,20
# Cell 15: neighbors 10,14,20,21
# Cell 16: neighbors 11,17
# Cell 17: neighbors 11,12,16,18
# Cell 18: neighbors 12,13,17,19
# Cell 19: neighbors 13,14,18,20
# Cell 20: neighbors 14,15,19,21
# Cell 21: neighbors 15,20
#
# Each row: n0,n1,n2,n3,n4,n5,count  (7 words per cell)
# Row 0 is a dummy/unused row so cell N maps directly to row N.
# -------------------------------------------------------
adjTable:
    .word  0, 0,-1,-1,-1,-1, 0   # cell  0  (unused)
    .word  2, 3,-1,-1,-1,-1, 2   # cell  1
    .word  1, 3, 4, 5,-1,-1, 4   # cell  2
    .word  1, 2, 5, 6,-1,-1, 4   # cell  3
    .word  2, 5, 7, 8,-1,-1, 4   # cell  4
    .word  2, 3, 4, 6, 8, 9, 6   # cell  5
    .word  3, 5, 9,10,-1,-1, 4   # cell  6
    .word  4, 8,11,12,-1,-1, 4   # cell  7
    .word  4, 5, 7, 9,12,13, 6   # cell  8
    .word  5, 6, 8,10,13,14, 6   # cell  9
    .word  6, 9,14,15,-1,-1, 4   # cell 10
    .word  7,12,16,17,-1,-1, 4   # cell 11
    .word  7, 8,11,13,17,18, 6   # cell 12
    .word  8, 9,12,14,18,19, 6   # cell 13
    .word  9,10,13,15,19,20, 6   # cell 14
    .word 10,14,20,21,-1,-1, 4   # cell 15
    .word 11,17,-1,-1,-1,-1, 2   # cell 16
    .word 11,12,16,18,-1,-1, 4   # cell 17
    .word 12,13,17,19,-1,-1, 4   # cell 18
    .word 13,14,18,20,-1,-1, 4   # cell 19
    .word 14,15,19,21,-1,-1, 4   # cell 20
    .word 15,20,-1,-1,-1,-1, 2   # cell 21

.text

# -------------------------------------------------------
# resetBoard: zero cells 1-21, reset blackHoleIndex to -1
# Args: none  |  Returns: none
# -------------------------------------------------------
resetBoard:
    addi $sp, $sp, -4		# make room on the stack for 1 word (4 bytes)
    sw   $ra, 0($sp)		# save the return address

    la   $t0, board		# load the memory ADDRESS of board[0] into $t0
    li   $t1, 1			# i = 1  (we start at cell 1, not cell 0)
rbLoop:
    bgt  $t1, 21, rbDone	# if i > 21, we've cleared all cells, exit loop
    sll  $t2, $t1, 2		# $t2 = i * 4  (each word is 4 bytes, so multiply index by 4)
    add  $t2, $t0, $t2		# $t2 = base address + byte offset = address of board[i]
    sw   $zero, 0($t2)		# store 0 into board[i]  (mark cell as empty)
    addi $t1, $t1, 1		# i = i + 1
    j    rbLoop			
rbDone:
    la   $t0, blackHoleIndex	# load the address of the blackHoleIndex variable
    li   $t1, -1		# -1 means "not found yet"
    sw   $t1, 0($t0)		# store -1 into blackHoleIndex

    lw   $ra, 0($sp)		# restore the return address we saved at the top
    addi $sp, $sp, 4		# give back the 4 bytes we took from the stack
    jr   $ra			# jump back to wherever resetBoard was called from

# -------------------------------------------------------
# isEmptyCell: check if board[index] == 0
# Args:   $a0 = cell index (1-21)
# Returns $v0 = 1 if empty, 0 if taken
# -------------------------------------------------------
isEmptyCell:
    la   $t0, board		# load the memory ADDRESS of board[0] into $t0
    sll  $t1, $a0, 2		# $t1 = $a0 * 4  (convert cell index to byte offset)
    add  $t0, $t0, $t1		# $t0 = base address + byte offset = address of board[$a0]
    lw   $t2, 0($t0)		# load the value stored at board[$a0] into $t2
    seq  $v0, $t2, $zero	# $v0 = 1 if $t2 == 0, otherwise $v0 = 0
    jr   $ra

# -------------------------------------------------------
# placeTile: store value in board[index]
# Args:   $a0 = cell index (1-21)
#         $a1 = value to store
# Returns: none
# -------------------------------------------------------
placeTile:
    la   $t0, board		# load the memory ADDRESS of board[0] into $t0
    sll  $t1, $a0, 2		# $t1 = $a0 * 4  (convert cell index to byte offset)
    add  $t0, $t0, $t1		# $t0 = base address + byte offset = address of board[$a0]
    sw   $a1, 0($t0)		# store the tile value ($a1) into board[$a0]
    jr   $ra

# -------------------------------------------------------
# findBlackHole: scan board[1..21] for the remaining 0 cell
# Stores result in blackHoleIndex.
# Args: none  |  Returns: $v0 = index (1-21) of black hole
# -------------------------------------------------------
findBlackHole:
    addi $sp, $sp, -4		# make room on the stack for 1 word (4 bytes)
    sw   $ra, 0($sp)		# save the return address

    la   $t0, board		# load the memory ADDRESS of board[0] into $t0
    li   $t1, 1			# i = 1  (we start at cell 1, not cell 0)
fbhLoop:
    bgt  $t1, 21, fbhDone	# if i > 21, we've checked all cells, exit loop
    sll  $t2, $t1, 2		# $t2 = i * 4  (byte offset for cell i)
    add  $t3, $t0, $t2		# $t3 = base address + offset = address of board[i]
    lw   $t4, 0($t3)		# load the value at board[i] into $t4
    bne  $t4, $zero, fbhNext	# if board[i] != 0, this cell is taken — skip it
    
    # if we reach here, board[i] == 0 — this is the black hole
    la   $t5, blackHoleIndex	# load the ADDRESS of the blackHoleIndex variable
    sw   $t1, 0($t5)		# store i into blackHoleIndex so other functions can read it
    move $v0, $t1		# also return i in $v0 for the caller
    lw   $ra, 0($sp)		# restore return address
    addi $sp, $sp, 4		# restore stack pointer
    jr   $ra			# return
fbhNext:
    addi $t1, $t1, 1		# i = i + 1
    j    fbhLoop		# go back to the top and check the next cell
fbhDone:
    li   $v0, -1		# return -1 to signal "not found" (should never happen)
    lw   $ra, 0($sp)		# restore return address
    addi $sp, $sp, 4		# restore stack pointer
    jr   $ra			# return

# -------------------------------------------------------
# getNeighbors: return neighbor list for a cell
# Args:   $a0 = cell index (1-21)
# Returns $v0 = address of first neighbor word in adjTable
#         $v1 = number of neighbors
# -------------------------------------------------------
getNeighbors:
    la   $t0, adjTable		# load the memory ADDRESS of adjTable[0] into $t0
    li   $t1, 7			# 7 words per row
    mul  $t1, $a0, $t1     	# row offset in words = cell index * 7
    sll  $t1, $t1, 2        	# convert word offset to byte offset (multiply by 4)
    add  $v0, $t0, $t1		# $v0 = base address + byte offset = address of cell's row
    lw   $v1, 24($v0)       	# load the neighbor count from the 7th word (6*4 = 24 bytes in)
    jr   $ra
