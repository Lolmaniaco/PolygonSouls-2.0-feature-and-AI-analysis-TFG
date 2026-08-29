class_name Turret
extends Enemy

@export var chargeSpeed: int = 80

var turretArrow = preload("res://scenes/enemies/turretArrow.tscn")
var dirToShoot


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
	var bullet: TurretArrow = turretArrow.instantiate()
	add_sibling(bullet)
	bullet.setup(global_position, rotation, dirToShoot, 700, 'R')


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("pjBullets"):
		return

	trigger_death()


func _on_shield_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("pjBullets"):
		area.queue_free()
