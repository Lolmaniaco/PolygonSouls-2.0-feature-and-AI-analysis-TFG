class_name Turret
extends Enemy

const TURRET_PROJECTILE = preload("uid://dnyctorhi3ttb")
const TURRET_BREAK = preload("uid://bxbae0q3uj1v1")
const BROKEN_TURRET = preload("uid://dtu8g5eed28ag")

@export var chargeSpeed: int = 80
@export var rotation_speed: float = 1.5

var dirToShoot

@onready var sfx: AudioStreamPlayer = $sfx
@onready var charge_meter: TextureProgressBar = $chargeMeter

@onready var shield_hit_box: Area2D = $shieldHitBox


func _ready() -> void:
	rotation_degrees = randf_range(0, 360)


func _physics_process(delta: float) -> void:
	chargeUpdate(chargeSpeed * delta)
	var angle_to_player = get_angle_to(Global.player.global_position)

	rotation = rotate_toward(
		rotation,
		rotation + angle_to_player,
		rotation_speed * delta
	)

	if charge_meter.value == charge_meter.max_value:
		if abs(angle_to_player) < 0.2:
			dirToShoot = global_position.direction_to(Global.player.global_position)
			sfx.play()
			shootProjectile()


func chargeUpdate(chargePoints):
	charge_meter.value += chargePoints


func take_hit():
	trigger_death(true)


func trigger_death(get_souls: bool):
	set_physics_process(false)
	call_deferred("set_collision_layer_value", 1, 0)
	call_deferred("set_collision_layer_value", 2, 0)
	shield_hit_box.call_deferred("set_collision_layer_value", 1, 0)
	shield_hit_box.call_deferred("set_collision_layer_value", 2, 0)
	if get_souls:
		updatePlayerSouls(30)

	sfx.stream = TURRET_BREAK
	sfx.play()

	visible = false
	Global.create_explosion(global_position)

	var new_broken = BROKEN_TURRET.instantiate()
	new_broken.position = position
	get_parent().get_parent().add_child(new_broken)

	await sfx.finished
	queue_free()


func shootProjectile():
	$chargeMeter.value = 0
	var bullet: EnemyProjectile = TURRET_PROJECTILE.instantiate()
	add_sibling(bullet)
	bullet.setup(global_position, rotation, dirToShoot, 700)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("pjBullets"):
		return

	trigger_death(true)
