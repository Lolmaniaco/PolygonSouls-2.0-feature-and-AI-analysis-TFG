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


func explode() -> void:
	Global.create_explosion(global_position)
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body is TileMapLayer:
		explode()
		return

	if not body is Enemy:
		return

	explode()
	body.take_hit()


func _on_area_entered(area: Area2D) -> void:
	if not area.name == "shieldHitBox":
		return

	explode()
