extends Node2D

#EXPORTS
@export var speed: float = 10.0
var facingDirection
var speedSide
var destroyProjective = false
var fadeOutDeath = 1

func setup(pos, rot, dir):
	position = pos
	rotation_degrees += rot
	facingDirection = dir

func _physics_process(delta):
	position += facingDirection * speed
	
	if destroyProjective:
		fadeOutDeath -= delta
		if fadeOutDeath <= 0:
			queue_free()

func _on_destroyTimer_timeout():
	queue_free()
	pass

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass
	
func _on_magicAttack_area_entered(area):
	if area.name == "kamikazeHitbox" or area.name == "shieldHitBox" or area.name == "bouncerArrow" or area.name == "protectiveAura" or area.name == "blockBody":
		queue_free()
	pass 


func _on_lifespanTimer_timeout():
	$magicAttack/CollisionShape3D.disabled = true
	$Sprite2D.visible = false
	$GPUParticles2D.emitting = false
	destroyProjective = true
