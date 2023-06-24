#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Dylan Hollohan, *******439
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5 
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. [Easy] Display the number of lives remaining
# 2. [Easy] Dynamic increase in difficulty (speed changes by using 'e' key)
# 3. [Easy] Have objects in different rows move at different speeds
# 4. [Easy] Make the frog point in the direction that it's travelling
# 5. [Easy] Sound effects on victory, movement or collision
# 6. [Easy] Death animation
# 7. [Easy] Pause screen appears when 'p' is pressed, and game returns when 'p' is pressed again.
#
# Any additional information that the TA needs to know:
# - P is for 'Pause' and 'unpause'
# - Q is for 'Quit', it just exits the event loop
# - E is used to increase the difficulty of the game, but it also wraps back around ie: Easy -> Medium -> Hard -> Easy ... 
#
# COLORS: 
# Hot pink:          ff33cc
# Green (grass):     33cc33
# Green (frog):      008000
# Blue:              3366cc
# Grey (road):       666666
# Brown (log):       86592d
# Biege (center safe): ffd480
# Yellow (frog's feet): ffff66
#
#####################################################################


.data
displayAddress: .word 0x10008000
frogX:  .word 12         
frogY:  .word 7
height:	.word 512
topGrass: .space 1024
logRow2: .space 512
logRow1: .space 512
safeSpace: .space 512
carRow2: .space 512
carRow1: .space 512
bottomGrass: .space 512 
car1: .word 4
car2: .word 20
car3: .word 8
car4: .word 24
log1: .word 12
log2: .word 28
log3: .word 0
log4: .word 16
isPaused: .byte 0
succeeded: .byte 0
difficulty: .word 0		# values 0, 1, 2
carR1Req: .word 4
carR1Ticks: .word 0
carR2Req: .word 5
carR2Ticks: .word 0
logR1Req: .word 6
logR1Ticks: .word 0
logR2Req: .word 4
logR2Ticks: .word 0
frogDirection: .word 0 		# 0 means forward, 1 means facing left, 2 means facing down, 3 means facing right, 4 animation1 , 5 animation2
successSpots: .space 32
hackStack: .space 32
lives: .word 3
collision: .byte 0

.text
main: 

# set up successSpots
add $t0, $zero, $zero			# store default of successSpots as 0,  ie: "not-filled"
la $t1, successSpots			# $t1 gets the address of the state of the success spots


# for 8 spots, stored at each 4 memory addresses, store 0 
addi $t2, $t1, 32			# the first out-of-bounds memory address for this array

setupSuccessSpotsLoop: 
beq $t2, $t1, endCopySpotsLoop		
sw $t0, 0($t1)				# store the pixel from the buffer into the display
addi $t1, $t1, 4			# increment the address of display map by 4
j setupSuccessSpotsLoop
endCopySpotsLoop:

j processLoop


#### resetFrog  #####
#	
#	reset the frog's position to starting position after success/fail collision
#
#####
resetFrog: 
addi $t0, $zero, 12			# store 12 (x-start) in $t0
sw $t0, frogX
addi $t0, $zero, 7
sw $t0, frogY

jr $ra
########################################### end resetFrog

#### drawRemLives  #####
#	
#	draw a cross symbol for each remaining life in the top 3, beginning at 3 
#
#####
drawRemLives: 
add $t0, $zero, $zero 			# the incrementer for the loop which will count from 0 -> 3 
lw $t1, lives				# stores the number of lives remaining, which will be the upper bound on the loop
la $t2, topGrass
addi $t2, $t2, 244			# move the pointer to the top of the right-most cross to draw
li $t3, 0xffffff			# load white in as color of the crosses
	
drawLivesLoop:
beq $t0, $t1, belowLives
sw $t3, 0($t2)
addi $t2, $t2, 124
sw $t3, 0($t2)
addi $t2, $t2, 4
sw $t3, 0($t2)
addi $t2, $t2, 4
sw $t3, 0($t2)
addi $t2, $t2, 124
sw $t3, 0($t2)  
addi $t2, $t2, -272			# increment to the starting position of next cross, which may or may not be drawn.
addi $t0, $t0, 1			# increment the loop 

j drawLivesLoop

belowLives:

jr $ra

####################################### end drawRemLives


#### drawDifficulty  #####
#	
#	draw bars according to difficulty
#
#####
drawDifficulty: 
add $t0, $zero, $zero 			# the incrementer for the loop which will count from 0 -> 3 
lw $t1, difficulty				# stores the number of lives remaining, which will be the upper bound on the loop
la $t2, topGrass
addi $t2, $t2, 4			# move the pointer to the top of the right-most cross to draw
li $t3, 0xffffff			# load white in as color of the crosses
	
sw $t3, 0($t2)
addi $t2, $t2, 4
sw $t3, 0($t2)
addi $t2, $t2, 12
sw $t3, 0($t2)
addi $t2, $t2, 4
sw $t3, 0($t2)
addi $t2, $t2, 4
sw $t3, 0($t2)
addi $t2, $t2, 8
sw $t3, 0($t2)
addi $t2, $t2, 4
sw $t3, 0($t2)
addi $t2, $t2, 4
sw $t3, 0($t2)
addi $t2, $t2, 8
sw $t3, 0($t2)
addi $t2, $t2, 80
sw $t3, 0($t2)
addi $t2, $t2, 8
sw $t3, 0($t2)
addi $t2, $t2, 12
sw $t3, 0($t2)
addi $t2, $t2, 12
sw $t3, 0($t2)
addi $t2, $t2, 96
sw $t3, 0($t2)
addi $t2, $t2, 8
sw $t3, 0($t2)
addi $t2, $t2, 12
sw $t3, 0($t2)
addi $t2, $t2, 12
sw $t3, 0($t2)
addi $t2, $t2, 4
sw $t3, 0($t2)
addi $t2, $t2, 92
sw $t3, 0($t2)
addi $t2, $t2, 4
sw $t3, 0($t2)
addi $t2, $t2, 12
sw $t3, 0($t2)
addi $t2, $t2, 4
sw $t3, 0($t2)
addi $t2, $t2, 4
sw $t3, 0($t2)
addi $t2, $t2, 8
sw $t3, 0($t2)
addi $t2, $t2, 16
sw $t3, 0($t2)
# now add the bars
addi $t2, $t2, 12
sw $t3, 0($t2)
add $t4, $zero, $zero
slt $t5, $t4, $t1
# if difficulty > 0, we need at least the next set of bars, otherwise skip to end
beq $t5, 0, setDifficulty
addi $t2, $t2, 4
sw $t3, 0($t2)
addi $t2, $t2, -128
sw $t3, 0($t2)
# check if we need the third bar:
addi $t4, $zero, 1
slt $t5, $t4, $t1
beq $t5, 0, setDifficulty
addi $t2, $t2, -252
sw $t3, 0($t2)
addi $t2, $t2, 128
sw $t3, 0($t2)
addi $t2, $t2, 128
sw $t3, 0($t2)
addi $t2, $t2, 128
sw $t3, 0($t2)

