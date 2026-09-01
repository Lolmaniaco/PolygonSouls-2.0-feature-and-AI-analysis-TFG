extends Control

@onready var time_message: Label = $VBoxContainer/TimeMessage


func _ready():
	time_message.text = "Has completado PolygonSouls 2.0 en " + Global.time + " minutos"


func _input(event):
	if event.is_action_pressed('resetScene'):
		get_tree().change_scene_to_file("res://rooms/proceduralGeneration.tscn")
