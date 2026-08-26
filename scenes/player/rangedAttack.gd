extends Node2D

#EXPORTS
@export var speed: float = 10.0

var facingDirection
var speedSide


func _physics_process(_delta):
	position += facingDirection * speed


func setup(pos, rot, dir):
	position = pos
	rotation_degrees += rot
	facingDirection = dir


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
