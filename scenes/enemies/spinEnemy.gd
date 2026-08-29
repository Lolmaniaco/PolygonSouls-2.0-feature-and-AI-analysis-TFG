class_name SpinEnemy
extends Enemy

@export var turnDegrees: int = 2

var arrow = preload("res://scenes/enemies/turretArrow.tscn")

var regenerating = false
var canRegenerate = true
var startRegenerating = false
var flee = false
var rPAP # received PAP
var EAPs = { 'C': 0, 'R': 0, 'M': 0 } # Enemy attack patterns
var accEAPs = { 'C': 0, 'R': 0, 'M': 0 } # Accumulated weight percentatges

var object_types = [
	{ 'attackType': 'C', 'roll_weight': 0, 'acc_weight': 0 } ,
	{ 'attackType': 'R', 'roll_weight': 0, 'acc_weight': 0 } ,
	{ 'attackType': 'M', 'roll_weight': 0, 'acc_weight': 0 }]
var accWeight = 0

var currentAttack = 'C'
var dirToShoot
var canShoot = true

var attackMultiplier = 1.0
var attackDamage = 30
var shields = 3
var healingTicTimer
var waitUntilStartHealing

@onready var healthBar = $enemyBars
@onready var spikesCenterPoint = $enemyCenterPos


# Called when the node enters the scene tree for the first time.
func _ready():
	_start_delay()

	speed *= 0.7
	healingTicTimer = Timer.new()
	healingTicTimer.set_one_shot(true)
	healingTicTimer.set_wait_time(0.05)
	healingTicTimer.connect("timeout", Callable(self, "_on_healingTicTimer_timeout"))
	add_child(healingTicTimer)


func _physics_process(delta):
	var movement
	if regenerating:
		movement = Vector2(0, 0)
		canShoot = false
		$healingActivated.emitting = true

		if waitUntilStartHealing > 0:
			waitUntilStartHealing -= delta
		else:
			if canRegenerate:
				healthBar.healthUpdate(0.5)
				canRegenerate = false
				healingTicTimer.start()

			if healthBar.getHealth() == 100:
				regenerating = false
			elif healthBar.getHealth() > 50:
				if flee:
					flee = false
					regenerated()
	else:
		waitUntilStartHealing = 1
		$healingActivated.emitting = false
		var directionToPlayer = global_position.direction_to(player.global_position)
		movement = directionToPlayer * speed * 2 * delta
		if healthBar.getHealth() < 50:
			directionToPlayer = -global_position.direction_to(player.global_position)
			if !flee:
				weakened()
			movement = directionToPlayer * speed * delta

	dirToShoot = global_position.direction_to(player.global_position).normalized()

	# Attack patterns
	match(currentAttack):
		'C':
			turnDegrees = 6
			$meleeAttack.visible = true
			$rangedAttack.visible = false
			$magicAttack.visible = false
		'R':
			turnDegrees = 2
			$meleeAttack.visible = false
			$rangedAttack.visible = true
			$magicAttack.visible = false
			if canShoot:
				canShoot = false
				shootProjectile()
		'M':
			turnDegrees = 2
			$meleeAttack.visible = false
			$rangedAttack.visible = false
			$magicAttack.visible = true
			if canShoot:
				canShoot = false
				shootProjectile()
			pass

	spikesCenterPoint.rotation_degrees += turnDegrees
	move_and_collide(movement)


func regenerated():
	$AnimationPlayer.play("regenerated")
	$reloadTimer.weakenedEnemy()
	flee = false


func weakened():
	$AnimationPlayer.play("weakened")
	$reloadTimer.weakenedEnemy()
	flee = true


func lostShield():
	$AnimationPlayer.play("shieldLess")


func hasProtection():
	shields -= 1
	if shields == 2:
		$enemyCenterPos/spike.queue_free()
	elif shields == 1:
		$enemyCenterPos/spike2.queue_free()
	elif shields == 0:
		$enemyCenterPos/spike3.queue_free()
		lostShield()
	else:
		return true
	return false


func shootProjectile():
	var projectile: TurretArrow = arrow.instantiate()
	add_sibling(projectile)
	projectile.setup(global_position, global_position.angle_to_point(player.global_position),
		dirToShoot, 500 if currentAttack == 'R' else 250, currentAttack)


func initProbabilities():
	var total_weight = 0.0

	for obj_type in object_types:
		total_weight += obj_type.roll_weight
		obj_type.acc_weight = total_weight


func pickObject():
	randomize()
	var roll: float = randf()

	for obj_type in object_types:
		if obj_type.acc_weight > roll:
			return obj_type.attackType


func trigger_death():
	createExplosion()
	updatePlayerSouls(100)
	queue_free()


func _on_hitbox_area_entered(area):
	if not area.is_in_group("pjBullets") and not area.name == "nearAttack":
		return

	if "nearAttack" in area.name:
		match(currentAttack):
			# Close Combat: C
			'C':
				# Draw vs C
				attackMultiplier = 1
			# Ranged Combat: R
			'R':
				# Wins vs R
				attackMultiplier = 1.5
			# Magic Combat: M
			'M':
				# Lose vs M
				attackMultiplier = 0.5

	elif area is RangedProjectile:
		match(currentAttack):
			# Close Combat: C
			'C':
				# Lose vs C
				attackMultiplier = 0.5
			# Ranged Combat: R
			'R':
				# Draw vs R
				attackMultiplier = 1.0
			# Magic Combat: M
			'M':
				# Wins vs M
				attackMultiplier = 1.5

	elif area is MagicProjectile:
		match(currentAttack):
			# Close Combat: C
			'C':
				# Wins vs C
				attackMultiplier = 1.5
			# Ranged Combat: R
			'R':
				# Lose vs R
				attackMultiplier = 0.5
			# Magic Combat: M
			'M':
				# Draw vs M
				attackMultiplier = 1

	if hasProtection():
		healthBar.healthUpdate(-attackDamage * attackMultiplier)

	if healthBar.getHealth() <= 0:
		trigger_death()


func _on_processEAP_timeout():
	rPAP = player.getPAP()

	for obj_type in object_types:
		match(obj_type.attackType):
			'C':
				obj_type.roll_weight = rPAP['R']
			'R':
				obj_type.roll_weight = rPAP['M']
			'M':
				obj_type.roll_weight = rPAP['C']
	initProbabilities()
	currentAttack = pickObject()

	if shields <= 0:
		randomize()
		var newAttack = randf_range(0, 1)
		if newAttack == 0:
			currentAttack = 'M'
		else:
			currentAttack = 'R'


func _on_reloadTimer_timeout():
	canShoot = true


func _on_healingTicTimer_timeout():
	canRegenerate = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		regenerating = false


func _on_area_2d_body_exited(body: Node2D) -> void:
	if flee and body is Player:
		regenerating = true
