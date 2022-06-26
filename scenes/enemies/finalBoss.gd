extends "res://scenes/enemies/enemy.gd"

var arrow = preload("res://scenes/enemies/bossArrow.tscn")

var kamikaze = preload("res://scenes/enemies/kamikaze.tscn")
var turret = preload("res://scenes/enemies/turret.tscn")
var spinEnemy = preload("res://scenes/enemies/spinEnemy.tscn")
var bouncer = preload("res://scenes/enemies/bouncer.tscn")

var baseEnemies = [kamikaze, turret, bouncer]
var hardEnemies = [kamikaze, turret, spinEnemy, bouncer]

onready var healthPoints = $stateBody/healthPoints
var currentHealth
var maxHealth = 10
var active = false

var collidedWithWall = false
var initialAttackFinished = false
var fleeFromPlayer = false
var proyectilesRecibidos = 0
var phase = 0
var tempPos
var wallMovement = 1
var collided = false
var t = Timer.new()
var canAttack = false
var delay = 1.2

var havePlayerPosition = false
var playerPosition
var haveToFadeOut = true
var haveToFadeIn = false
var posibleSpawns
var shieldHealth = 4
var notEnoughDamage = true

var waitRiftAppear = 0.5
var delayPhaseThree = 3
var setPositionPhaseThree = false
var hasDoneTheExplosion = false
var hardEnemy = true
var hasAppeared = false
var bounce = 1
var collision
var concentratedAttackCounter = 2

func setup(pos):
	self.position = pos
	
func _ready():	
	movement = Vector2.LEFT * 6
	currentHealth = maxHealth
	speed *= 3
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	
	$AnimationPlayer.play("talking")
	t.start()
	yield(t, "timeout")
	$bossDialogs.set_bbcode("[center] BIENVENIDO, PALADIN DE LA LUZ")
	
	t.set_wait_time(2)
	t.start()
	yield(t, "timeout")
	$bossDialogs.set_bbcode("[center] ESTA SERA TU TUMBA DENTRO DE MUY POCO")
	
	t.set_wait_time(2)
	t.start()
	yield(t, "timeout")
	$bossDialogs.visible = false
	$AnimationPlayer.stop(true)

