class_name Door
extends Marker2D


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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
