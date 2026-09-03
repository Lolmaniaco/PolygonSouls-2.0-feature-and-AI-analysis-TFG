extends Node

signal update_souls_UI(souls: int)
signal update_rooms_UI(rooms: int)

const EXPLOSION = preload("uid://bdc7he4vk1evl")
const NUCLEAR_EXPLOSION = preload("uid://dajqvpqvuu841")

var game_time: String
var death_counter: int = 0
var restart_timer: float = 10
var reset_timer: Timer
var player: Player = null
var UI: UserInterface = null

var soulsCollected: int = 0
var roomsCleared: int = 0

@onready var cameras: CameraManager


func _ready() -> void:
	reset_timer = Timer.new()
	reset_timer.wait_time = 2
	reset_timer.one_shot = true
	reset_timer.autostart = false
	reset_timer.timeout.connect(_on_reset_timer_timeout)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('resetScene', true):
		if reset_timer.is_stopped() and reset_timer.is_inside_tree():
			reset_timer.start()

		restart_timer -= 1
		if restart_timer <= 0:
			get_tree().reload_current_scene()
			restart_timer = 10


func create_explosion(new_position: Vector2) -> void:
	var new_explosion: GPUParticles2D = EXPLOSION.instantiate()
	new_explosion.position = new_position
	add_child(new_explosion)
	new_explosion.set_emitting(true)
	await get_tree().create_timer(0.6).timeout
	new_explosion.queue_free()


func create_nuclear_explosion(new_position: Vector2) -> void:
	var new_explosion: GPUParticles2D = EXPLOSION.instantiate()
	new_explosion.lifetime = 1
	new_explosion.process_material = NUCLEAR_EXPLOSION
	new_explosion.position = new_position
	add_child(new_explosion)
	new_explosion.set_emitting(true)
	cameras.shake_screen(0.4)
	await get_tree().create_timer(1.1).timeout
	new_explosion.queue_free()


func getRoomsCleared():
	return roomsCleared


func updateRoomsCleared():
	roomsCleared += 1
	update_rooms_UI.emit(roomsCleared)


func getPlayerSouls():
	return soulsCollected


func updateSoulsValue(amount):
	soulsCollected += amount
	update_souls_UI.emit(soulsCollected)


func _on_reset_timer_timeout() -> void:
	restart_timer = 10
