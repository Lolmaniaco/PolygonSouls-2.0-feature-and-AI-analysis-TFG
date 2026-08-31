class_name EnemyProjectile
extends Area2D

@export var bullet_speed: float = 10.0

var dirToShoot
var explosion = preload("res://particles/fake_explosion_particles.tscn")


func _physics_process(delta):
	global_position += dirToShoot * bullet_speed * delta


func setup(pos, rot, direction, new_speed):
	global_position = pos
	rotation += rot
	dirToShoot = direction
	bullet_speed = new_speed


func createExplosion():
	var newExp = explosion.instantiate()
	newExp.setup(position)
	get_parent().add_child(newExp)
	newExp.particles_explode = true


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		queue_free()
		return
	elif not body is Player:
		return

	body.receive_damage(15)
	createExplosion()
	queue_free()
