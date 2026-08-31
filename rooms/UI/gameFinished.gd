extends Control


func _ready():
	$TimeMessage.text = "Has completado PolygonSouls 2.0 en " + Global.time + " minutos"


func _input(event):
	if event.is_action_pressed('resetScene'):
		get_tree().change_scene_to_file("res://rooms/proceduralGeneration.tscn")
