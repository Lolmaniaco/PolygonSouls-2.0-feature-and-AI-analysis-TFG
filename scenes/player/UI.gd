class_name UserInterface
extends CanvasLayer

@export var maxRooms: int = 12

var soulsCollected = 0
var roomsCleared = 0
var controllerConnected = false
var time
var colorIndicator = false

@onready var souls_collected: Label = $VBoxContainer/SoulsCollected
@onready var cleared_rooms: Label = $VBoxContainer/ClearedRooms
@onready var game_time: Label = $VBoxContainer/GameTime


func _ready():
	time = 0


func _process(delta):
	if Input.get_connected_joypads().size() > 0:
		controllerConnected = true
	else:
		controllerConnected = false

	time += delta
	var seconds = fmod(time, 60)
	var minutes = fmod(time, 3600) / 60
	Global.time = "%02d:%02d" % [minutes, seconds]
	game_time.text = str(Global.time)


func isControllerConnected():
	return controllerConnected


func gameWon():
	var t = Timer.new()
	t.set_wait_time(3)
	t.set_one_shot(true)
	add_child(t)
	t.start()
	await t.timeout
	get_tree().change_scene_to_file("res://scenes/control/gameFinished.tscn")


func getMaxRooms():
	return maxRooms


func updateRoomsCleared(value):
	roomsCleared += value


func getRoomsCleared():
	return roomsCleared


func updateSoulsValue(amount):
	soulsCollected += amount
	updateSoulsLabel()


func updateSoulsLabel():
	souls_collected.text = str(soulsCollected) + " Almas"


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
