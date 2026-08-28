class_name Bouncer
extends Enemy

var arrow = preload("res://scenes/enemies/bouncerArrow.tscn")
var dirToShoot = Vector2(0, 1)
var canShoot = true
var playerOnSight = false
var dirAttack

var bounce = 1
var movement_direction: Vector2

@onready var ray_down: RayCast2D = $RayCastDown
@onready var ray_right: RayCast2D = $RayCastRight
@onready var ray_left: RayCast2D = $RayCastLeft
@onready var ray_up: RayCast2D = $RayCastUp
@onready var reload_timer: Timer = $reloadTimer


func _ready():
	_start_delay()
	speed = randi_range(200, 300)
	movement_direction = Vector2(randf(), randf()).normalized()


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(movement_direction * speed * delta)

	if collision:
		movement_direction = movement_direction.bounce(collision.get_normal()).normalized()

	if canShoot:
		dirToShoot = Vector2.ZERO
		var down_hit = ray_down.get_collider()
		var right_hit = ray_right.get_collider()
		var left_hit = ray_left.get_collider()
		var up_hit = ray_up.get_collider()

		if down_hit is Player:
			dirToShoot = Vector2.DOWN
		elif right_hit is Player:
			dirToShoot = Vector2.RIGHT
		elif left_hit is Player:
			dirToShoot = Vector2.LEFT
		elif up_hit is Player:
			dirToShoot = Vector2.UP

		if dirToShoot != Vector2.ZERO:
			canShoot = false
			reload_timer.start()
			shootProjectile()


func shootProjectile():
	var bullet: BouncerArrow = arrow.instantiate()
	add_sibling(bullet)

	match dirToShoot:
		Vector2.DOWN: bullet.setup(position, PI / 2, dirToShoot, 500, 'R')
		Vector2.RIGHT: bullet.setup(position, 0, dirToShoot, 500, 'R')
		Vector2.LEFT: bullet.setup(position, PI, dirToShoot, 500, 'R')
		Vector2.UP: bullet.setup(position, -PI / 2, dirToShoot, 500, 'R')


func take_hit():
	trigger_death()


func trigger_death():
	createExplosion()
	updatePlayerSouls(30)
	queue_free()


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


func _on_body_entered(body: Node) -> void:
	print("DETECTED")
	if not body.is_in_group("pjBullets"):
		return

	trigger_death()
