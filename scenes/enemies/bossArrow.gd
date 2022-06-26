extends Node2D

var dirToShoot
export (float) var velocity = 10.0
var explosion = preload("res://particles/fake_explosion_particles.tscn")
var notCollide = ["turret", "spinEnemy", "player", "rift", "riftCollisionShape", "bouncer", "finalBoss"]

func _ready():
	pass # Replace with function body.

func setup(pos, rot, direction, velocity):
	position = pos
	rotation_degrees += rot
	self.dirToShoot = direction
	self.velocity = velocity

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += self.dirToShoot * self.velocity * delta
	rotation_degrees += 4
	
func createExplosion():
	var newExp =  explosion.instance()
	newExp.setup(position)
	get_parent().add_child(newExp)
	newExp.particles_explode = true
	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_bossArrowHitbox_body_entered(body):
	var explosion = true
#	print(body.name)
	for obj in notCollide:
		if obj in body.name:
			explosion = false

	if explosion:
		createExplosion()
		queue_free()

func _on_bossArrowHitbox_area_entered(area):
	if area.name == "pjHitbox":
		createExplosion()
		queue_free()
