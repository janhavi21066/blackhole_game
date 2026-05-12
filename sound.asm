# CS/SE 2340 Term Project - Spring 2026
# Author: Janhavi Joshi
# sound.asm
# Sound effects using MARS MIDI syscall (syscall 31).
#
# Syscall 31 parameters:
#   $a0 = pitch     (0-127, 60=middle C)
#   $a1 = duration  (milliseconds)
#   $a2 = instrument (0=piano, 40=violin, 73=flute, etc.)
#   $a3 = volume    (0-127)
#
# Functions exported:
#   soundPlayerMove   - short upbeat note when player places
#   soundComputerMove - lower note when computer places
#   soundWin          - fanfare for player win
#   soundLose         - descending tones for player loss
#   soundBlackHole    - eerie tone when black hole is revealed
#

.include "SysCalls.asm"
.globl soundPlayerMove
.globl soundComputerMove
.globl soundWin
.globl soundLose
.globl soundBlackHole

.text

# -------------------------------------------------------
# soundPlayerMove: bright short note (C5)
# -------------------------------------------------------
soundPlayerMove:
    li   $a0, 72        # C5
    li   $a1, 2000       # 150ms
    li   $a2, 0         # piano
    li   $a3, 90        # volume
    li  $v0, SysMidiOutSync
    syscall
    jr   $ra

# -------------------------------------------------------
# soundComputerMove: lower note (G3)
# -------------------------------------------------------
soundComputerMove:
    li   $a0, 55        # G3
    li   $a1, 2000
    li   $a2, 40        # violin
    li   $a3, 80
    li  $v0, SysMidiOutSync
    syscall
    jr   $ra

# -------------------------------------------------------
# soundWin: ascending fanfare C4-E4-G4-C5
# -------------------------------------------------------
soundWin:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li   $a0, 60
    li $a1, 2000
    li $a2, 0
    li $a3, 100
    li  $v0, SysMidiOutSync
    syscall

    li   $a0, 64
    li $a1, 2000
    li $a2, 0
    li $a3, 100
    li  $v0, SysMidiOutSync
    syscall

    li   $a0, 67
    li $a1, 2000
    li $a2, 0
    li $a3, 100
    li  $v0, SysMidiOutSync
    syscall

    li   $a0, 72 
    li $a1, 4000
    li $a2, 0
    li $a3, 110
    li  $v0, SysMidiOutSync
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# -------------------------------------------------------
# soundLose: descending tones C5-G4-E4-C4
# -------------------------------------------------------
soundLose:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li   $a0, 72 
    li $a1, 2000 
    li $a2, 40
    li $a3, 90
    li  $v0, SysMidiOutSync
    syscall

    li   $a0, 67
    li $a1, 2000 
    li $a2, 40
    li $a3, 80
    li  $v0, SysMidiOutSync
    syscall

    li   $a0, 64 
    li $a1, 2000
    li $a2, 40
    li $a3, 70
    li  $v0, SysMidiOutSync
    syscall

    li   $a0, 60 
    li $a1, 4000
    li $a2, 40
    li $a3, 60
    li  $v0, SysMidiOutSync
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# -------------------------------------------------------
# soundBlackHole: low eerie rumble (A2, long)
# -------------------------------------------------------
soundBlackHole:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li   $a0, 33        # A2 - very low
    li   $a1, 6000
    li   $a2, 73        # flute for eeriness
    li   $a3, 100
    li  $v0, SysMidiOutSync
    syscall

    li   $a0, 30
    li   $a1, 8000
    li   $a2, 73
    li   $a3, 70
    li  $v0, SysMidiOutSync
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
