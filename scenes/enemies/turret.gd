extends "res://scenes/enemies/enemy.gd"

var turretArrow = preload("res://scenes/enemies/turretArrow.tscn")
export (int) var chargeSpeed = 80
var targetPos
var actualPlayerPos
var actualPlayerPosSector
var rotationSector
var dirToShoot
# Called when th node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	targetPos = player.getPos()
	chargeUpdate(chargeSpeed*delta)
	actualPlayerPos = +targetPos.angle_to_point(position)
	
	actualPlayerPosSector = int(abs(actualPlayerPos*0.967741935483871)+3)%6
	rotationSector = int(abs(rotation*0.967741935483871)+3)%6
	
	if $chargeMeter.value == $chargeMeter.max_value:
		if rotation > actualPlayerPos:
			rotation -= 0.1
		else:
			rotation += 0.1

		if stepify(rotation, 0.1) == stepify(actualPlayerPos, 0.1):
			var aux = int(rotation) / 3
			if aux != 0:
				rotation -= 6*aux
			self.dirToShoot = position.direction_to(targetPos)
			shootProjectile()
			#print("Se acaba de disparar")

func chargeUpdate(chargePoints):
	$chargeMeter.value += chargePoints
	
func shootProjectile():
#	print("shoot!")
	$chargeMeter.value = 0
	var bullet = turretArrow.instance()
	get_parent().add_child(bullet)
	bullet.setup(position, rotation_degrees, self.dirToShoot, 700, 'R')

func _on_enemyHitbox_area_entered(area):
#	print(area.name)
	if "Attack" in area.name:
#		print(area.name)
		createExplosion()
		updatePlayerSouls(30)
		queue_free()

func _on_shieldHitBox_area_entered(area):
	pass # Replace with function body.
