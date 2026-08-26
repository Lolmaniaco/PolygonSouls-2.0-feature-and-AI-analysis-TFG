extends Node2D

@export var bullet_speed: float = 10.0

var dirToShoot
var explosion = preload("res://particles/fake_explosion_particles.tscn")
var notCollide = ["turret", "spinEnemy", "player", "bouncer", "finalBoss"]


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += dirToShoot * bullet_speed * delta


func setup(pos, rot, direction, new_speed, typeOfProjectile):
	position = pos
	rotation_degrees += rot
	dirToShoot = direction
	bullet_speed = new_speed

	match(typeOfProjectile):
		'R':
			$ranged.visible = true
			$turretArrow/CollisionShape2D.disabled = false
		'M':
			$magic.visible = true
			$magicHitbox/CollisionShape2D.disabled = false


func createExplosion():
	var newExp = explosion.instantiate()
	newExp.setup(position)
	get_parent().add_child(newExp)
	newExp.particles_explode = true


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_hitbox_body_entered(body):
	var explode = true
#	print(body.name)
	for obj in notCollide:
		if obj in body.name:
			explode = false

	if explode:
		createExplosion()
		queue_free()


func _on_hitbox_area_entered(area):
	if area.name == "pjHitbox":
		createExplosion()
		queue_free()
