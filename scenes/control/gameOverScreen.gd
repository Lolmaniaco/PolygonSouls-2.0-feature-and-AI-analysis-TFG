extends Node2D


func _input(event):
	if Input.is_action_pressed('resetScene'):
		get_tree().change_scene_to_file("res://scenes/levels/proceduralGeneration.tscn")
