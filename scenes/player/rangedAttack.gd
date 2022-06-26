extends Node2D

#EXPORTS
export (float) var speed = 10.0
var facingDirection
var speedSide

func setup(pos, rot, dir):
	self.position = pos
	self.rotation_degrees += rot
	self.facingDirection = dir

func _physics_process(delta):
	position += facingDirection * speed

func _on_destroyTimer_timeout():
	queue_free()
	pass

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass

func _on_rangedAttack_area_entered(area):
	if area.name == "kamikazeHitbox" or area.name == "shieldHitBox" or area.name == "bouncerArrow" or area.name == "protectiveAura" or area.name == "blockBody":
		queue_free()
	pass
