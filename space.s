.equ  TIMER0_BASE,      0x10002000
.equ  TIMER0_STATUS,    0
.equ  TIMER0_CONTROL,   4
.equ  TIMER0_PERIODL,   8
.equ  TIMER0_PERIODH,   12
.equ  TIMER0_SNAPL,     16
.equ  TIMER0_SNAPH,     20

.equ KILLSWITCHRIGHT,0x08037254
.equ KILLSWITCHLEFT, 0x08037001
.equ JTAG_UART_BASE, 0x10001000
.equ JTAG_UART_RR, 0
.equ JTAG_UART_TR, 0
.equ JTAG_UART_CSR, 4
.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000
.equ maxPixel, 0x0803BE7E
.equ DefaultTankBase, 0x08037118 /* starting tank position*/
.equ MinAlienBase, 0x080078AA /* starting alien position*/
.equ black, 0x0000
.equ white, 0xffff
.equ green, 0x0fa0
.equ red, 0xff00
.equ TankBorder, 0x08032000
.equ TankBorderMax, 0x08032280
.equ AlienRefresh, 0x08006400

 .global _start
 
 
.section .data

array:
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1
.word 0x1







 TipVariable: .word 0x08035128
 VariableTankBase: .word 0x08037118
 MoveTank: .word 0x1
 MoveAliens: .word 0x1
 Level: .word 0x1
 VariableAlienBase: .word 0x080078AA
 VariableTimerPeriod: .word 0x0017D7840
 CollisionVariable: .word 0x0
 PreviousAlienBase: .word 0x080078AA
 LeftAlienKillSwitch: .word 0x08007804
 RightAlienKillSwitch: .word 0x08007970   /* takes into account the last alien */
 MoveLeftorRight: .word 0x0 /*1 makes it move right, 0 makes it move left*/
 ShootBool: .word 0x0
 ScoreBool: .word 0x0
 BulletAdress: .word 0x0
 BulletTimer: .word 10000
 GameOver: .word 0
 Start: .word 0
 InitCheck: .word 0

 .section .exceptions, "ax"
 .align 2
/******************************************EXCEPTION HANDLER*******************************************************/
handler:	
  	# PROLOGUE
  	subi  sp, sp, 16	# we will be saving 3 registers on the stack
  	stwio r2, 0(sp)           	# save r2
  	stwio r5, 4(sp)           	# save r5
	stwio r3, 8(sp)
	stwio r6, 12(sp)
  	movia r5, JTAG_UART_BASE
  	ldwio r2, JTAG_UART_CSR(r5)   # read the status register
  	andi  r2, r2, 0x100       	# is bit RIP 1?
  	beq   r2, r0, TimerInterupt        	# if not run code to check and handle what the interrupt is (not shown – depends on the device)
RIP:
  	ldwio r5, JTAG_UART_RR(r5)	# read RR in r5	# this clears the IRQ1 request
  	andi  r5, r5, 0xff        	# a character was received, copy the lower 8 bits to r9
  	movi r2, 0x61
  	beq r5,  r2,  left	
	movi r2, 0x64
	beq r5, r2, right
	movi r2, 0x20
	beq r5, r2, spacebar
	movi r2, 0x73
	beq r5, r2, PressS
  	br epilogue
  	
TimerInterupt:
#Initialize Timer
	movia r3, MoveAliens
	ldw r2, 0(r3)
	addi r2, r0, 0x1
	stw r2, 0(r3)
	movia r2, TIMER0_BASE
    movia r6, VariableTimerPeriod
	ldw r3, 0(r6)
	srli r3, r3, 16
	stwio r3,  TIMER0_PERIODH(r2)
	ldw r3, 0(r6)
	andi r3, r3, 0xFF
	stwio r3, TIMER0_PERIODL(r2) 	
#Write 0 to address to clear the timeout
	stwio r0, 0(r2)
	
