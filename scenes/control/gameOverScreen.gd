extends Node2D
	
func _ready():
	pass # Replace with function body.

func _input(event):
	if Input.is_action_pressed('resetScene'):
		get_tree().change_scene("res://scenes/levels/proceduralGeneration.tscn")

