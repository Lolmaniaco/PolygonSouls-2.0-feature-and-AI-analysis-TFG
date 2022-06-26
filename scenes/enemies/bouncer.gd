extends "res://scenes/enemies/enemy.gd"

var arrow = preload("res://scenes/enemies/bouncerArrow.tscn")
var targetPos
var hitWall = false;
var collision
var dirToShoot = Vector2(0,1)
var canShoot = true
var playerOnSight = false
var dirAttack
var waitTime = 0.5

var direction
var bounce = 1
func _ready():
	speed *= 0.04
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	direction = rng.randi_range(1, 2)	
	
func _process(delta):
	if waitTime > 0:
		waitTime -= delta
	else:
		if direction == 1:
			if bounce % 2 == 0:
				collision = move_and_collide(Vector2.UP * speed)
			else:
				collision = move_and_collide(Vector2.DOWN * speed)
			if collision != null:
				bounce += 1
		else:
			if bounce % 2 == 0:
				collision = move_and_collide(Vector2.RIGHT * speed)
			else:
				collision = move_and_collide(Vector2.LEFT * speed)
			if collision != null:
				bounce += 1

			
		if dirAttack == "left" and playerOnSight and canShoot:
			canShoot = false
			dirToShoot = Vector2.LEFT
			shootProjectile()
		elif dirAttack == "right" and playerOnSight and canShoot:
			canShoot = false
			dirToShoot = Vector2.RIGHT
			shootProjectile()
		elif dirAttack == "up" and playerOnSight and canShoot:
			canShoot = false
			dirToShoot = Vector2.UP
			shootProjectile()
		elif dirAttack == "down" and playerOnSight and canShoot:
			canShoot = false
			dirToShoot = Vector2.DOWN
			shootProjectile()
		
func _on_Area2D_area_entered(area):
	if collision:
		var result = collision.collider is TileMap
		if collision.collider is TileMap:
			speed = 100
		print("resultado: ", result)

func shootProjectile():
#	print("shoot!")
	var bullet = arrow.instance()
	get_parent().add_child(bullet)
	
	if dirAttack == "left":
		bullet.setup(position, 180, self.dirToShoot, 500, 'R')
	elif dirAttack == "up":
		bullet.setup(position, -90, self.dirToShoot, 500, 'R')
	elif dirAttack == "right":
		bullet.setup(position, 0, self.dirToShoot, 500, 'R')
	elif dirAttack == "down":
		bullet.setup(position, 90, self.dirToShoot, 500, 'R')
		

func _on_reloadTimer_timeout():
	canShoot = true

func _on_crossDetectorDown_area_entered(area):
	if area.name == "pjHitbox" and canShoot:
		dirAttack = "down"
		playerOnSight = true

func _on_crossDetectorLeft_area_entered(area):
	if area.name == "pjHitbox":
		dirAttack = "left"
		playerOnSight = true

func _on_crossDetectorUp_area_entered(area):
	if area.name == "pjHitbox" and canShoot:
		dirAttack = "up"
		playerOnSight = true

func _on_crossDetectorRight_area_entered(area):
	if area.name == "pjHitbox" and canShoot:
		dirAttack = "right"
		playerOnSight = true

func _on_crossDetectorLeft_area_exited(area):
	if area.name == "pjHitbox":
		playerOnSight = false
		
func _on_crossDetectorRight_area_exited(area):
	if area.name == "pjHitbox":
		playerOnSight = false

func _on_crossDetectorDown_area_exited(area):
	if area.name == "pjHitbox":
		playerOnSight = false

func _on_crossDetectorUp_area_exited(area):
	if area.name == "pjHitbox":
		playerOnSight = false

func _on_bouncerHitbox_area_entered(area):
	if "Attack" in area.name:
#		print(area.name)
		createExplosion()
		updatePlayerSouls(30)
		queue_free()