setDifficulty:

jr $ra

####################################### end drawRemLives


#### decrementLives  #####
#	
#   decrease number of lives by 1
#	
#
#####

decrementLives: 
lw $t0, lives
addi $t0, $t0, -1
sw $t0, lives

jr $ra

####################################### end drawRemLives


#############  drawPauseScreen   #########
#
#	008000    dark green:  frog body and border
#	ffff66    yellow:  frog legs and pause word
# 	3366cc    blue: the 'fill' 
#
##########################################
drawPauseScreen:

##  store my current $ra value in the stack, so we can call other function before eventually doing 'jr $ra'
la $t3, hackStack
sw $ra, 0($t3)			# store the current value of ra into hackStack,  
la $t1, topGrass
addi $t1, $t1, 788		# keep this as nearest pointer to pause screen's top left
add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
li $t4 0x008000			# dark green as screen border
li $a0, 18
li $a1, 23
jal drawRectangle

# draw blue inner fill
add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 132		# move down one and right one from border
li $t4 0x3366cc			# blue as the fill
li $a0, 16
li $a1, 21
jal drawRectangle

li $t4 0xffff66			# set color for PAUSED letters
# draw P letter
add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 264		# move down one and right one from border
li $a0, 5
li $a1, 1
jal drawRectangle

add $t0, $zero, $t1
addi $t0, $t0, 268
sw $t4, 0($t0)
addi $t0, $t0, 256
sw $t4, 0($t0)

add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 272		# move down one and right one from border
li $a0, 3
li $a1, 1
jal drawRectangle

# draw A letter
add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 280		# move down one and right one from border
li $a0, 5
li $a1, 1
jal drawRectangle

add $t0, $zero, $t1
addi $t0, $t0, 284
sw $t4, 0($t0)
addi $t0, $t0, 256
sw $t4, 0($t0)

add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 288		# move down one and right one from border
li $a0, 5
li $a1, 1
jal drawRectangle

# draw U letter
add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 296		# move down one and right one from border
li $a0, 5
li $a1, 1
jal drawRectangle

add $t0, $zero, $t1
addi $t0, $t0, 812
sw $t4, 0($t0)

add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 304		# move down one and right one from border
li $a0, 5
li $a1, 1
jal drawRectangle

# draw S letter
add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 312		# move down one and right one from border
sw $t4, 0($t0)
addi $t0, $t0 4
sw $t4, 0($t0)
addi $t0, $t0 4
sw $t4, 0($t0)
addi $t0, $t0 120
sw $t4, 0($t0)
addi $t0, $t0 128
sw $t4, 0($t0)
addi $t0, $t0 4
sw $t4, 0($t0)
addi $t0, $t0 4
sw $t4, 0($t0)
addi $t0, $t0 128
sw $t4, 0($t0)
addi $t0, $t0 128
sw $t4, 0($t0)
addi $t0, $t0 -4
sw $t4, 0($t0)
addi $t0, $t0 -4
sw $t4, 0($t0)

#draw E letter
add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 328		# move down one and right one from border
li $a0, 5
li $a1, 1
jal drawRectangle

add $t0, $zero, $t1
addi $t0, $t0, 332
sw $t4, 0($t0)
addi $t0, $t0 4
sw $t4, 0($t0)

addi $t0, $t0 252
sw $t4, 0($t0)
addi $t0, $t0 256
sw $t4, 0($t0)
addi $t0, $t0 4
sw $t4, 0($t0)



# draw top left foot
add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 1052		# move down one and right one from border
li $t4 0xffff66			# yellow as frog's foot
li $a0, 4
li $a1, 2
jal drawRectangle
# draw top right foot
add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 1076		# move down one and right one from border
li $t4 0xffff66			# yellow as frog's foot
li $a0, 4
li $a1, 2
jal drawRectangle
# draw frog body
add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 1316		# move down one and right one from border
li $t4 0x008000			# dark green as screen border
li $a0, 6
li $a1, 4
jal drawRectangle
# draw bottom left foot
add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 1820		# move down one and right one from border
li $t4 0xffff66			# yellow as frog's foot
li $a0, 2
li $a1, 2
jal drawRectangle
# draw bottom right foot
add $t0, $zero, $t1		# clone value of $t1 into $t0 so $t0 can change 
addi $t0, $t0, 1844		# move down one and right one from border
li $t4 0xffff66			# yellow as frog's foot
li $a0, 2
li $a1, 2
jal drawRectangle

la $t3, hackStack
lw $ra, 0($t3)			# set the value of $ra back to it's original caller from main

jr $ra



########### end drawPauseScreen function #########

#### checkCollision  #####
#	
#	check whether the frog collided with the object
#	$t0: stores 0 if it's a car and 1 if it's a log
#	$t1: stores the Y row of the row in which the object is located
#       $t2: stores the 0-31 X-position of the object in question
#
#####

checkCollision: 
# no collisions are valid if the frog is in the middle of an animation, ie: frogDirection = 4 or 5

lw $t7, frogDirection
beq, $t7, 4, inDeathAnimation		# added this to handle animations, maybe,
beq $t7, 5, inDeathAnimation
j belowInDeathAnimation			# proceed to check for collisions

inDeathAnimation: 			# update collision value to 0 and then resolveCollision function
add $t1, $zero, $zero
sw $t1, collision
j resolveCollision

belowInDeathAnimation:
lw $t3, frogY				# get the Y-position of the frogs 
bne $t3, $t1, resolveCollision		# confirm that the frog is in the correct row for collision

