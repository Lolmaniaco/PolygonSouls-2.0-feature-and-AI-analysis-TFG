class_name Enemy
extends RigidBody2D

var speed = 100


func _ready() -> void:
	_start_delay()


func setupSpawn(x, y):
	position = Vector2(x, y)


func trigger_death(_get_souls: bool):
	pass


func take_hit():
	pass


func updatePlayerSouls(amount):
	Global.updateSoulsValue(amount)


func _start_delay() -> void:
	set_physics_process(false)
	await get_tree().create_timer(0.4).timeout
	set_physics_process(true)