func _physics_process(delta):
	if active:
		$protectiveAura/CollisionShape2D.disabled = true
		$protectiveAura/Sprite.visible = false
		
		if global_position.y > 6900:
			$bossDialogs.rect_position.y = -115
		else:
			$bossDialogs.rect_position.y = 75
		if phase == 0:
			$blockBody/blockBodyHitbox.shape.radius = 11.855
			$blockBody/blockBodyHitbox.shape.height = 8.4
			tripleAroundAttack()
			phase += 1

		elif phase == 1 and initialAttackFinished:
			if delay <= 0:
				$AnimationPlayer.play("chargedShoot")
			else:
				delay -= delta

			if canAttack:
				canAttack = false
				shootFocusedToPlayerProjectile()
			if move_and_collide(movement) != null:
				wallMovement += 1
				if wallMovement == 5:
					wallMovement = 1

				if currentHealth == 10:
					if wallMovement == 1:
						global_position.y -= 10
						movement = Vector2.LEFT * speed * 1.35 * delta
					elif wallMovement == 2:
						global_position.x += 10
						movement = Vector2.UP * speed * 1.35 * delta
					elif wallMovement == 3:
						global_position.y += 10
						movement = Vector2.RIGHT * speed * 1.35 * delta
					elif wallMovement == 4:
						global_position.x -= 10
						movement = Vector2.DOWN * speed * 1.35 * delta
				elif currentHealth == 9:
					if wallMovement == 1:
						global_position.y += 10
						movement = Vector2.LEFT * speed * 1.35 * delta
					elif wallMovement == 2:
						global_position.x += 10
						movement = Vector2.DOWN * speed * 1.35 * delta
					elif wallMovement == 3:
						global_position.y -= 10
						movement = Vector2.RIGHT * speed * 1.35 * delta
					elif wallMovement == 4:
						global_position.x -= 10
						movement = Vector2.UP * speed * 1.35 * delta
				else:
					$stateBody/bossSkullShield.self_modulate = "#ff0000"
					$stateBody/bossMouthShield.self_modulate = "#ff0000"
					$blockBody/blockBodyHitbox.disabled = true
					phase = 2
		elif phase == 2:
			if haveToFadeIn:
				haveToFadeIn = false
				playerPosition = player.global_position
				posibleSpawns = [Vector2(10541.25, 6615), Vector2(10963.75, 6615), Vector2(10541.25,6835), Vector2(10963.75, 6835)]
				var posibleSpawnsNames = [1,2,3,4]
				if playerPosition.x > 10752.5:
					if playerPosition.y > 6725:
						posibleSpawns.erase(Vector2(10963.75, 6835))
						posibleSpawnsNames.erase(4)
					else:
						posibleSpawns.erase(Vector2(10963.75, 6615))
						posibleSpawnsNames.erase(2)
				else:
					if playerPosition.y > 6725:
						posibleSpawns.erase(Vector2(10541.25, 6835))
						posibleSpawnsNames.erase(3)
					else:
						posibleSpawns.erase(Vector2(10541.25, 6615))
						posibleSpawnsNames.erase(1)
				global_position = posibleSpawns[randi() % posibleSpawns.size()]

				$AnimationPlayer.play("fadeIn")
				$fadeInTimer.start()
				tripleAroundAttack()

			if currentHealth <= 3:
				phase = 3
				haveToFadeOut = false
				$stateBody.visible = false
				
			if haveToFadeOut:
				haveToFadeOut = false
				$AnimationPlayer.play("fadeOut")
				$fadeOutTimer.start()
				
		elif phase == 3:
			if !hasDoneTheExplosion:
				hasDoneTheExplosion = true
				$rift/riftCollisionShape.disabled = false
				$rift/riftCollisionShape.visible = true
				$rift/riftCollisionShape/Explosion1.emitting = true
				$rift/riftCollisionShape/Explosion2.emitting = true
				$rift/riftCollisionShape/Explosion3.emitting = true
				$rift/riftCollisionShape/Explosion4.emitting = true
				$rift/riftCollisionShape/smokeExplosion1.emitting = true
				$rift/riftCollisionShape/smokeExplosion2.emitting = true
				$rift/riftCollisionShape/smokeExplosion3.emitting = true
				$rift/riftCollisionShape/smokeExplosion4.emitting = true
				$stateBody/bossMouthShield.visible = false
				$stateBody/bossSkullShield.visible = false
				$blockBody/blockBodyHitbox.shape.radius = 5.796
				$blockBody/blockBodyHitbox.shape.height = 19.973
				
			if player.global_position.x > 10751.5:
				if !setPositionPhaseThree:
					setPositionPhaseThree = true
					global_position.x = 10350
					global_position.y = 6724.5
					$rift/riftSprite.flip_h = false
					$rift/riftCollisionShape.position.x = 358

				if $rift/riftCollisionShape.position.x != 422:
					$rift/riftCollisionShape.position.x += 1
			else:
				if !setPositionPhaseThree:
					setPositionPhaseThree = true
					global_position.x = 11153
					global_position.y = 6724.5
					$rift/riftSprite.flip_h = true
					$rift/riftCollisionShape.position.x = -358
				
				if $rift/riftCollisionShape.position.x != -422:
					$rift/riftCollisionShape.position.x -= 1
						
			if waitRiftAppear <= 0:
				$rift/riftSprite.visible = true
				delayPhaseThree -= delta
			else:
				waitRiftAppear -= delta
				
			if delayPhaseThree <= 0:
				delayPhaseThree = 0
				
				if hasAppeared == false:
					print("playing animation")
					hasAppeared = true
					$stateBody.visible = true
					$AnimationPlayer.play("fadeIn")
				
				if bounce % 2 == 0:
					collision = move_and_collide(Vector2.UP * speed * delta)
				else:
					collision = move_and_collide(Vector2.DOWN * speed * delta)
				if collision != null:
					bounce += 1
					
				if currentHealth <= 2:
					if $shieldTimer.is_stopped():
						$shieldTimer.start()
				
				if $attackTimer.is_stopped():
					$attackTimer.start()
					
				if canAttack:
					canAttack = false
					concentratedAttackCounter += 1
					shootFocusedToPlayerProjectile()
					if concentratedAttackCounter == 3:
						shootAroundProjectiles()
						concentratedAttackCounter = 0
		else:
			pass

func spawnEnemies():
	var enemyObj
	
	if hardEnemy:
		enemyObj = hardEnemies[randi()%4].instance()
		hardEnemy = false
	else:
		enemyObj = baseEnemies[randi()%3].instance()
		hardEnemy = true
		
	add_child(enemyObj)
	var xMinMaxRoom = [10340, 10741]
	var yMinMaxRoom = [6515, 6934]
	
	enemyObj.setupSpawn(xMinMaxRoom, yMinMaxRoom, player)
	
func tripleAroundAttack():
	var t = Timer.new()
	t.set_wait_time(0.5)
	self.add_child(t)
	
	t.start()
	yield(t, "timeout")
	shootAroundProjectiles()
	
	t.start()
	yield(t, "timeout")
	shootAroundProjectiles()
	
	t.start()
	yield(t, "timeout")
	shootAroundProjectiles()
	
	t.queue_free()
	initialAttackFinished = true

