class_name Door
extends Marker2D


func setup(initPos, doorRotation):
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
