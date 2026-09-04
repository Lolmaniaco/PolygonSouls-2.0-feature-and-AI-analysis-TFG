class_name UserInterface
extends CanvasLayer

const languages: Dictionary = {
	"en": "ENGLISH",
	"es": "ESPAÑOL",
	"cat": "CATALÁN",
}

var current_language: String = "en"

var controller: bool = false
var colorIndicator: bool = false
var start_time: float = 0

@onready var button: Button = $Button

@onready var souls_collected: Label = $VBoxContainer/SoulsCollected
@onready var cleared_rooms: Label = $VBoxContainer/ClearedRooms
@onready var game_time: Label = $VBoxContainer/GameTime
@onready var win_timer: Timer = $WinTimer
@onready var volume: VSlider = $VSlider
@onready var color_rect: ColorRect = $ColorRect


func _ready():
	if OS.get_locale_language() in languages.keys():
		current_language = OS.get_locale_language()
		button.text = languages[current_language]
		TranslationServer.set_locale(current_language)

	souls_collected.text = str(0) + " " + TranslationServer.translate("SOULS")
	cleared_rooms.text = str(0) + " " + TranslationServer.translate("ROOMS")
	start_time = Time.get_ticks_msec()
	volume.value = AudioServer.get_bus_volume_linear(0) * 100
	Global.update_souls_UI.connect(_on_update_souls)
	Global.update_rooms_UI.connect(_on_update_rooms)


func _physics_process(_delta: float) -> void:
	controller = false if Input.get_connected_joypads().is_empty() else true
	var current_time = Time.get_ticks_msec() - start_time
	var total_seconds = current_time / 1000

	var seconds = fmod(total_seconds, 60)
	var minutes = fmod((total_seconds / 60), 60)
	Global.game_time = "%02d:%02d" % [minutes, seconds]
	game_time.text = Global.game_time


func controller_connected():
	return controller


func gameWon():
	win_timer.start()


func activateColorInfo():
	colorIndicator = true
	_on_update_rooms(Global.getRoomsCleared())


func transition_color(new_color: Color) -> void:
	color_rect.color = new_color
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate", Color.WHITE, 0.5)


func _on_update_souls(souls: int) -> void:
	souls_collected.text = str(souls) + " " + TranslationServer.translate("SOULS")


func _on_update_rooms(rooms: int) -> void:
	cleared_rooms.text = str(rooms) + " " + TranslationServer.translate("ROOMS")
	if colorIndicator:
		if rooms <= (Utils.MAX_ROOMS * 0.7) - 1:
			cleared_rooms.self_modulate = "#ff0000"
		else:
			cleared_rooms.self_modulate = "#3990d6"


func _on_win_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://rooms/UI/gameFinished.tscn")


func _on_v_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value / 100)


func _on_button_pressed() -> void:
	match current_language:
		"en": current_language = "es"
		"es": current_language = "cat"
		"cat": current_language = "en"

	button.text = languages[current_language]
	TranslationServer.set_locale(current_language)
	_on_update_souls(Global.soulsCollected)
	_on_update_rooms(Global.roomsCleared)
