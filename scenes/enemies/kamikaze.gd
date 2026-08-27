class_name Kamikaze
extends Enemy

const POWER: int = 47

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


func trigger_death():
	createExplosion()
	createExplosion()
	createExplosion()
	updatePlayerSouls(50)
	queue_free()


func take_hit():
	tankedHits += 1;
	$Sprite2D.scale *= 1.4

	if tankedHits == 3:
		trigger_death()


func _on_body_entered(body: Node) -> void:
	if body is Player:
		createExplosion()
		body.receive_damage(POWER)
		queue_free()