lw $t3, frogX				# frog's X position will remain as $t1
beq $t0, 1, checkOnLog
# if we reach here, the frog is in a car lane				# now frog's top-left corner is 0, 4, 8, ... , 28
addi $t5, $t3, -8			# find the pointer to position 8 spots to the left of frog's position, we need object position to be to the right of that
slt $t6, $t5, $t2
# if $t6 = 1 then it's possible there was a collision.  Otherwise, no collision could have happened. 
beq $t6, 0, resolveCollision
# now we need to check that the object isn't too far to the right for a collision:
addi $t5, $t3, 4			# find the pointer to position 4 spots to the right of frog's position, we need object position to be to the left of that
slt $t6, $t2, $t5
# if $t6 = 1, then there was a collision
bne $t6, 1, resolveCollision
# if we reach here, there was a collision
addi $t9, $zero, 1			# prepare to set value of 'collision' variable to true 
sb $t9, collision			# store 1 in collision var

j belowCheckOnLog


checkOnLog:
# the frog must 'collide' with the log or else we should say it fell in the water.  We'll set variable "collision" to 1, which assumes the frog fell in
# but if the frog collides with a log, then we'll flip 'collision' back to 0, meaning the frog is safe.  
addi $9, $zero, 1
sb $t9, collision			# store a 1 in collision var, which we'll 'undo' if the frog lands on a log.  				# now frog's top-left corner is 0, 4, 8, ... , 28
addi $t5, $t3, -8			# find the pointer to position 8 spots to the left of frog's position, we need object position to be to the right of that
slt $t6, $t5, $t2
# if $t6 = 1 then it's possible there was a collision with a log.  Otherwise, no collision could have happened. 
beq $t6, 0, resolveCollision
# now we need to check that the object isn't too far to the right for a collision:
addi $t5, $t3, 4			# find the pointer to position 4 spots to the right of frog's position, we need object position to be to the left of that
slt $t6, $t2, $t5
# if $t6 = 1, then there was a collision
bne $t6, 1, resolveCollision
# if we reach here, there was a collision with a log, so we should set collision back to 0, meaning the frog landed safely ontop
add $t9, $zero, $zero			# prepare to set value of 'collision' variable to true 
sb $t9, collision			# store 1 in collision var

belowCheckOnLog:

resolveCollision:

jr $ra

####################################### end drawRemLives



####

#### checkSucceed  #####
#	
#	check whether the frog is located in a 'victory' position
#
#####
checkSucceed: 

lw $t0, frogY			# get frog's Y coordinate
bne $t0, 1, noSuccess		# frog was not in second row, so can't be success

lw $t0, frogX 			# get frogX value into $t0

la $t1, successSpots		# get address of successSpots
add $t1, $t1, $t0		# offset that address by the position of the frog
lw $t2, 0($t1)			# get the value stored at that address where 1 means it's filled already and 0 means it's open 
bne $t2, 0, noSuccess		# the spot was full, so we have no success
# if code reaches here, the frog succeeded and we should update the value of this successSpot
addi $t0, $zero, 1		# store 1, the 'filled' value
sw $t0, 0($t1)
addi $t4, $zero, 1
sb $t4, succeeded		# update the succeeded byte to store one, to be checked after return.
# play a sound
li $v0, 33				# put sleep syscall code in $v0
li $a0, 60				# pitch
li $a1, 80				# duration ms
li $a2, 101 				# instrument
li $a3, 80				# volume
syscall
# second sound effect
li $a0, 50				# pitch
li $a1, 70				# duration ms
li $a2, 101				# instrument
li $a3, 80				# volume
syscall
# third sound effect
li $a0, 80				# pitch
li $a1, 130				# duration ms
li $a2, 101				# instrument
li $a3, 80				# volume
syscall

noSuccess:

jr $ra				# if succeeded, after return we need to reset frog's position

## end checkSucceed function	##

#### drawFrog #####
#
#
#
#########

drawFrog:

la $t0, topGrass	 		# set $t0 to store displayAddress as it was originally instantiated
lw $t2, height				# 512 is the height in memory address of the frog
lw $t3, frogX				# a value in 0-28, left to right
##  next we want to calculate the top left of the frog sprite by taking (0,0) and offsetting by the frog's x-y coordinates
# set up for moving the frog over by 3 frog-size units to the right
addi $t4, $zero, 4			# the number of addresses to move to the right for each unit in X coordinate
mult $t4, $t3				# multiply 4 by x coordinate
mflo $t4
add $t0, $t0, $t4			# off-set the frog horizontally 

lw $t3 frogY
mult $t2, $t3				# multiply 512 by the Y-coordinate
mflo $t4				# retrieve multiplication result
add $t0, $t0, $t4			# offset the frog vertically
# check orientation of the frog. 
lw $t5, frogDirection
beq $t5, 1, drawLeftFrog
beq $t5, 2, drawDownFrog
beq $t5, 3, drawRightFrog
beq $t5, 4, drawDeathAni1
beq $t5, 5, drawDeathAni2
# can proceed to draw the frog facing up, $t5 stores 0

li $t1, 0xffff66 			# $t1 stores the dark green frog color
# ffff66, 008000
sw $t1, 0($t0)				# paint the current unit yellow.
addi $t0, $t0, 12  			# increment the address for painting by 12
sw $t1, 0($t0)				# top right pixel of sprite
addi $t0, $t0, 116
sw $t1, 0($t0)				# top right pixel of sprite
li $t1, 0x008000 			# set green as color for frog body
addi $t0, $t0, 4
sw $t1, 0($t0)				# top right pixel of sprite
addi $t0, $t0, 4
sw $t1, 0($t0)				# top right pixel of sprite
li $t1, 0xffff66 			# set yellow as color for feet
addi $t0, $t0, 4
sw $t1, 0($t0)				# top right pixel of sprite
li $t1, 0x008000 			# set green as color for frog body
addi $t0, $t0, 120
sw $t1, 0($t0)				# top right pixel of sprite
addi $t0, $t0, 4
sw $t1, 0($t0)				# top right pixel of sprite
li $t1, 0xffff66 			# set yellow as color for feet
addi $t0, $t0, 120
sw $t1, 0($t0)	
li $t1, 0x008000 			# set green as color for frog body			
addi $t0, $t0, 4
sw $t1, 0($t0)				# top right pixel of sprite
addi $t0, $t0, 4
sw $t1, 0($t0)				# top right pixel of sprite
li $t1, 0xffff66 			# set yellow as color for feet
addi $t0, $t0, 4
sw $t1, 0($t0)				# top right pixel of sprite
j resolveDrawFrog

