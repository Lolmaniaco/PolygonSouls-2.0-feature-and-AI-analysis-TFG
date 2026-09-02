class_name Turret
extends Enemy

const TURRET_PROJECTILE = preload("uid://dnyctorhi3ttb")

@export var chargeSpeed: int = 80
@export var rotation_speed: float = 2.0 # radianes por segundo

var dirToShoot

@onready var sfx: AudioStreamPlayer = $sfx


func _ready() -> void:
	player = $"../../../../player"
	UI = $"../../../../player/UI"
func _run() -> void:
	pass

func _physics_process(delta: float) -> void:
	chargeUpdate(chargeSpeed * delta)
	var angle_to_player = get_angle_to(player.global_position)

	rotation = rotate_toward(
		rotation,
		rotation + angle_to_player,
		rotation_speed * delta
	)

	if $chargeMeter.value == $chargeMeter.max_value:
		dirToShoot = global_position.direction_to(player.global_position)
		sfx.play()
		shootProjectile()


func chargeUpdate(chargePoints):
	$chargeMeter.value += chargePoints


func take_hit():
	trigger_death(true)


func trigger_death(get_souls: bool):
	if get_souls:
		updatePlayerSouls(30)
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


func _on_shield_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("pjBullets"):
		area.queue_free()
