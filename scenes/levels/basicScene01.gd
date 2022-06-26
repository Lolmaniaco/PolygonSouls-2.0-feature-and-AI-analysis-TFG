extends Node2D



func _ready():
	get_tree().paused = true

func _input(event):
	if Input.is_action_pressed('resetScene'):	
			get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
