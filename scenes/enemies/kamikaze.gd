class_name Kamikaze
extends Enemy

const POWER: int = 47

var tankedHits = 0

@onready var col_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	directionToPlayer = global_position.direction_to(player.global_position)
	rotation = global_position.angle_to_point(player.global_position)

	match(tankedHits):
		1: movement = directionToPlayer * speed * 2.5 * delta
		2: movement = directionToPlayer * speed * 3.5 * delta
		_: movement = directionToPlayer * speed * 2 * delta

	move_and_collide(movement)


func trigger_death():
	createExplosion()
	createExplosion()
	createExplosion()
	updatePlayerSouls(50)
	queue_free()


func take_hit():
	tankedHits += 1;
	sprite.scale *= 1.4
	col_shape.scale *= 1.2

	if tankedHits == 3:
		trigger_death()


func _on_body_entered(body: Node) -> void:
	print("Body: ", body.name)
	if body is Player:
		createExplosion()
		body.receive_damage(POWER)
		queue_free()