drawDeathAni1:
li $t1, 0xffff66		# yellow four corners
sw $t1, 0($t0)
addi $t0, $t0, 12
sw $t1, 0($t0)
addi $t0, $t0, 256
sw $t1, 0($t0)
addi $t0, $t0, -12
sw $t1, 0($t0)
j resolveDrawFrog

drawDeathAni2:
li $t1, 0x008000 		# dark green middle 4
addi $t0, $t0, 132
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)
addi $t0, $t0, 128
sw $t1, 0($t0)
addi $t0, $t0, -4
sw $t1, 0($t0)
j resolveDrawFrog

drawLeftFrog:
li $t1, 0xffff66		# yellow
sw $t1, 0($t0) 
addi $t0, $t0, 4
sw $t1, 0($t0)
addi $t0, $t0, 8
sw $t1, 0($t0)
li $t1, 0x008000 		#green
addi $t0, $t0, 120
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)
addi $t0, $t0, 120
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)
li $t1, 0xffff66		# yellow
addi $t0, $t0, 116
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)
addi $t0, $t0, 8
sw $t1, 0($t0)

j resolveDrawFrog
# finish drawLEFTFrog

drawDownFrog: 
li $t1, 0xffff66		# yellow
sw $t1, 0($t0) 
addi $t0, $t0, 4
li $t1, 0x008000		# green
sw $t1, 0($t0) 
addi $t0, $t0, 4				
sw $t1, 0($t0) 
addi $t0, $t0, 4
li $t1, 0xffff66		# yellow
sw $t1, 0($t0) 
# finish row 1 of sprite
addi $t0, $t0, 120			
li $t1, 0x008000		#green
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)	
#finish row 2 of sprite
addi $t0, $t0, 120
li $t1, 0xffff66		#yellow
sw $t1, 0($t0)	
addi $t0, $t0, 4
li $t1 0x008000			#green
sw $t1, 0($t0)
addi $t0, $t0, 4	
sw $t1, 0($t0)
addi $t0, $t0, 4
li $t1, 0xffff66		#yellow
sw $t1, 0($t0)	
#finish row 3 of sprite
addi $t0, $t0, 116
sw $t1, 0($t0)	
addi $t0, $t0, 12
sw $t1, 0($t0)			
# finish full sprite
j resolveDrawFrog


drawRightFrog:

li $t1, 0xffff66		# yellow
sw $t1, 0($t0) 
addi $t0, $t0, 8
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)
li $t1, 0x008000 		#green
addi $t0, $t0, 116
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)
addi $t0, $t0, 120
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)
li $t1, 0xffff66		# yellow
addi $t0, $t0, 120
sw $t1, 0($t0)
addi $t0, $t0, 8
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t1, 0($t0)
# finish drawRIGHTFrog

resolveDrawFrog:


jr $ra

############### end of drawFrog function


##### drawSuccessSprites  #######
#
#	for now, does nothing just return to caller next line
#
######

# loop over the successSpots, if it's a '1' stored there, draw the sprite.
# otherwise, just increment to next of 8 success spots.
drawSuccessSprites:
add $t0, $zero, $zero 			# the 0-7 successSpot position we're checking
addi $t1, $zero, 8			# the upper limit for the loop
la $t2, successSpots			# the thing we'll increment to look at the value in each spot being 0 or 1

drawSpriteLoop: 	
beq $t0, $t1, doneDrawSprites		# t0 has reached 8
la $t4, topGrass			# skip to second row of grass at the top
addi $t4, $t4, 512	
lw $t3, 0($t2)				# $t3 gets the value stored in this success spots
bne $t3, 1, spriteLoopIncrement 	# if it's a 1, we need to draw the sprite.  If it's not, we should just increment 
# draw the sprite now
addi $t5, $zero, 16			# store 4 in $t5 for upcoming mult
multu $t0, $t5				# multiply our spot in the success spots by memory size 4
mflo $t6				# t6 gets value of 4 * success spot 
add $t4, $t4, $t6 			# t4 stores the top left of the square where we'll draw the sprite, after offset by t6

li $t7, 0x000000				# black in t7
sw $t7, 0($t4) 
addi $t4, $t4, 4
li $t7, 0xff0000				# black in t7
sw $t7, 0($t4) 
addi $t4, $t4, 4				# black in t7
sw $t7, 0($t4) 
addi $t4, $t4, 4
li $t7, 0x000000				# black in t7
sw $t7, 0($t4) 
# finish row 1 of sprite
addi $t4, $t4, 120			
li $t7, 0xff0000
sw $t7, 0($t4)
addi $t4, $t4, 4
sw $t7, 0($t4)	
#finish row 2 of sprite
addi $t4, $t4, 120
li $t7, 0x000000	
sw $t7, 0($t4)	
addi $t4, $t4, 4
li $t7 0xff0000
sw $t7, 0($t4)
addi $t4, $t4, 4	
sw $t7, 0($t4)
addi $t4, $t4, 4
li $t7, 0x000000
sw $t7, 0($t4)	
#finish row 3 of sprite
addi $t4, $t4, 116
sw $t7, 0($t4)	
addi $t4, $t4, 12
sw $t7, 0($t4)			
# finish full sprite


spriteLoopIncrement: 
addi $t0, $t0, 1			# increment the loop counter
addi $t2, $t2, 4			# increment the location in memory that stores the filled/not filled info
j drawSpriteLoop

doneDrawSprites:
jr $ra					# return



#### end drawSuccessSprites function #####


######### drawMoving legend ###
#	$t0: the pointer to where the non-wrapped position is
#	$t1: pointer to the start of the line we're drawing in during this inner loop
#	$t3: the updated place where we'll actually draw the pixel, after accounting for wrapping  
#	$t4: stores a hex color to be drawn
#	$t5: the width index for inner loop
#	$t6: the height index for outer loop
#	$t7: the car's offset from top left
#	$t8: the address that is out of bounds for this row, needs to wrap
# 	$a0: desired height
#	$a1: desired width
#	
##################################


drawMoving:				
add $t6, $zero, $zero			# Set index of the outer loop, $t6 to 0
addi $a0, $zero, 4 			# height of the car
addi $a1, $zero, 8			# width of the car
addi $t8, $t1, 128			# take the starting memory address for this region of the map and add 128, < are the allowable locations for this row
sll $t7, $t7, 2				# multiply the offset by 4 as memory
add $t0, $t0, $t7			# offset the starting point by amount equal to the car1 (location) value * 4 


drawObjectsLoop:
beq $t6, $a0, endDrawObjects		# If index has reach the required height of 4, exit loop