#Tell the Aliens to move  use r6 and r3
	movia r6, MoveLeftorRight
	ldw r3, 0(r6)
	beq r3, r0, GoRight
	
	/**********************Going Left*******************/
	GoLeft:
	movia  r3, PreviousAlienBase
	movia r5, VariableAlienBase
	ldw r6, 0(r5)
	stw r6, 0(r3)
	movia  r3, LeftAlienKillSwitch
	ldw r5, 0(r3)
    movia r2, VariableAlienBase
    ldw r6, 0(r2)
    bge r5, r6, IncrementAlienBase
	subi r6, r6, 8
	stw r5, 0(r3)
    stw r6, 0(r2)
	br TimerSet
	
	IncrementAlienBase: /*incrementing the alien base to next line*/
	addi r6, r6, 2048
	stw r6, 0(r2)
	movia r2, LeftAlienKillSwitch
	ldw r6, 0(r2)
	addi r6, r6, 2048
	stw r6, 0(r2)
	movia r2, RightAlienKillSwitch
	ldw r6, 0(r2)
	addi r6, r6, 2048
	stw r6, 0(r2)
	movia r6, MoveLeftorRight
	ldw r3, 0(r6)
	addi r3, r0, 0x0
	stw r3, 0(r6)

	br TimerSet
	
	
	
		
		
	
	/************************Going Right******************************/
	GoRight:
	movia  r3, PreviousAlienBase
	movia r5, VariableAlienBase
	ldw r6, 0(r5)
	stw r6, 0(r3)
	movia  r3, RightAlienKillSwitch
	ldw r5, 0(r3)
    movia r2, VariableAlienBase
    ldw r6, 0(r2)
    ble r5, r6, IncrementAlienBase2
	addi r6, r6, 8
	stw r5, 0(r3)
	stw r6, 0(r2)
	br TimerSet
	
	IncrementAlienBase2: /*incrementing the alien base to next line*/
	addi r6, r6, 2048
	stw r6, 0(r2)
	movia r2, RightAlienKillSwitch
	ldw r6, 0(r2)
	addi r6, r6, 2048
	stw r6, 0(r2)
	movia r2, LeftAlienKillSwitch
	ldw r6, 0(r2)
	addi r6, r6, 2048
	stw r6, 0(r2)
	movia r6, MoveLeftorRight
	ldw r3, 0(r6)
	addi r3, r0, 0x1
	stw r3, 0(r6)
	br TimerSet
	
	TimerSet:
#Tell timer to accept interrupts and to start ther timer
    movia r2, TIMER0_BASE 
	addi r5, r0, 0b00000101
	stwio r5, TIMER0_CONTROL(r2)
 	br epilogue
	
left:
 movia r3, MoveTank
 ldw r2, 0(r3)
 addi r2, r0, 0x1
 stw r2, 0(r3)
 movia  r3, KILLSWITCHLEFT
 movia r2, VariableTankBase
 ldw r6, 0(r2)
 bge r3, r6, epilogue
 subi r6, r6, 4
 stw r6, 0(r2)
 br epilogue

right:
 movia r3, MoveTank
 ldw r2, 0(r3)
 addi r2, r0, 0x1
 stw r2, 0(r3)
 movia  r3, KILLSWITCHRIGHT
 movia r2, VariableTankBase
 ldw r6, 0(r2)
 ble r3, r6, epilogue
 addi r6, r6, 4
 stw r6, 0(r2)
 br epilogue
 
spacebar:
	movia r3, ShootBool
	addi r2, r0, 0x1
	stw r2, 0(r3)
br epilogue
PressS:
    movia r3, Start
	addi r2, r0, 0x1
	stw r2, 0(r3)
 
epilogue:
  	# EPILOGUE
	
	ldwio r6, 12(sp)
	ldwio r3, 8(sp)
  	ldwio r5, 4(sp)           	# restore r5
  	ldwio r2, 0(sp)           	# restore r2
  	addi  sp, sp, 16           	# we will be saving two registers on the stack
 
  	subi  ea, ea, 4           	# make sure we execute the instruction that was interrupted. Ea/r29 points to the instruction after it
  	eret  
 
 
 
 
 
 .section .text
 

