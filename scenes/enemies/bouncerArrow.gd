extends Node2D

var dirToShoot
export (float) var velocity = 10.0
var explosion = preload("res://particles/fake_explosion_particles.tscn")
var notCollide = ["turret", "spinEnemy", "player", "bouncer", "finalBoss"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(pos, rot, direction, velocity, typeOfProjectile):
	position = pos
	rotation_degrees += rot
	self.dirToShoot = direction
	self.velocity = velocity

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += self.dirToShoot * self.velocity * delta
	
func createExplosion():
	var newExp =  explosion.instance()
	newExp.setup(position)
	get_parent().add_child(newExp)
	newExp.particles_explode = true

func _on_hitbox_body_entered(body):
	var explosion = true
#	print(body.name)
	for obj in notCollide:
		if obj in body.name:
			explosion = false

	if explosion:
		createExplosion()
		queue_free()
		
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_hitbox_area_entered(area):
	if area.name == "pjHitbox":
		createExplosion()
		queue_free()
	elif area.name == "magicAttack" or area.name == "rangedAttack" or area.name == "nearAttack":
		createExplosion()
		queue_free()