func shootFocusedToPlayerProjectile():
	for i in range(3):
		var bossArrow = arrow.instance()
		get_parent().add_child(bossArrow)
		var direction = global_position.direction_to(player.global_position)
		if i == 0:
			direction *= 0.9
		elif i == 2:
			direction *= 1.1
		bossArrow.setup(self.position, rand_range(0,200), direction, 600)

func shootAroundProjectiles():
	for i in range(0, maxHealth+1):
		var angle = i * 36 + $firingPoint.rotation_degrees
		var direction = Vector2(cos(angle), sin(angle))
		var bossArrow = arrow.instance()
		get_parent().add_child(bossArrow)
		bossArrow.setup(position, rotation_degrees+i * 36, direction, 400)
	$firingPoint.rotation_degrees += 10
	
func _on_hitbox_area_entered(area):
	if active:
		if phase == 1:
			if "nearAttack" in area.name:
				currentHealth = currentHealth - 1
				healthPoints.text = "0" + str(currentHealth)
			elif "magicAttack" in area.name or "rangedAttack" in area.name:
				proyectilesRecibidos += 1
				if proyectilesRecibidos <= 4:
					$bossDialogs.set_bbcode("[center] TUS PROYECTILES SON INUTILES CONTRA MI")
				else:
					$bossDialogs.set_bbcode("[center] PERO ES QUE NO TE ENTERAS?! NO SIRVE DE NADA DISPARARME, IMBECIL.")
				$bossDialogs.visible = true
				$dialogDeath.start()
		elif phase == 2:
			if "nearAttack" in area.name or "magicAttack" in area.name or "rangedAttack" in area.name:
				$shieldTimer.start()
				shieldHealth -= 1
				match (shieldHealth):
					4: $stateBody/bossSkullShield.self_modulate = "#FF0000" 
					4: $stateBody/bossMouthShield.self_modulate = "#FF0000" 
					3: $stateBody/bossSkullShield.self_modulate = "#FFB900" 
					3: $stateBody/bossMouthShield.self_modulate = "#FFB900" 
					2: $stateBody/bossSkullShield.self_modulate = "#FCFF08"
					2: $stateBody/bossMouthShield.self_modulate = "#FCFF08" 
					1: $stateBody/bossSkullShield.self_modulate = "#00ffffff"
					1: $stateBody/bossMouthShield.self_modulate = "#00ffffff" 
					_: notEnoughDamage = false
					
				if notEnoughDamage == false:
					currentHealth -= 1
					healthPoints.text = "0" + str(currentHealth)
		elif phase == 3:
			if "rangedAttack" in area.name:
				currentHealth -= 1
				healthPoints.text = "0" + str(currentHealth)
				$lowerDodge/lowerDodgeHitbox.shape.extents.y *= 1.2
				$upperDodge/upperDodgeHitbox.shape.extents.y *= 1.2
				
		if currentHealth <= 0:
			phase = 4
			$bossDialogs.set_bbcode("[center]IMPOSIBLE\nYO TE MALDIGO")
			$dialogDeath.wait_time = 3
			$dialogDeath.start()
			move_and_collide(Vector2(0,0))
			$AnimationPlayer.set_speed_scale(0.4)
			$AnimationPlayer.play("fadeOut")
			createExplosion()
			roomCam.gameWon()

func _on_active_timeout():
	active = true

func _on_dialogDeath_timeout():
	proyectilesRecibidos = 0
	$bossDialogs.visible = false

func _on_attackTimer_timeout():
	canAttack = true

func getProjectilesReceived():
	return proyectilesRecibidos

func _on_fadeOutTimer_timeout():
	haveToFadeIn = true

func _on_fadeInTimer_timeout():
	haveToFadeOut = true

func _on_shieldTimer_timeout():
	if phase == 2:
		shieldHealth = 4
		$stateBody/bossSkullShield.self_modulate = "#ff0000"
		$stateBody/bossMouthShield.self_modulate = "#ff0000"
		if notEnoughDamage:
			$bossDialogs.visible = true
			$bossDialogs.set_bbcode("[center] DISPARANDO TAN LENTO NUNCA ATRAVESARAS MI ESCUDO")
			$dialogDeath.start()
		notEnoughDamage = true

func _on_lowerDodge_area_entered(area):
	if phase == 3:
		bounce = 0
		if "magicAttack" in area.name or "rangedAttack" in area.name:
			$bossDialogs.visible = true
			$bossDialogs.set_bbcode("[center] PREVISIBLE")
			$dialogDeath.start()

func _on_upperDodge_area_entered(area):
	if phase == 3:
		bounce = 1
		if "magicAttack" in area.name or "rangedAttack" in area.name:
			$bossDialogs.visible = true
			$bossDialogs.set_bbcode("[center] FACIL")
			$dialogDeath.start()