/*When one of the guys dies, we increment there colour value and if that is the colour value then we will not draw it on the next refresh.*/
/*write a function for each draw and redraw every time the timer is up*/
_start:

/*************************HANDLER INITIALIZATION*****************/
movia r8, JTAG_UART_BASE
 
  	# Tell the UART to request interrupts when characters are received
  	# set bit 0 (REI) of the CSR register to 1
  	addi  r9, r0, 0x1
  	stwio r9, JTAG_UART_CSR(r8)
 
  	# Tell the CPU to accept interrupt requests from IRQ8 and IRQ0 when interrupts are enabled
  	# set bit 8 of ctl3 to 1
  	addi  r9, r0, 0x101
  	wrctl ctl3, r9
    
  	# Tell the CPU to accept interrupts
  	# set bit 0 of ctl0 to 1
  	addi r9, r0, 0x1
  	wrctl ctl0, r9
     
	#Initialize Timer
	movia r8, TIMER0_BASE
    movia r9, VariableTimerPeriod
	ldw r9, 0(r8)
	srli r9, r9, 16
	stwio r9,  TIMER0_PERIODH(r8)
	ldw r9, 0(r8)
	andi r9, r9, 0xFF
	stwio r9, TIMER0_PERIODL(r8) 		
	 
	 #Tell timer to accept interrupts and to start ther timer
	addi r9, r0, 0b00000101
	stwio r9, TIMER0_CONTROL(r8)
	

movia r2,ADDR_VGA
movia r3,ADDR_CHAR
movia r7,maxPixel
movia r4,black  /* black pixel */
movia r8,MoveTank
movia r22,MoveAliens
 
/***************INITIALIZE BLACK***********/
Initblack:
  sthio r4, 0(r2)
  addi r2, r2, 1
  bne  r2, r7, Initblack
 
  
/******************PRESS S TO CONTINUE**********************/

Press: 
movia r2,ADDR_CHAR
addi r2, r2, 3734
movi  r5, 0x50   /* ASCII for 'P' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x52   /* ASCII for 'R' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x45   /* ASCII for 'E' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x53   /* ASCII for 'S' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x53   /* ASCII for 'S' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x53   /* ASCII for 'S' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x54   /* ASCII for 'T' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x4F   /* ASCII for 'O' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for '' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x53   /* ASCII for 'S' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x54   /* ASCII for 'T' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x41   /* ASCII for 'A' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x52   /* ASCII for 'R' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x54  /* ASCII for 'T' */
sthio r5,0(r2) 
addi r6, r0, 1
movia r2, Start
ldw r3, 0(r2)
bne r3, r6, Press

movia r2,ADDR_CHAR
addi r2, r2, 3734
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for ' ' */
sthio r5,0(r2) 
addi r2, r2, 2
br Init
GameOVER:
movia r4,black
movia r2,ADDR_VGA
movia r7,maxPixel
Initblack3:
  sthio r4, 0(r2)
  addi r2, r2, 1
  bne  r2, r7, Initblack3

