extends Area2D

#EXPORTS
@export var speed: float = 10.0

var facingDirection
var speedSide
var destroyProjective = false
var fadeOutDeath = 1


func _physics_process(delta):
	position += facingDirection * speed

	if destroyProjective:
		fadeOutDeath -= delta
		if fadeOutDeath <= 0:
			queue_free()


func setup(pos, rot, dir):
	position = pos
	rotation_degrees += rot
	facingDirection = dir


func _on_destroyTimer_timeout():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_magicAttack_area_entered(area):
	if area.name == "kamikazeHitbox" or area.name == "shieldHitBox" or area.name == "bouncerArrow" or area.name == "protectiveAura" or area.name == "blockBody":
		queue_free()


func _on_lifespanTimer_timeout():
	$CollisionShape2D.disabled = true
	$Sprite2D.visible = false
	$GPUParticles2D.emitting = false
	destroyProjective = true


func _on_body_entered(body: Node) -> void:
	if body is TileMapLayer:
		queue_free()
	elif body is Enemy:
		body.take_hit()
		queue_free()
