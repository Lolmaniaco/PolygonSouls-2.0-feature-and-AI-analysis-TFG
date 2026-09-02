extends Control


func _ready() -> void:
	modulate = Color.BLACK
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WEB_GRAY, 10)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('resetScene'):
		get_tree().change_scene_to_file("res://rooms/proceduralGeneration.tscn")
