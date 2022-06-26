extends "res://scenes/enemies/enemy.gd"

var tankedHits = 0
var dodgeHits = 1
var playerPos
var targetPos 
var waitTime = 0.5
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	playerPos = player.getPos()
	directionToPlayer = self.position.direction_to(playerPos)
	
	targetPos = player.getPos()
	rotation = targetPos.angle_to_point(position)
	
	if waitTime > 0:
		waitTime -= delta
	else:
		match(tankedHits):
			1: movement = directionToPlayer * speed * 2 * delta
			2: movement = directionToPlayer * speed * 3 * delta
			_: movement = directionToPlayer * speed * delta

		move_and_collide(movement)

func _on_kamikazeHitbox_area_entered(area):
	if "Attack" in area.name:
		tankedHits += 1;
		$Sprite.scale *= 1.4
		#$kamikazeHitbox/hitBox.scale *= 1.2
		
	if(tankedHits == 3):
		createExplosion()
		createExplosion()
		createExplosion()
		updatePlayerSouls(50)
		queue_free()

	if "pjHitbox" in area.name:
		speed = 0
		createExplosion()
		queue_free()
