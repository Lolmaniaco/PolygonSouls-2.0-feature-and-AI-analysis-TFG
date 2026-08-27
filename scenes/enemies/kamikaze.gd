class_name Kamikaze
extends Enemy

var tankedHits = 0


func _physics_process(delta: float) -> void:
	var playerPos = player.global_position
	directionToPlayer = global_position.direction_to(playerPos)
	rotation = global_position.angle_to_point(playerPos)

	match(tankedHits):
		1: movement = directionToPlayer * speed * 2 * delta
		2: movement = directionToPlayer * speed * 3 * delta
		_: movement = directionToPlayer * speed * delta

	move_and_collide(movement)


func _on_kamikazeHitbox_area_entered(area):
	if "Attack" in area.name:
		tankedHits += 1;
		$Sprite2D.scale *= 1.4
		#$kamikazeHitbox/hitBox.scale *= 1.2

	if tankedHits == 3:
		createExplosion()
		createExplosion()
		createExplosion()
		updatePlayerSouls(50)
		queue_free()

	if "pjHitbox" in area.name:
		speed = 0
		createExplosion()
		queue_free()
