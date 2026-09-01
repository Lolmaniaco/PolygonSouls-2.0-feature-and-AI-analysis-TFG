class_name BossProjectile
extends Node2D

@export var bullet_speed: float = 10.0

var dirToShoot
var explosion = preload("res://particles/fake_explosion_particles.tscn")
var notCollide = ["turret", "spinEnemy", "player", "rift", "riftCollisionShape", "bouncer", "finalBoss"]
var rotating_speed: float


func _ready() -> void:
	rotating_speed = randi_range(250, 750)


func _physics_process(delta):
	position += dirToShoot * bullet_speed * delta
	rotation_degrees += rotating_speed * delta


func setup(pos, direction, new_speed):
	position = pos
	dirToShoot = direction
	bullet_speed = new_speed


func createExplosion():
	var newExp = explosion.instantiate()
	newExp.setup(position)
	get_parent().add_child(newExp)
	newExp.particles_explode = true


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_bossArrowHitbox_body_entered(body):
	var explode = true
	for obj in notCollide:
		if obj in body.name:
			explode = false

	if explode:
		createExplosion()
		queue_free()


func _on_bossArrowHitbox_area_entered(area):
	if area.name == "pjHitbox":
		createExplosion()
		queue_free()
