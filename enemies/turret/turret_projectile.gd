class_name EnemyProjectile
extends Area2D

@export var bullet_speed: float = 10.0

var dirToShoot


func _physics_process(delta):
	global_position += dirToShoot * bullet_speed * delta


func setup(pos, rot, direction, new_speed):
	global_position = pos
	rotation += rot
	dirToShoot = direction
	bullet_speed = new_speed


func explode() -> void:
	Global.create_explosion(global_position)
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	explode()


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		explode()
		return

	if not body is Player:
		return

	body.receive_damage(15)
	explode()