# draw one line of an object
add $t5, $zero, $zero			# Set index for inner loop $t5 to 0

drawObjectLineLoop:
beq $t5, $a1, endDrawObjectLine		# End loop if the number of iterations == 8 since 8 pixels is the car's length
add $t3, $t0, $zero			# realign $t3 and $t0, so there's no wrapping behavior

#  before we store the pixel, we have to know the offset is still in the range of startingPoint + 128, so store that in $t8
sltu $t9, $t0, $t8			# if $t0 is < $t8, then it doesn't need to wrap around
beq $t9, 0, wrapObjectLeft		# if $t0 >= $t8, we have to shift the pixel left by 128
j belowObject
wrapObjectLeft: 
addi $t3, $t0, -128
belowObject:
# do nothing, pixel is where it should be.

sw $t4, 0($t3)				# draw a pixel with color stored in $t4 at address stored in $t0 
addi $t0, $t0, 4			# increment $t0 by 4
addi $t5, $t5, 1			# increment $t5 by 1
j drawObjectLineLoop
endDrawObjectLine:

sll $t2, $a1, 2				# after finishing a line, shift back 4*the width we are given in $a1
addi $t0, $t0, 128			# add 128 to $t0 to drop down a full line
sub $t0, $t0, $t2			# actually shift the pointer to the left
addi $t1, $t1, 128			# increment the leftmost pixel space, for handling wrapping behavior
addi $t8, $t1, 128

#move to the next line
addi $t6, $t6, 1			# increment the height counter
j drawObjectsLoop
endDrawObjects:

jr $ra					# go back to line below the calling function


########## drawRectangle legend ###
#	$t0: address of location in memory where we'll put the pixel color  
#	$t4: stores a hex color to be drawn
#	$t5: the width index for inner loop
#	$t6: the height index for outer loop
#	$t7: stores width * 4
# 	$a0: desired height
#	$a1: desired width
#	
#####################################


drawRectangle:				# can be used to fill in any buffer, if we set $t0 = the first pixel's address in the buffer
add $t6, $zero, $zero			# Set index in $t6 to 0

drawRectangleLoop:

beq $t6, $a0, endRectangle		# If index has reach the required height, exit loop

# draw a line
add $t5, $zero, $zero			# Set index for inner loop $t5 to 0

drawLineLoop:
beq $t5, $a1, endDrawLine		# End loop if the number of iterations == the desired width
sw $t4, 0($t0)				# draw a pixel with color stored in $t4 at address stored in $t0 
addi $t0, $t0, 4			# increment $t0 by 4
addi $t5, $t5, 1			# increment $t5 by 1
j drawLineLoop
endDrawLine:

sll $t7, $a1, 2				# after finishing a line, shift back 4*the width we are given in $a1
addi $t0, $t0, 128			# add 128 to $t0 to drop down a full line
sub $t0, $t0, $t7			# actually shift the pointer to the left

#move to the next line
addi $t6, $t6, 1			# increment the height counter
j drawRectangleLoop
endRectangle:

jr $ra					# go back to line below the calling function

  
      
### end of functions   

  
##########################   start the process loop  #########################
processLoop:

lb $t0, collision
beq $t0, 0, lastFrameNotCollision
# if code reaches here, last frame was a collision of the frog and we need to draw the Animation 4 on this iteration
add $t0, $zero, $zero
sb $t0, collision			# reset the value of collision to 0
addi $t1, $zero, 4
sw $t1, frogDirection			# set the frog's sprite to be the first death animation


lastFrameNotCollision:

add $t0, $zero, $zero  			# reset collision to 0
sb $t0, collision 

lb $t0, isPaused
# if it's paused, we ONLY want to listen for p or q, if no input, or if not p or q, sleep and loop back up. 
beq $t0, 0, gameNotPaused 
# if code reaches here, the isPaused boolean is true.  
lw $t8, 0xffff0000			# check if there is any input at all
beq $t8, 1, listenForPQ
# if code reaches here, there was no input and game is paused, need to sleep and restart
# sleep and then try to listen for input again
li $v0, 32				# put sleep syscall code in $v0
li $a0, 17				# sleep for duration: 16.67 ~ 17 milliseconds
syscall
j processLoop


listenForPQ:
# there was SOME input, check if it was P or Q, if so, handle it.
lw $t2, 0xffff0004
beq $t2, 0x70, respond_to_P
beq $t2, 0x71, respond_to_Q
# if code reaches here, the input was something irrelevant, sleep and loop back up.
li $v0, 32					# put sleep syscall code in $v0
li $a0, 17					# sleep for duration: 16.67 ~ 17 milliseconds
syscall
j processLoop


gameNotPaused:

lw $t8, 0xffff0000
beq $t8, 1, keyboardInput			# otherwise, jump below key stroke handling
j belowKeyboard



keyboardInput:
# if the frog is in the middle of an animation, ignore keyboard input.
lw $t1, frogDirection
beq $t1, 4, belowKeyboard
beq $t1, 5, belowKeyboard			# jump below keyboard because we don't want to allow escape of death animation

# if code reaches here, the frog is 'live'
lw $t2, 0xffff0004
beq $t2, 0x61, respond_to_A
beq $t2, 0x73, respond_to_S
beq $t2, 0x64, respond_to_D
beq $t2, 0x65, respond_to_E
beq $t2, 0x77, respond_to_W
beq $t2, 0x70, respond_to_P
beq $t2, 0x71, respond_to_Q
j belowKeyboard

respond_to_A:				# move left command
la $t9, frogX				# put the memory address of x location in $t9
lw $t8, 0($t9)				# load the value that is at $t9 address into $t8
beq $t8, 0, belowKeyboard		# do nothing if the X coordinate was already 0
addi $t8, $t8, -4
sw $t8, 0($t9)				# store the left-moved x-coordinate back in memory
addi $t0, $zero, 1
sw $t0, frogDirection
# play a sound
li $v0, 33				# put sleep syscall code in $v0
li $a0, 60				# pitch
li $a1, 125				# duration ms
li $a2, 97 				# instrument
li $a3, 80				# volume
syscall
# second sound effect
li $a0, 70				# pitch
li $a1, 100				# duration ms
li $a2, 97				# instrument
li $a3, 80				# volume
syscall

j belowKeyboard

respond_to_E:
lw $t0, difficulty
beq $t0, 2, backToBeginner		# we need to loop back to beginner level
# assuming the difficulty is going up
addi $t0, $t0, 1
sw $t0, difficulty			# set difficulty up one notch

