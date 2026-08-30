class_name Door
extends Node2D


func setup(initPos, doorRotation):
	if initPos.x == 576:
		if initPos.y == 16:
			name = "Upper Door"
		else:
			name = "Down Door"
	else:
		if initPos.x == 16:
			name = "Left Door"
		else:
			name = "Right Door"

	position = initPos
	rotation_degrees = doorRotation


func playDoorAnimation(open):
	if open:
		$AnimationPlayer.play("open")
	else:
		$AnimationPlayer.play_backwards("open")
