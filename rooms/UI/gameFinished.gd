extends Control

@onready var time_message: Label = $VBoxContainer/TimeMessage
@onready var color_rect: ColorRect = $ColorRect
@onready var texture_rect: TextureRect = $TextureRect
@onready var thanks_message: Label = $VBoxContainer/ThanksMessage


func _ready() -> void:
	thanks_message.text = TranslationServer.translate("GAME_WON1") + "\n\n" + TranslationServer.translate("GAME_WON2") + "\n" + TranslationServer.translate("GAME_WON3") + "\n" + TranslationServer.translate("GAME_WON4")
	time_message.text = TranslationServer.translate("FINISHED") + Global.game_time + TranslationServer.translate("MINUTES")
	texture_rect.modulate = Color.DIM_GRAY
	color_rect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate", Color.TRANSPARENT, 10)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('resetScene'):
		get_tree().change_scene_to_file("res://rooms/proceduralGeneration.tscn")