lw $t2, carR1Req
addi $t2, $t2, -1
sw $t2, carR1Req 
lw $t2, carR2Req
addi $t2, $t2, -1
sw $t2, carR2Req 
lw $t2, logR1Req
addi $t2, $t2, -1
sw $t2, logR1Req 
lw $t2, logR2Req
addi $t2, $t2, -1
sw $t2, logR2Req 
j belowKeyboard	

backToBeginner:
add $t1, $zero, $zero
sw $t1, difficulty			# set difficulty pointer back to 0 

lw $t2, carR1Req
addi $t2, $t2, 2
sw $t2, carR1Req 
lw $t2, carR2Req
addi $t2, $t2, 2
sw $t2, carR2Req 
lw $t2, logR1Req
addi $t2, $t2, 2
sw $t2, logR1Req 
lw $t2, logR2Req
addi $t2, $t2, 2
sw $t2, logR2Req 
										#  
j belowKeyboard


respond_to_S: 				# move back/down command
la $t9, frogY				# put the memory address of x location in $t9
lw $t8, 0($t9)				# load the value that is at $t9 address into $t8
beq $t8, 7, belowKeyboard		# do nothing if the Y coordinate was already 7 (the lowest on screen)
addi $t8, $t8, 1			# add 1 to Y coordinate, which moves the frog down on screen.
sw $t8, 0($t9)				# store the left-moved x-coordinate back in memory
addi $t0, $zero, 2			# set the frog's frogDirection variable to 2, meaning 'facing down'
sw $t0, frogDirection
# play a sound
li $v0, 33				# put sleep syscall code in $v0
li $a0, 60				# pitch
li $a1, 125				# duration ms
li $a2, 97 				# instrument
li $a3, 80				# volume
syscall
# second sound effect
li $a0, 70				# pitch
li $a1, 100				# duration ms
li $a2, 97				# instrument
li $a3, 80				# volume
syscall
j belowKeyboard

respond_to_D: 				# move right command
la $t9, frogX				# put the memory address of x location in $t9
lw $t8, 0($t9)				# load the value that is at $t9 address into $t8
beq $t8, 7, belowKeyboard		# do nothing if the X coordinate was already 7
addi $t8, $t8, 4
sw $t8, 0($t9)				# store the right-moved x-coordinate back in memory
addi $t0, $zero, 3			# set the frog's frogDirection variable to 3, meaning 'right'
sw $t0, frogDirection
# play a sound
li $v0, 33				# put sleep syscall code in $v0
li $a0, 60				# pitch
li $a1, 100				# duration ms
li $a2, 97 				# instrument
li $a3, 80				# volume
syscall
# second sound effect
li $a0, 70				# pitch
li $a1, 80				# duration ms
li $a2, 97				# instrument
li $a3, 80				# volume
syscall
j belowKeyboard

respond_to_W: 				# move up command
la $t9, frogY				# put the memory address of x location in $t9
lw $t8, 0($t9)				# load the value that is at $t9 address into $t8
beq $t8, 1, belowKeyboard		# do nothing if the Y coordinate was already 0 (the highest on screen)
addi $t8, $t8, -1			# add 1 to Y coordinate, which moves the frog down on screen.
sw $t8, 0($t9)				# store the left-moved x-coordinate back in memory
add $t0, $zero, $zero			# set the frog's frogDirection variable to 0, meaning 'facing up'
sw $t0, frogDirection
# play a sound
li $v0, 33				# put sleep syscall code in $v0
li $a0, 60				# pitch
li $a1, 125				# duration ms
li $a2, 97 				# instrument
li $a3, 80				# volume
syscall
# second sound effect
li $a0, 70				# pitch
li $a1, 100				# duration ms
li $a2, 97				# instrument
li $a3, 80				# volume
syscall
j belowKeyboard


respond_to_P:
lb $t0, isPaused			# get the boolean isPaused

beq $t0, 0, setPaused			# if it's false, jump down and set it to 'true'
# if the code reaches here, the game must have been paused.  We need to unpause the game
add $t1, $zero, $zero			# set isPaused to 0, meaning 'unpaused' 
sb $t1, isPaused
j belowKeyboard

setPaused:
addi $t1, $zero, 1
sb $t1, isPaused			# set the value of 'isPaused' to 1, meaning 'paused' state
j belowKeyboard


respond_to_Q: 				# hard quit game command
j Exit					

# don't need to jump, already at end.

belowKeyboard:

####  check for success / fail collisions

jal checkSucceed
# if code is here, then the frog hit an open space and we need to draw the 'success' sprite in that space and move the frog back to the starting position
lb $t1, succeeded
beq $t1, 0, continueAfterNoSuccess	# frog didn't succeed yet
# frog succeeded and we need to change it's location
jal resetFrog				# doesn't happen if noSuccess
li $v0, 32				# put sleep syscall code in $v0
li $a0, 17				# sleep for duration: 16.67 ~ 17 milliseconds
syscall
add $t1, $zero, $zero 
sb $t1, succeeded			# now set Succeeded back to 0, since we already reset the frog's position

continueAfterNoSuccess:

# check for collisions with bottom row of cars
add $t0, $zero, $zero 			# set t0 = 0 meaning car.
addi $t1, $zero, 6			# bottom row of cars is row 6
lw $t2, car1
jal checkCollision

add $t0, $zero, $zero 			# set t0 = 0 meaning car.
addi $t1, $zero, 6			# bottom row of cars is row 6
lw $t2, car2
jal checkCollision

add $t0, $zero, $zero 			# set t0 = 0 meaning car.
addi $t1, $zero, 5			# top row of cars is row 5
lw $t2, car3
jal checkCollision

add $t0, $zero, $zero 			# set t0 = 0 meaning car.
addi $t1, $zero, 5			# top row of cars is row 5
lw $t2, car4
jal checkCollision

addi $t0, $zero, 1 			# set t0 = 1 meaning log.
addi $t1, $zero, 3			# top row of cars is row 3
lw $t2, log1
jal checkCollision

addi $t0, $zero, 1 			# set t0 = 1 meaning log.
addi $t1, $zero, 3			# top row of cars is row 3
lw $t2, log2
jal checkCollision

addi $t0, $zero, 1 			# set t0 = 1 meaning log.
addi $t1, $zero, 2			# top row of cars is row 2
lw $t2, log3
jal checkCollision

