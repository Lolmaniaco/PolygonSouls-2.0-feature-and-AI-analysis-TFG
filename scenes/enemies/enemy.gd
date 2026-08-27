class_name Enemy
extends RigidBody2D

var directionToPlayer
var speed = 100
var explosion = preload("res://particles/fake_explosion_particles.tscn")
var movement
var posX
var posY

@onready var player: Player = $"../../../player"
@onready var roomCam: Camera2D = $"../../../cameras/roomCam"


func _ready() -> void:
	_start_delay()


func trigger_death():
	pass


func spawn():
	position = Vector2(posX, posY)


func setupSpawn(x, y):
	posX = x
	posY = y


func take_hit():
	pass


func createExplosion():
	var newExp = explosion.instantiate()
	newExp.setup(position)
	get_parent().get_parent().add_child(newExp)
	newExp.particles_explode = true


func updatePlayerSouls(amount):
	roomCam.updateSoulsValue(amount)


func _start_delay() -> void:
	spawn()

	set_physics_process(false)
	await get_tree().create_timer(0.4).timeout
	set_physics_process(true)