movia r3, ADDR_CHAR
movi r5, 0x47 /* ASCII for 'G' */
stbio r5, 3744(r3) /* character (4,1) is x + y*128 so (4 + 128 = 132) */
movi r5, 0x41 /* ASCII for 'A' */
stbio r5, 3746(r3) /* character (4,1) is x + y*128 so (4 + 128 = 132) */
movi r5, 0x4D /* ASCII for 'M' */
stbio r5, 3748(r3) /* character (4,1) is x + y*128 so (4 + 128 = 132) */
movi r5, 0x45 /* ASCII for 'E' */
stbio r5, 3750(r3) /* character (4,1) is x + y*128 so (4 + 128 = 132) */
movi r5, 0x20 /* ASCII for ' ' */
stbio r5, 3752(r3) /* character (4,1) is x + y*128 so (4 + 128 = 132) */
movi r5, 0x4F /* ASCII for 'O */
stbio r5, 3754(r3) /* character (4,1) is x + y*128 so (4 + 128 = 132) */
movi r5, 0x56 /* ASCII for 'V */
stbio r5, 3756(r3) /* character (4,1) is x + y*128 so (4 + 128 = 132) */
movi r5, 0x45 /* ASCII for 'E' */
stbio r5, 3758(r3) /* character (4,1) is x + y*128 so (4 + 128 = 132) */
movi r5, 0x52 /* ASCII for 'R' */
stbio r5, 3760(r3) /* character (4,1) is x + y*128 so (4 + 128 = 132) */

br GameOVER  
br Init

Reinit:
movia r5, array
addi r6, r5, 120
ReinitArray:
addi r7, r0, 1
stw r7, 0(r5)
addi r5, r5, 4
ble r5,r6, ReinitArray
movia r5, 0x080078AA
movia r6, VariableAlienBase
stw r5, 0(r6)
movia r5, 0x0
movia r6, InitCheck
stw r5, 0(r6)
movia r6, VariableTimerPeriod
ldw r5, 0(r6)
movi r7, 2
div r5, r5, r7
stw r5, 0(r6)
movia r5, 0x080078AA
movia r6, PreviousAlienBase
stw r5, 0(r6)
movia r5, 0x08007804
movia r6, LeftAlienKillSwitch
stw r5, 0(r6)
movia r5, 0x08007970
movia r6, RightAlienKillSwitch
stw r5, 0(r6)
movia r5, Level
ldw r6, 0(r5)
addi r6, r6, 1
stw r6, 0(r5)


 
/***************INITIALIZE BLACK and LEVEL***********/
Init:
movia r2,ADDR_VGA
movia r7,maxPixel
Initblack2:
  sthio r4, 0(r2)
  addi r2, r2, 1
  bne  r2, r7, Initblack2



movia r2,ADDR_CHAR
movia r7, Level
ldw r6, 0(r7)
addi r2, r2, 316
movi  r5, 0x4C   /* ASCII for 'L' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x45   /* ASCII for 'E' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x56  /* ASCII for 'V' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x45   /* ASCII for 'E' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x4C   /* ASCII for 'L' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x3A   /* ASCII for ':' */
sthio r5,0(r2) 
addi r2, r2, 2
movi  r5, 0x20   /* ASCII for '' */
sthio r5,0(r2) 
addi r2, r2, 2
movi r9, 1
beq r6, r9, one
movi r9, 2
beq r6, r9, two
movi r9, 3
beq r6, r9, three
movi r9, 4
beq r6, r9, four
movi r9, 5
beq r6, r9, five
movi r9, 6
beq r6, r9, six
movi r9, 7
beq r6, r9, seven
movi r9, 8
beq r6, r9, eight
movi r9, 9
beq r6, r9, nine
br gameLOOP

one:
movi  r5, 0x31  /* ASCII for '1' */
sthio r5, 0(r2)
br gameLOOP
two:
movi  r5, 0x32   /* ASCII for '2' */
sthio r5, 0(r2)
br gameLOOP
three:
movi  r5, 0x33   /* ASCII for '3' */
sthio r5, 0(r2)
br gameLOOP
four:
movi  r5, 0x34   /* ASCII for '4' */
sthio r5, 0(r2)
br gameLOOP
five:
movi  r5, 0x35  /* ASCII for '5' */
sthio r5, 0(r2)
br gameLOOP
six:
movi  r5, 0x36  /* ASCII for '6' */
sthio r5, 0(r2)
br gameLOOP
seven:
movi  r5, 0x37  /* ASCII for '7' */
sthio r5, 0(r2)
br gameLOOP
eight:
movi  r5, 0x38  /* ASCII for '8' */
sthio r5, 0(r2)
br gameLOOP
nine:
movi  r5, 0x39  /* ASCII for '9' */
sthio r5, 0(r2)
br gameLOOP

  
  

