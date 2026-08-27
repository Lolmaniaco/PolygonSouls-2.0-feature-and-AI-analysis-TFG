class_name Bouncer
extends Enemy

var arrow = preload("res://scenes/enemies/bouncerArrow.tscn")
var targetPos
var hitWall = false;
var collision
var dirToShoot = Vector2(0, 1)
var canShoot = true
var playerOnSight = false
var dirAttack
var waitTime = 0.5

var direction
var bounce = 1


func _ready():
	_start_delay()

	speed *= 0.04
	direction = randi_range(1, 2)


func _physics_process(_delta: float) -> void:
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


func shootProjectile():
#	print("shoot!")
	var bullet: BouncerArrow = arrow.instantiate()
	get_parent().add_child(bullet)

	if dirAttack == "left":
		bullet.setup(position, 180, dirToShoot, 500, 'R')
	elif dirAttack == "up":
		bullet.setup(position, -90, dirToShoot, 500, 'R')
	elif dirAttack == "right":
		bullet.setup(position, 0, dirToShoot, 500, 'R')
	elif dirAttack == "down":
		bullet.setup(position, 90, dirToShoot, 500, 'R')


func take_hit():
	trigger_death()


func trigger_death():
	createExplosion()
	updatePlayerSouls(30)
	queue_free()


func _on_Area2D_area_entered(_area):
	if collision:
		var result = collision.collider is TileMap
		if collision.collider is TileMap:
			speed = 100
		print("resultado: ", result)


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
		trigger_death()


func _on_bouncer_hitbox_body_entered(body: Node2D) -> void:
	if not body.is_in_group("pjBullets"):
		return

	trigger_death()
