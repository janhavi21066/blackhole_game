Black Hole Game — User Manual 
CS/SE 2340 Term Project | Spring 2026 |  Janhavi Joshi  |  UTD 
1. Requirements 
To run this program you need: 
• MARS MIPS Simulator version 4.5 or later 
• Java 8 or later (MARS is a Java application) 
• All .asm files from the project ZIP in the same folder 
• MARS settings: Enable 'Permit extended (pseudo) instructions and 
formats' 
• MARS settings: Enable 'Initialize Program Counter to global main 
if defined' 
2. Project File Structure 
Your ZIP should be extracted so all files are in the same directory: 
main.asm    
board.asm 
input.asm   
computer.asm           
scoring.asm             
display.asm             
sound.asm             
SysCalls.asm           
<- The game loop and entry point 
<- Data structures, adjacency tables, and 
neighbour lookups. 
<- Handles player input and validation. 
<- Computer/AI random move generator and 
RNG seeding 
<- Calculates the final scores based on the 
Black Hole’s neighbours. 
<- Handles the ASCII triangular board 
rendering 
<- MIDI sound effects for moves, wins, and 
losses. 
<- Definitions for MARS syscall constants. 
ProjectReport_Janhavi_Joshi.docx 
UserManual_Janhavi_Joshi.docx 
3. How to Run in MARS 
Step 1: Open MARS 
Launch MARS by double-clicking the .jar file or running: java -jar Mars.jar 
Step 2: Configure MARS Settings 
Go to Settings menu and ensure the following are checked: 
• 'Permit extended (pseudo) instructions and formats' 
• 'Initialize Program Counter to global main if defined' 
Step 3: Open main.asm 
Click File > Open and navigate to your project folder. Open main.asm. MARS will 
automatically include all other modules via the .include directives. 
Step 4: Assemble 
Click the wrench icon (Assemble) or press F3. The Messages tab should show 
'Assemble operation completed successfully.' If you see errors, verify all .asm files are 
in the same folder. 
Step 5: Run 
Click the green play button (Run) or press F5. The program runs in the Run I/O tab at 
the bottom. All input and output happens there. 
. Playing the Game 
4.1 Game Flow 
The game is a Single Player vs Computer match. You will alternate turn placing tilers 
numbered 1 through 10. Once 20 tiles are placed, The one remaining empty cell is 
revealed as the Black Hole. 
4.2 Board Layout 
The board is a triangle with 6 rows and 21 cells (indices 1–21): 
[1] 
[2] [3] 
[4] [5] [6] 
[7] [8] [9] [10] 
[11][12][13][14][15] 
[16][17][18][19][20][21] 
4.3 Board Symbols 
During play, holes appear as: 
Symbol 
Meaning 
Empty hole — can be played 
| | 
|BH| 
Black Hole — revealed at game end 
Player's move number N 
(N) 
[N] 
Computer's move number N 
4.4 Taking Your Turn 
When prompted “Your turn! Enter a cell number (1-21):”, type the index 
number of the hole you want to fill and press Enter. 
• If you choose a number outside this range or a cell that is 
occupied, the game will display an error and ask you to try 
again. 
• After your valid move, the computer will automatically “think” 
and pick a random empty cell. 
4.5 Scoring and Winning 
The game ends when only one hole remains unfilled (the Black Hole), which is after 10 
rounds. The program then: 
• Reveals the Black Hole position on the board. 
• Sums the move numbers of all tiles adjacent to the Black Hole for 
each player and the computer. 
• Declares the participant with the LOWEST score the winner. 
5. Scoring Rules 
The Black Hole game uses a low-score-wins system.  It uses a lookup table to look up 
neighbours for each cell in the game. For each hole adjacent to the Black Hole: 
• If it belongs to Player: its move number is added to Player's 
score. 
• If it belongs to the Computer: its move number is added to the 
Computer's score. 
The participant with the lowest total score wins. 
6. Sound 
The game uses MIDI audio via MARS: 
• Player Move: A bright, upbeat piano note. 
• Computer Move: A lower-pitched violin note 
• Black Hole Reveal: An eerie, suspicious, low flute rumble. 
• Victory: An ascending four-note fanfare. 
• Defeat: A descending four-note sequence. 
Sound requires no special MARS configuration beyond the defaults. If sound does not 
play, ensure your system audio is enabled. 
7. Troubleshooting 
Problem 
Solution 
Ensure all .asm files are in the same folder as main.asm 
'Symbol not found' 
error on assemble 
Sound does not 
play 
Check system volume; MARS MIDI requires Java sound support 
Random moves seem 
identical 
MARS uses a time-seeded RNG; results vary each run 