/******************GAME LOOP*************/

gameLOOP:
  subi sp, sp, 16
  stw r4, 0(sp)
  stw r7, 4(sp)
  stw r2, 8(sp)
  stw r8, 12(sp)
  #movia r7, ScoreBool
  #beq r7, r0, updateScore
  movia r7, InitCheck
  ldw r2, 0(r7)
  bne r2, r0, Reinit
  movia r7, GameOver
  ldw r2, 0(r7)
  bne r2,r0, GameOVER
  call checkAliens
  movia r8, CollisionVariable
  ldw r7, 0(r8)
  movi r4, 1
  beq r7, r4, drawtheAliens
  br SkiptheAliens
  drawtheAliens:
  #call  drawScore
  call drawAliens
  movia r8, CollisionVariable
  stw r0, 0(r8)
  SkiptheAliens:
  movia r8, ShootBool
  ldw r7, 0(r8)
  addi r8, r0, 1
  bne r7, r0, drawBulletCall
  br bulletcontinue
  
updateScore:
  
drawBulletCall:
  movia r2, 100000
  addi r8, r8, 1
  beq r8, r2, drawbulllet
  br drawBulletCall
  drawbulllet:
  call drawBullet
  
  br bulletcontinue
bulletcontinue:
  ldw r4, 0(sp)
  ldw r7, 4(sp)
  ldw r2, 8(sp)
  ldw r8, 12(sp)
  addi sp, sp, 16
  ldw r9, 0(r22)   
  bne r9, r0, AlienMovement
  ldw r9, 0(r8)     /*checks if MoveTank is 1*/
  bne r9, r0, TankMovement
  br gameLOOP
AlienMovement:
  stw r0, 0(r22) /*sets MoveAliens to 0*/
  subi sp, sp, 16
  stw r4, 0(sp)
  stw r7, 4(sp)
  stw r2, 8(sp)
  stw r8, 12(sp)
  call drawAliens
  ldw r4, 0(sp)
  ldw r7, 4(sp)
  ldw r2, 8(sp)
  ldw r8, 12(sp)
  addi sp, sp, 16
  ldw r9, 0(r8)     /*checks if MoveTank is 1*/
  bne r9, r0, TankMovement  
  br gameLOOP  
TankMovement:
  stw r0, 0(r8) /*sets MoveTank to 0*/
  subi sp, sp, 20
  stw r4, 0(sp)
  stw r7, 4(sp)
  stw r2, 8(sp)
  stw r8, 12(sp)
  stw r23, 16(sp)
  call drawTank
  ldw r4, 0(sp)
  ldw r7, 4(sp)
  ldw r2, 8(sp)
  ldw r8, 12(sp)
  ldw r23, 16(sp)
  addi sp, sp, 20
  movia r2,ADDR_VGA
  br gameLOOP 
  
/******************DRAW OUT THE TANK******************8*/
 drawTank:
 movia r4, black
 movia r2, TankBorder 
 movia r7, maxPixel
TankBlack:
 sthio r4, 0(r2)
 addi r2, r2, 1
 bne  r2, r7 , TankBlack /*branches once the screen is black*/
 movia r2, VariableTankBase /*move to tankbase*/
 movia r23, TipVariable
 ldw r7, 0(r2)
 subi r4, r7, 8170
 stw r4, 0(r23)
 movia r4, green
 drawtank1:
 addi r3, r7, 40
 drawtank2: /*draw the tank */
 /*draw the main base*/
 addi r7, r7, 2
 sthio r4, 0(r7)
 bne r7, r3, drawtank2 /*draws the first lines of tank*/
 
 subi r7, r7, 1064 /*returns to the line of pixels above*/
 movia r6, 0x08036000
 ble r7, r6, drawtank3 /*after two lines are done it contiunes*/
 br drawtank1
 
 drawtank3: /* draw skinnier lines */
 addi r7, r7, 2
 drawtank4:
 addi r3, r7, 36
 drawtank5:
 addi r7, r7, 2
 sthio r4, 0(r7)
 bne r7,r3, drawtank5
 subi r7, r7, 1060
 movia r6, 0x08035C00
 ble r7, r6, drawtankgun /*go to tank gun drawing*/
 br drawtank4
 
 
