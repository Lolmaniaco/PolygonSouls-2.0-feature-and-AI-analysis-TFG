class_name Turret
extends Enemy

@export var chargeSpeed: int = 80

var turretArrow = preload("res://scenes/enemies/turretArrow.tscn")
var targetPos
var currentPlayerPos
var currentPlayerPosSector
var rotationSector
var dirToShoot


func _physics_process(delta: float) -> void:
	chargeUpdate(chargeSpeed * delta)
	look_at(player.global_position)

	if $chargeMeter.value == $chargeMeter.max_value:
		dirToShoot = global_position.direction_to(player.global_position)
		shootProjectile()


func chargeUpdate(chargePoints):
	$chargeMeter.value += chargePoints


func shootProjectile():
#	print("shoot!")
	$chargeMeter.value = 0
	var bullet: TurretArrow = turretArrow.instantiate()
	add_sibling(bullet)
	bullet.setup(global_position, rotation_degrees, dirToShoot, 700, 'R')


func _on_enemyHitbox_area_entered(area):
#	print(area.name)
	if "Attack" in area.name:
#		print(area.name)
		createExplosion()
		updatePlayerSouls(30)
		queue_free()


func _on_shieldHitBox_area_entered(area):
	pass # Replace with function body.
