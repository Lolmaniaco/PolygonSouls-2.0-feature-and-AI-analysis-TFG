class_name Enemy
extends RigidBody2D

var speed = 100

@onready var explosion = preload("res://particles/fake_explosion_particles.tscn")

@onready var player: Player
@onready var UI: UserInterface


func _ready() -> void:
	UI = $"../../../../player/UI"
	_start_delay()


func setupSpawn(x, y):
	position = Vector2(x, y)


func trigger_death():
	pass


func take_hit():
	pass


func createExplosion():
	var newExp = explosion.instantiate()
	newExp.setup(position)
	get_parent().get_parent().add_child(newExp)
	newExp.particles_explode = true


func updatePlayerSouls(amount):
	UI.updateSoulsValue(amount)


func _start_delay() -> void:
	set_physics_process(false)
	await get_tree().create_timer(0.4).timeout
	set_physics_process(true)
