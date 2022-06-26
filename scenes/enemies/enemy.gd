extends KinematicBody2D

var directionToPlayer
var speed = 100
onready var player = get_node("../../../player")
onready var roomCam = get_node("../../../cameras/roomCam")
var explosion = preload("res://particles/fake_explosion_particles.tscn")
var movement
var posX
var posY

var roomX
var roomY

var safeDistance = Vector2(200,200)

func _ready():
	pass # Replace with function body.

func spawn():
	randomize()
	self.posX = rand_range(self.roomX[0], self.roomX[1])
	self.posY = rand_range(self.roomY[0], self.roomY[1])
	position = Vector2(self.posX, self.posY)

	# Spawn enemy at another random position if player and enemy are 
	if ((player.getPos() - position).abs() < safeDistance):
		spawn()

func setupSpawn(xMinMaxRoom, yMinMaxRoom):

	self.roomX = xMinMaxRoom
	self.roomY = yMinMaxRoom
	spawn()
	

func createExplosion():
	var newExp =  explosion.instance()
	newExp.setup(position)
	get_parent().get_parent().add_child(newExp)
	newExp.particles_explode = true

func updatePlayerSouls(amount):
	roomCam.updateSoulsValue(amount)
