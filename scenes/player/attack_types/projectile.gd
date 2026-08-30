class_name Projectile
extends Area2D

@export var speed: float = 600.0

var facingDirection


func _physics_process(delta):
	position += facingDirection * speed * delta


func setup(pos, rot, dir):
	position = pos
	rotation_degrees += rot
	facingDirection = dir


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body is TileMapLayer:
		queue_free()
		return
	if not body is Enemy:
		return

	body.take_hit()
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.name == "shieldHitBox":
		queue_free()
