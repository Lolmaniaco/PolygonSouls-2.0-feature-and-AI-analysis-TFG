extends Control

@onready var label_2: Label = $VBoxContainer/Label2


func _ready() -> void:
	label_2.text = TranslationServer.translate("GAME_OVER1") + "\n" + TranslationServer.translate("GAME_OVER2") + "\n" + TranslationServer.translate("GAME_OVER3")
	modulate = Color.BLACK
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WEB_GRAY, 10)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('resetScene'):
		get_tree().change_scene_to_file("res://rooms/proceduralGeneration.tscn")