addi $t0, $zero, 1 			# set t0 = 1 meaning log.
addi $t1, $zero, 2			# top row of cars is row 2
lw $t2, log4
jal checkCollision


# goal here is to draw the grass into the buffer

la $t0, topGrass 			# $t0 stores the base address for the topGrass buffer

li $t4, 0x33cc33 			# $t1 stores the green grass color
addi $a0, $zero, 8			# set the height of rectangle to 8
addi $a1, $zero, 32			# set the width of rectangle to draw to 32
jal drawRectangle

# now draw the remaining lives ontop of the top grass
jal drawRemLives			# draw a number of crosses into the buffer = num lives remaining. 
jal drawDifficulty			# draw the number of bars accordingly to the speed of logs/cars

# goal here is to draw the water only into the buffer
# load pixel color values into the .space for logRow2
la $t0, logRow2				# $t0 stores the base address for the topGrass buffer

li $t4, 0x3366cc 			# $t1 stores the blue water color
addi $a0, $zero, 8			# set the height of rectangle to 8
addi $a1, $zero, 32			# set the width of rectangle to draw to 32
jal drawRectangle			# experiment to see if memory is contiguous............................


# goal here is to draw the safe center space into the buffer
# load pixel color values into the .space for safeSpace
la $t0, safeSpace				# $t0 stores the base address for the topGrass buffer

li $t4, 0xffd480 			# $t1 stores the light biege color
addi $a0, $zero, 4			# set the height of rectangle to 8
addi $a1, $zero, 32			# set the width of rectangle to draw to 32
jal drawRectangle			# experiment to see if memory is contiguous............................


# load pixel color values into the .space for CarRow1/2 buffer
la $t0, carRow2
li $t4, 0x666666 			# $t4 stores the grey road color
addi $a0, $zero, 8			# set the height of rectangle to 8
addi $a1, $zero, 32			# set the width of rectangle to draw to 32
jal drawRectangle			
# load pixel color values into the .space for bottomGrass buffer
la $t0, bottomGrass			# $t0 stores the address allocated for the bottomGrass in the buffer
li $t4, 0x33cc33  			# $t4 stores the green grass color
addi $a0, $zero, 4			# set the height of rectangle to 4
addi $a1, $zero, 32			# set the width of rectangle to draw to 32
jal drawRectangle			

# draw success Sprites
jal drawSuccessSprites

# draw the moving objects into the buffer

# draw logs first, left-moving
addi $t4, $zero, 0x86592d		# store brown as the log's color
la $t1, logRow2				# this will be use to mark the left-most pixel of each of the 4 rows, since $t0 will be incrementing
la $t0, logRow2 			# top left corner address of the cars row 1 region, will be incremented
lw $t7, log4				# the 0-31 horizontal offset of the log
jal drawMoving 			# draw log #2

la $t1, logRow2				# this will be use to mark the left-most pixel of each of the 4 rows, since $t0 will be incrementing
la $t0, logRow2
lw $t7, log3				# the 0-31 horizontal offset of the log
jal drawMoving			# draw log #1

# draw logs, right-moving
la $t1, logRow1				# this will be use to mark the left-most pixel of each of the 4 rows, since $t0 will be incrementing
la $t0, logRow1 			# top left corner address of the cars row 1 region, will be incremented
lw $t7, log2				# the 0-31 horizontal offset of the log
jal drawMoving 			# draw log #2

la $t1, logRow1				# this will be use to mark the left-most pixel of each of the 4 rows, since $t0 will be incrementing
la $t0, logRow1 
lw $t7, log1				# the 0-31 horizontal offset of the log
jal drawMoving			# draw log #1


# draw cars

addi $t4, $zero, 0xff33cc		# store hot pink as the car's color
la $t1, carRow2				# this will be use to mark the left-most pixel of each of the 4 rows, since $t0 will be incrementing
la $t0, carRow2			# top left corner address of the cars row 1 region, will be incremented
lw $t7, car3				# the 0-31 horizontal offset of the car
jal drawMoving 			# draw car #2

la $t1, carRow2				# this will be use to mark the left-most pixel of each of the 4 rows, since $t0 will be incrementing
la $t0, carRow2 
lw $t7, car4				# the 0-31 horizontal offset of the car
jal drawMoving			# draw car #1


		# store hot pink as the car's color
la $t1, carRow1				# this will be use to mark the left-most pixel of each of the 4 rows, since $t0 will be incrementing
la $t0, carRow1 			# top left corner address of the cars row 1 region, will be incremented
lw $t7, car2				# the 0-31 horizontal offset of the car
jal drawMoving 			# draw car #2

la $t1, carRow1				# this will be use to mark the left-most pixel of each of the 4 rows, since $t0 will be incrementing
la $t0, carRow1 
lw $t7, car1				# the 0-31 horizontal offset of the car
jal drawMoving			# draw car #1

# draw the frog ontop of everything
# if collision happened, need to run the frog reset position function before here.

# WHERE WE'LL DRAW FROG, POINTING IN DIRECTION OF MOVEMENT  ###########################

jal drawFrog

# check if the game is paused,  draw the pause screen ontop of everything, if it is.  
lb $t0, isPaused
beq $t0, 1, gameIsPaused
# if code reaches here, the game wasn't paused so we should jump below to 'notPaused'
j notPaused

gameIsPaused:
jal drawPauseScreen


notPaused:
# now draw ALL pixels from ALL the different sections into the displayMap

lw $t0, displayAddress
la $t1, topGrass			# $t1 gets the address of the first element of space allocated for grass, ie: top left of whole game board

# for 4096 pixels, stored at each 4 memory addresses, take the one FROM the buffer starting at address of topGrass and put it INTO the displayAddress corresponding location
addi $t2, $t0, 16384			# the first out-of-bounds memory address for the display

copyOverLoop: 
beq $t2, $t0, endCopy
lw $t3, 0($t1)				# grab the pixel at memory address in $t1
sw $t3, 0($t0)				# store the pixel from the buffer into the display
addi $t0, $t0, 4			# increment the address of display map by 4
addi $t1, $t1, 4			# increment the address of the buffer by 4
j copyOverLoop
endCopy:

# if the game is paused, just loop back to the top and don't increment objects
# debating if this line is needed, where we might jump somewhere above 

