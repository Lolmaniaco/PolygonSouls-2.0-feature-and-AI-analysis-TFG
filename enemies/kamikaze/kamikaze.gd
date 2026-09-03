class_name Kamikaze
extends Enemy

const POWER: int = 47
const ROTATION_SPEED := 10.0

var tankedHits = 0

@onready var col_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

@onready var sfx: AudioStreamPlayer = $SFX


func _ready() -> void:
	rotation_degrees = randf_range(0, 360)
	set_physics_process(false)
	await rotate_to_player()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	var movement: Vector2
	var directionToPlayer = global_position.direction_to(Global.player.global_position)
	look_at(Global.player.global_position)

	match(tankedHits):
		1: movement = directionToPlayer * speed * 2.5 * delta
		2: movement = directionToPlayer * speed * 3.5 * delta
		_: movement = directionToPlayer * speed * 2 * delta

	move_and_collide(movement)


func rotate_to_player() -> void:
	while true:
		var direction := global_position.direction_to(Global.player.global_position)
		var target_angle := direction.angle()

		rotation = rotate_toward(
			rotation,
			target_angle,
			ROTATION_SPEED * get_process_delta_time()
		)

		if is_equal_approx(rotation, target_angle):
			rotation = target_angle
			break

		await get_tree().process_frame


func trigger_death(get_souls: bool):
	if get_souls:
		updatePlayerSouls(50)
	
	call_deferred("set_collision_layer_value", 1, 0)
	call_deferred("set_collision_layer_value", 2, 0)
	call_deferred("set_visible", false)
	Global.create_nuclear_explosion(global_position)
	sfx.play()
	await sfx.finished
	queue_free()


func take_hit():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", sprite.scale * 1.4, 0.2)
	col_shape.scale *= 1.2

	tankedHits += 1;
	if tankedHits == 3:
		trigger_death(true)


func _on_body_entered(body: Node) -> void:
	if not body is Player:
		return

	body.receive_damage(POWER)
	trigger_death(false)