drawtankgun: /* draw tanks gun */
 addi r7, r7, 16
 drawtankgun2:
 addi r3, r7, 4
 drawtankgun3:
 addi r7, r7, 2
 sthio r4, 0(r7)
 bne r7,r3, drawtankgun3
 subi r7, r7, 1028
 movia r6, 0x08035000
 ble r7, r6, finish
 br drawtankgun2
 
 finish:
 ret

 
/************DISPLAY SCORE*********************/
DisplayScore:

/**********************CHECK ALIENS*******************/
/**************Checks if all aliens are dead, and keeps score********************/
checkAliens:
movia r4, array
addi r13, r4, 120
ReinitCheck:
movi r15, 1
ldw r14, 0(r4)
addi r4, r4, 4
beq r15, r14, cont
ble r4, r13,ReinitCheck

movia r4, InitCheck
stw r15, 0(r4)
ret


cont:

movia r4, white
movia r13, TankBorder
subi r13, r13, 12480
movia r14, TankBorderMax
subi r14, r14, 12480
checkBorder:

addi r13, r13, 2
ldw r15, 0(r13)
andi r15, r15, 0x0000ffff
beq r15, r4, gotogameover
beq r13, r14, keepchecking
br checkBorder

keepchecking:
movia r7, PreviousAlienBase /*move to previous alien base*/
  ldw r2, 0(r7)
  addi r3, r2, 10240
  movi r5, 0
  movi r6, 30
  movi r10, 6
  movia r12, 20480
  movia r17, CollisionVariable
checkAliens2:
	movi r8, 0
	addi r8, r2, 20 
checkwhite:
	ldw r4, 0(r17)     /*checks one row of alien*/
	addi r2, r2, 2
	beq r2, r4, Found
	beq r2, r8, alienrowcheck
	br checkwhite
alienrowcheck: /* moves to next row*/
	addi r2, r2, 1004 /*back 10 pixels and down 1 row of pixels*/
	bge r2, r3, checksingle
	br checkAliens2
checksingle: /* sets up new alien*/
	subi r2, r2, 10240
	addi r2, r2, 50
	addi r3, r2, 10240 
	addi r5, r5, 1
	beq r5, r6, enddrawaliens2
	beq r5, r10, nextrowofaliens2
	br checkAliens2

nextrowofaliens2:
	addi r10, r10, 6
	subi r2, r2, 300
	add r2, r2, r12
	addi r3, r2, 10240
	br checkAliens2
	enddrawaliens2:
	ret
Found:
	muli r4, r5, 4
	movia r17, array
    add r17, r17, r4
	stw r0, 0(r17)
	movia r17, CollisionVariable
	movi r4, 1
	stw r4, 0(r17)
    ret
gotogameover:
    movia r4, GameOver
	addi r17, r0, 1
	stw r17, 0(r4)
    ret

 /******************DRAW OUT THE ALIENS******************8*/ 
drawAliens:
 movia r5, black
 movia r2, ADDR_VGA
 movia r7, TankBorder
AlienBlack:
 sthio r5, 0(r2)
 addi r2, r2, 2
 bne  r2, r7 , AlienBlack /*branches once the screen is black*/
  movia r7, VariableAlienBase /*move to alien base*/
  ldw r2, 0(r7)
  movia r4, white
  addi r3, r2, 10240
  movi r5, 0
  movi r6, 30
  movi r10, 6
  movia r12, 20480