# now screen has been drawn, need to handle collisions in the next loop
# if the frog is in animation, ie: frogDirection = 4 or 5, we want to emphasize by sleeping here
lw $t1, frogDirection
beq $t1, 4, sleepEmphasis1
beq $t1, 5, sleepEmphasis2
j belowSleepEmphasis

sleepEmphasis1: 
# play a sound
li $v0, 33				# put sleep syscall code in $v0
li $a0, 50				# pitch
li $a1, 200				# duration ms
li $a2, 23				# instrument
li $a3, 80				# volume
syscall

li $v0, 32				# put sleep syscall code in $v0
li $a0, 430				# sleep for duration: ~.3 seconds to emphasize the death animation
syscall
 j belowSleepEmphasis
 
sleepEmphasis2:
# play a sound
li $v0, 33				# put sleep syscall code in $v0
li $a0, 40				# pitch
li $a1, 200				# duration ms
li $a2, 23				# instrument
li $a3, 80				# volume
syscall


 
belowSleepEmphasis:
   
lw $t0, lives
beq $t0, 0, EndProcessLoop

# now check to see if collision is = 1
lb $t0, collision
beq $t0, 1, collided
j belowCollided

collided:
# play a sound
li $v0, 33				# put sleep syscall code in $v0
li $a0, 60				# pitch
li $a1, 200				# duration ms
li $a2, 23				# instrument
li $a3, 80				# volume
syscall
jal decrementLives
li $v0, 32				# put sleep syscall code in $v0
li $a0, 300				# sleep for duration: ~.3 seconds to emphasize the death animation
syscall
# set off the death animation
# the two lines below have been moved to the top of the process loop
# addi $t0, $zero, 4 			# set the frog's direction to 4, the last animation
#sw $t0, frogDirection

belowCollided:

# check to see if an animation just finished being drawn: 
# if so, reset the frog's position, otherwise skip
lw $t1, frogDirection
bne $t1, 5, notTransition
add $t2, $zero, $zero		# reset the animation to frog facing up 
sw $t2, frogDirection
jal resetFrog
j processLoop

notTransition:

# check to see if the frog is mid-transition
lw $t1, frogDirection
bne $t1, 4, notMidTransition
addi $t1, $t1, 1		# progress to the next phase of animation
sw $t1, frogDirection		# set frog direction to 5, ie: deathAnimation2
j processLoop			# want everything stationary as animation happens, so go up to top of loop

notMidTransition:

# check if it's time to move carR1 yet
lw $t4 carR1Req
lw $t3, carR1Ticks
slt $t5, $t3, $t4
# if #t5=1, we want to skip the pixel moves because ticks are less than required ticks.
beq $t5, 1, skipCarR1upd
# update locations of cars in row 1

lw $t0, car1
addi $t0, $t0, 1			# take car 1's top left corner location, add 1
addi $t1, $zero, 32			# store 32 in $t1
divu $t0, $t1				# divide the position by 32
mfhi $t0				# update $t0 to be $t0 % 32, so it resets to 0 when it reaches 32
sw $t0, car1

lw $t0, car2
addi $t0, $t0, 1			# take car 1's top left corner location, add 1
addi $t1, $zero, 32			# store 32 in $t1
divu $t0, $t1				# divide the position by 32
mfhi $t0				# update $t0 to be $t0 % 32, so it resets to 0 when it reaches 32
sw $t0, car2

add $t3, $zero, $zero
sw $t3, carR1Ticks
j belowCarR1

skipCarR1upd:
addi $t3, $t3, 1
sw $t3, carR1Ticks

belowCarR1:


# update locations of log row 1 if needed 
lw $t4 logR1Req
lw $t3, logR1Ticks
slt $t5, $t3, $t4
# if #t5=1, we want to skip the pixel moves
beq $t5, 1, skipLogR1upd

lw $t0, log1
addi $t0, $t0, 1			# take car 1's top left corner location, add 1
addi $t1, $zero, 32			# store 32 in $t1
divu $t0, $t1				# divide the position by 32
mfhi $t0				# update $t0 to be $t0 % 32, so it resets to 0 when it reaches 32
sw $t0, log1

lw $t0, log2
addi $t0, $t0, 1			# take car 1's top left corner location, add 1
addi $t1, $zero, 32			# store 32 in $t1
divu $t0, $t1				# divide the position by 32
mfhi $t0				# update $t0 to be $t0 % 32, so it resets to 0 when it reaches 32
sw $t0, log2

add $t3, $zero, $zero
sw $t3, logR1Ticks
j belowLogR1

skipLogR1upd:
addi $t3, $t3, 1
sw $t3, logR1Ticks

belowLogR1:



# decrement the pixels of all left-moving objects
lw $t4 carR2Req
lw $t3, carR2Ticks
slt $t5, $t3, $t4
# if #t5=1, we want to skip the pixel moves
beq $t5, 1, skipCarR2upd


lw $t0, car3
blez $t0, setCar3
addi $t0, $t0, -1
j belowSetCar3			
setCar3: 
addi $t0, $zero, 31
belowSetCar3:			
sw $t0, car3

lw $t0, car4
blez $t0, setCar4
addi $t0, $t0, -1
j belowSetCar4			
setCar4: 
addi $t0, $zero, 31
belowSetCar4:			
sw $t0, car4

add $t3, $zero, $zero
sw $t3, carR2Ticks
j belowCarR2

skipCarR2upd:
addi $t3, $t3, 1
sw $t3, carR2Ticks

belowCarR2:


lw $t4 logR2Req
lw $t3, logR2Ticks
slt $t5, $t3, $t4
# if #t5=1, we want to skip the pixel moves
beq $t5, 1, skipLogR2upd

lw $t0, log3
blez $t0, setLog3
addi $t0, $t0, -1
j belowSetLog3			
setLog3: 
addi $t0, $zero, 31
belowSetLog3:			
sw $t0, log3

lw $t0, log4
blez $t0, setLog4
addi $t0, $t0, -1
j belowSetLog4				
setLog4: 
addi $t0, $zero, 31
belowSetLog4:			
sw $t0, log4

add $t3, $zero, $zero
sw $t3, logR2Ticks
j belowLogR2

skipLogR2upd:
addi $t3, $t3, 1
sw $t3, logR2Ticks

belowLogR2:



li $v0, 32				# put sleep syscall code in $v0
li $a0, 17				# sleep for duration: 16.67 ~ 17 milliseconds
syscall

j processLoop

EndProcessLoop:

Exit:
li $v0, 10 # terminate the program gracefully
syscall
