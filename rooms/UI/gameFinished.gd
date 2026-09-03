extends Control

@onready var time_message: Label = $VBoxContainer/TimeMessage
@onready var color_rect: ColorRect = $ColorRect
@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	texture_rect.modulate = Color.DIM_GRAY
	color_rect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate", Color.TRANSPARENT, 10)

	time_message.text = "Has completado PolygonSouls 2.0 en " + Global.game_time + " minutos"


func _input(event):
	if event.is_action_pressed('resetScene'):
		get_tree().change_scene_to_file("res://rooms/proceduralGeneration.tscn")
