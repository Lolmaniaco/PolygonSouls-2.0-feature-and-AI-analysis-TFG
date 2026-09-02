class_name BouncerArrow
extends Area2D

@export var bullet_speed: float = 10.0

var dirToShoot


func _physics_process(delta):
	position += dirToShoot * bullet_speed * delta


func setup(pos, rot, direction, new_speed, _typeOfProjectile):
	position = pos
	rotation += rot
	dirToShoot = direction
	bullet_speed = new_speed



func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		queue_free()
		return
	if not body is Player:
		return

	body.receive_damage(15)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("pjBullets"):
		area.queue_free()
		queue_free()
