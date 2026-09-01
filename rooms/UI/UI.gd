class_name UserInterface
extends CanvasLayer

@export var maxRooms: int = 12

var soulsCollected: int = 1000
var roomsCleared: int = 10
var controllerConnected: bool = false
var colorIndicator: bool = false
var start_time: float = 0

@onready var souls_collected: Label = $VBoxContainer/SoulsCollected
@onready var cleared_rooms: Label = $VBoxContainer/ClearedRooms
@onready var game_time: Label = $VBoxContainer/GameTime
@onready var win_timer: Timer = $WinTimer
@onready var volume: VSlider = $VSlider


func _ready():
	start_time = Time.get_ticks_msec()
	volume.value = AudioServer.get_bus_volume_linear(0) * 100


func _physics_process(_delta: float) -> void:
	controllerConnected = false if Input.get_connected_joypads().is_empty() else true
	var current_time = Time.get_ticks_msec() - start_time
	var total_seconds = current_time / 1000

	var seconds = fmod(total_seconds, 60)
	var minutes = fmod((total_seconds / 60), 60)
	Global.time = "%02d:%02d" % [minutes, seconds]
	game_time.text = str(Global.time)


func isControllerConnected():
	return controllerConnected


func gameWon():
	win_timer.start()


func getMaxRooms() -> int:
	return maxRooms


func getRoomsCleared():
	return roomsCleared


func updateSoulsValue(amount):
	soulsCollected += amount
	updateSoulsLabel()


func updateSoulsLabel():
	souls_collected.text = str(soulsCollected) + " Almas"


func updateRoomsCleared(value):
	roomsCleared += value
	updateRoomsLabel()


func updateRoomsLabel():
	cleared_rooms.text = str(roomsCleared) + " Salas"
	if colorIndicator:
		if roomsCleared <= (maxRooms * 0.7) - 1:
			cleared_rooms.self_modulate = "#ff0000"
		else:
			cleared_rooms.self_modulate = "#3990d6"


func getPlayerSouls():
	return soulsCollected


func activateColorInfo():
	colorIndicator = true
	updateRoomsLabel()


func _on_win_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://rooms/UI/gameFinished.tscn")


func _on_v_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value / 100)
