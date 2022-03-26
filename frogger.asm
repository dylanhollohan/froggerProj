#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Dylan Hollohan, 1004407439
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
# - Milestone 0 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
# COLORS: 
# Hot pink:          ff33cc
# Green (grass):     33cc33
# Green (frog):      008000
# Blue:              3366cc
# Grey (road):       b3b3b3
# Brown (log):       86592d
# Biege (center safe): ffd480
# Yellow (frog's feet): ffff66
#
#####################################################################


.data
displayAddress: .word 0x10008000
frogX:  .word 3         
frogY:  .word 7
height:	.word 512

# analagous to 'i',  int, 0 assignment
.text
lw $t0, displayAddress 			# $t0 stores the base address for display

li $t1, 0x33cc33 			# $t1 stores the green grass color
addi $t2, $t0, 1024   		        # set $t2 to store displayAddress + 1024, this is the last address for green

DrawTopGrass:
beq $t0, $t2, EndTopGrassDraw 
sw $t1, 0($t0)				# paint the current unit green.
addi $t0, $t0, 4  			# increment the address for painting by 4
j DrawTopGrass

EndTopGrassDraw:

li $t1, 0x3366cc 				# $t1 stores the blue water color
addi $t2, $t0, 1024   		        # set $t2 to store displayAddress (currently 1024) + 1024, this is the last address for blue as end condition

DrawWater:
beq $t0, $t2, EndDrawWater
sw $t1, 0($t0)				# paint the current unit of the water region blue.
addi $t0, $t0, 4  			# increment the address for painting by 4
j DrawWater

EndDrawWater:

li $t1, 0xffd480				# $t1 stores the blue water color
addi $t2, $t0, 512   		        # set $t2 to store displayAddress (currently 2048) + 512, this is the last address for biege as end condition

DrawCenterStrip:
beq $t0, $t2, EndDrawCenter
sw $t1, 0($t0)				# paint the current unit of the dried grass biege.
addi $t0, $t0, 4  			# increment the address for painting by 4
j DrawCenterStrip

EndDrawCenter:

li $t1, 0xb3b3b3				# $t1 stores the blue water color
addi $t2, $t0, 1024   		        # set $t2 to store displayAddress (currently 2560) + 1024, this is the last address for biege as end condition

DrawRoad:
beq $t0, $t2, EndDrawRoad
sw $t1, 0($t0)				# paint the current unit of the dried grass biege.
addi $t0, $t0, 4  			# increment the address for painting by 4
j DrawRoad

EndDrawRoad:

li $t1, 0x33cc33 			# $t1 stores the green grass color
addi $t2, $t0, 512  		        # set $t2 to store displayAddress (currently 3584) + 512, this is the last address for green

DrawBottomGrass:
beq $t0, $t2, EndBottomGrassDraw 
sw $t1, 0($t0)				# paint the current unit green.
addi $t0, $t0, 4  			# increment the address for painting by 4
j DrawBottomGrass

EndBottomGrassDraw:

DrawFrog:
lw $t0, displayAddress  		# set $t0 to store displayAddress as it was originally instantiated
li $t1, 0xffff66 			# $t1 stores the dark green frog color
# ffff66, 008000
lw $t2, height				# 512 is the height in memory address of the frog
lw $t3, frogX				# a value in 0-7, left to right
##  next we want to calculate the top left of the frog sprite by taking (0,0) and offsetting by the frog's x-y coordinates
# set up for moving the frog over by 3 frog-size units to the right
addi $t4, $zero, 16			# the number of addresses to move to the right for each unit in X coordinate
mult $t4, $t3				# multiply 16 by x coordinate
mflo $t4
add $t0, $t0, $t4			# off-set the frog horizontally 

lw $t3 frogY
mult $t2, $t3				# multiply 512 by the Y-coordinate
mflo $t4				# retrieve multiplication result
add $t0, $t0, $t4			# offset the frog vertically

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




Exit:
li $v0, 10 # terminate the program gracefully
syscall
