extends Position2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(initPos, doorRotation):
	self.position = initPos
	self.rotation_degrees = doorRotation
	
	
func playDoorAnimation(open):
	
	if open:
		$AnimationPlayer.play("open")
	else:
		$AnimationPlayer.play_backwards("open")
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

