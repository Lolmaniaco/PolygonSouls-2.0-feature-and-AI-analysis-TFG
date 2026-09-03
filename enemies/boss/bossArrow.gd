class_name BossProjectile
extends Node2D

@export var bullet_speed: float = 10.0

var dirToShoot
var rotating_speed: float


func _ready() -> void:
	rotating_speed = randi_range(250, 750)


func _physics_process(delta):
	position += dirToShoot * bullet_speed * delta
	rotation_degrees += rotating_speed * delta


func setup(pos, direction, new_speed):
	position = pos
	dirToShoot = direction
	bullet_speed = new_speed


func explode() -> void:
	Global.create_explosion(global_position)
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	explode()


func _on_bossArrowHitbox_body_entered(body):
	if not body is TileMapLayer:
		return

	explode()


func _on_bossArrowHitbox_area_entered(area):
	if area.name == "pjHitbox":
		explode()


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	body.receive_damage(15)
	queue_free()
