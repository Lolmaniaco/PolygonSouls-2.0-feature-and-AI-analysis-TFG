class_name Enemy
extends CharacterBody2D

var directionToPlayer
var speed = 100
var explosion = preload("res://particles/fake_explosion_particles.tscn")
var movement
var posX
var posY

var roomX
var roomY

var safeDistance = Vector2(200, 200)

@onready var player: Player = $"../../../player"
@onready var roomCam: Camera2D = $"../../../cameras/roomCam"


func _ready() -> void:
	_start_delay()


func spawn():
	posX = randf_range(roomX[0], roomX[1])
	posY = randf_range(roomY[0], roomY[1])
	position = Vector2(posX, posY)
	print("Enemy spawned at: ", posX, ", ", posY)


func setupSpawn(xMinMaxRoom, yMinMaxRoom):
	roomX = xMinMaxRoom
	roomY = yMinMaxRoom


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
	await get_tree().create_timer(0.25).timeout
	set_physics_process(true)
