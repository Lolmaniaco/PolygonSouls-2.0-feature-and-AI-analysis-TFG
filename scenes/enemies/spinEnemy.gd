extends "res://scenes/enemies/enemy.gd"

var arrow = preload("res://scenes/enemies/turretArrow.tscn")
onready var healthBar = $enemyBars
onready var spikesCenterPoint = $enemyCenterPos
export (int) var turnDegrees = 2 

var regenerating = false
var canRegenerate = true
var startRegenerating = false
var flee = false
var rPAP # received PAP
var EAPs = {'C':0,'R':0, 'M':0} # Enemy attack patterns
var accEAPs = {'C':0,'R':0, 'M':0} # Accumulated weight percentatges

var object_types = [{'attackType':'C', 'roll_weight':0, 'acc_weight':0},
{'attackType':'R', 'roll_weight':0, 'acc_weight':0},
{'attackType':'M', 'roll_weight':0, 'acc_weight':0}]
var accWeight = 0

var currentAttack = 'C'
var targetPos
var dirToShoot
var canShoot = true

var attackMultiplier = 1.0
var attackDamage = 30
var shields = 3
var healingTicTimer
var waitUntilStartHealing
var waitTime = 0.5
# Called when the node enters the scene tree for the first time.
func _ready():
	speed *= 0.7
	healingTicTimer = Timer.new()
	healingTicTimer.set_one_shot(true)
	healingTicTimer.set_wait_time(0.05)
	healingTicTimer.connect("timeout", self, "_on_healingTicTimer_timeout")
	add_child(healingTicTimer)
	
func _physics_process(delta):
	if waitTime > 0:
		waitTime -= delta
	else:
		if regenerating:
			movement = Vector2(0,0)
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
			directionToPlayer = self.position.direction_to(player.getPos())
			movement = directionToPlayer * speed * 2 * delta
			if healthBar.getHealth() < 50:
				directionToPlayer = -self.position.direction_to(player.getPos())
				if !flee:
					weakened()
				movement = directionToPlayer * speed * delta
		
		targetPos = player.getPos()
		$centerPosition.rotation = targetPos.angle_to_point(position)
		self.dirToShoot = position.direction_to(targetPos).normalized()

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
					shootProjectile(currentAttack)
			'M':
				turnDegrees = 2
				$meleeAttack.visible = false
				$rangedAttack.visible = false
				$magicAttack.visible = true
				if canShoot:
					canShoot = false
					shootProjectile(currentAttack)
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

func _on_hitbox_area_entered(area):
	# Damage received by enemies to player
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

		if hasProtection():
			healthBar.healthUpdate(-attackDamage*attackMultiplier)
	elif "rangedAttack" in area.name:
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
				
		if hasProtection():
			healthBar.healthUpdate(-attackDamage*attackMultiplier)
	elif "magicAttack" in area.name:
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
			healthBar.healthUpdate(-attackDamage*attackMultiplier)
			
	if healthBar.getHealth() <= 0:
		createExplosion()
		updatePlayerSouls(100)
		queue_free()
		
func hasProtection():
	shields -=1
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
	
func shootProjectile(currentAttack):
	match(currentAttack):
		'R':
			var rangedArrow = arrow.instance()
			get_parent().add_child(rangedArrow)
			rangedArrow.setup(position, $centerPosition.rotation_degrees, self.dirToShoot, 500, currentAttack)
		'M':
			var magicArrow = arrow.instance()
			get_parent().add_child(magicArrow)
			magicArrow.setup(position, $centerPosition.rotation_degrees, self.dirToShoot, 250, currentAttack)

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
		var newAttack = rand_range(0,1)
		if newAttack == 0:
			currentAttack = 'M'
		else:
			currentAttack = 'R'

func initProbabilities():
	var total_weight = 0.0
	
	for obj_type in object_types:
		total_weight += obj_type.roll_weight
		obj_type.acc_weight = total_weight

func pickObject():
	randomize()
	var roll: float = rand_range(0.0, 1.0)

	for obj_type in object_types:
		if (obj_type.acc_weight > roll):
			return obj_type.attackType

func _on_reloadTimer_timeout():
	canShoot = true

func _on_Area2D_area_exited(area):
	if "pjHitbox" in area.name and flee == true:
		regenerating = true

func _on_Area2D_area_entered(area):
	if "pjHitbox" in area.name:
		regenerating = false
		
func _on_healingTicTimer_timeout():
	canRegenerate = true
