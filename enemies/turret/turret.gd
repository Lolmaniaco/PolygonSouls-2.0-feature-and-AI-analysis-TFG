class_name Turret
extends Enemy

const TURRET_PROJECTILE = preload("uid://dnyctorhi3ttb")

@export var chargeSpeed: int = 80

var dirToShoot


func _ready() -> void:
	player = $"../../../../player"


func _physics_process(delta: float) -> void:
	chargeUpdate(chargeSpeed * delta)
	look_at(player.global_position)

	if $chargeMeter.value == $chargeMeter.max_value:
		dirToShoot = global_position.direction_to(player.global_position)
		shootProjectile()


func chargeUpdate(chargePoints):
	$chargeMeter.value += chargePoints


func take_hit():
	trigger_death()


func trigger_death():
	createExplosion()
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

	trigger_death()


func _on_shield_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("pjBullets"):
		area.queue_free()
