class_name TurretArrow
extends Area2D

@export var bullet_speed: float = 10.0

var dirToShoot
var explosion = preload("res://particles/fake_explosion_particles.tscn")
var notCollide = ["turret", "spinEnemy", "player", "bouncer", "finalBoss"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position += dirToShoot * bullet_speed * delta


func setup(pos, rot, direction, new_speed, typeOfProjectile):
	global_position = pos
	rotation += rot
	dirToShoot = direction
	bullet_speed = new_speed

	match(typeOfProjectile):
		'R':
			$ranged.visible = true
			$CollisionShape2D.disabled = false
		'M':
			$magic.visible = true
			$CollisionShape2D.disabled = false


func createExplosion():
	var newExp = explosion.instantiate()
	newExp.setup(position)
	get_parent().add_child(newExp)
	newExp.particles_explode = true


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	body.receive_damage(15)
	createExplosion()
	queue_free()