drawAliens2:
	movi r8, 0
	addi r8, r2, 20 
drawwhite:
	muli r19, r5, 4
	movia r17, array
	add r17, r17, r19
    ldw r20, 0(r17)
	beq r20, r0, drawblack
	br drawwhite2
	drawblack:
	movia r4, black
	sthio r4, 0(r2)     /*draws one row of alien*/
	addi r2, r2, 2
	beq r2, r8, alienrow
	br Finito
	drawwhite2:
	movia r4, white
	sthio r4, 0(r2)     /*draws one row of alien*/
	addi r2, r2, 2
	beq r2, r8, alienrow
	Finito:
	br drawwhite
alienrow: /* moves to next row*/
	addi r2, r2, 1004 /*back 10 pixels and down 1 row of pixels*/
	bge r2, r3, drawsingle
	br drawAliens2
drawsingle: /* sets up new alien*/
	subi r2, r2, 10240
	addi r2, r2, 50
	addi r3, r2, 10240 
	addi r5, r5, 1
	beq r5, r6, enddrawaliens
	beq r5, r10, nextrowofaliens
	br drawAliens2

nextrowofaliens:
	addi r10, r10, 6
	subi r2, r2, 300
	add r2, r2, r12
	subi r13, r2, 170
	addi r3, r2, 10240
	movia r7, TankBorder
	subi r7, r7, 10240
	bge r2, r7, enddrawaliens
	br drawAliens2
enddrawaliens:
	ret
	

drawBullet:
	movia r2, BulletAdress
	ldw r3, 0(r2)
	beq r3, r0, drawBullet2
	br continueBullet
drawBullet2:
	movia r7, red
	movia r5, TipVariable
	ldw r3, 0(r5)
	subi r3, r3, 1024
	sthio r7, 0(r3)
	subi r3, r3, 1024
	sthio r7, 0(r3)
	subi r3, r3, 1024
	sthio r7, 0(r3)    
	stw r3, 0(r2)
	br finish1
	




continueBullet:
	ldhio r7, -2048(r3)
	movia r18, white
	mov r19, r3
	subi r19, r19, 2048
	andi r7, r7, 0x0000FFFF
	beq r7, r18, Collision
	ldhio r7, -2046(r3)
	mov r19, r3
	subi r19, r19, 2046
	andi r7, r7, 0x0000FFFF
	beq r7, r18, Collision
	ldhio r7, -2050(r3)
	mov r19, r3
	subi r19, r19,  2050
	andi r7, r7, 0x0000FFFF
	beq r7, r18, Collision
	ldhio r7, -1022(r3)
	mov r19, r3
	subi r19, r19, 1022
	andi r7, r7, 0x0000FFFF
	beq r7, r18, Collision
	ldhio r7, -1026(r3)
	mov r19, r3
	subi r19, r19, 1026
	andi r7, r7, 0x0000FFFF
	beq r7, r18, Collision
	
    movia r7, black
	ldw r3, 0(r2)
	addi r3, r3, 1024
	sthio r7, 0(r3)
	addi r3, r3, 1024
	sthio r7, 0(r3)
	subi r3, r3, 2048
	movia r7, red
	subi r3, r3, 1024
	sthio r7, 0(r3)
	subi r3, r3, 1024
	sthio r7, 0(r3)
    stw r3, 0(r2)
	movia r5, ADDR_VGA
	ble r3, r5, TurnoffBOOL
	br finish1
Collision: 
	movia r18, CollisionVariable
	stw r19, 0(r18)
	#mov r7, scoreBool
    stw r0, 0(r7)
	br TurnoffBOOL


TurnoffBOOL:
	movia r2, ShootBool
	ldw r3, 0(r2)
    mov r3, r0
	stw r3, 0(r2)
	movia r2, BulletAdress
	ldw r3, 0(r2)
    mov r3, r0
	stw r3, 0(r2)
	br finish1

	
	finish1:
	ret
	
	