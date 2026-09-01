class_name Boss
extends Enemy

enum State {
	INITIAL,
	WALL_CRAWLER,
	TELEPORT,
	EXPLOSION,
	END,
}

const TURRET = preload("uid://d6hqfkgirjyl")
const KAMIKAZE = preload("uid://cbocpuwmn6qsf")
const BOUNCER = preload("uid://cjhy5jdp4knd4")
const SPIN_ENEMY = preload("uid://c7dq5i3oueuk")
const BOSS_ARROW = preload("uid://ce802823rpndy")

const directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

var state: State = State.INITIAL

var baseEnemies: Array[PackedScene] = [KAMIKAZE, TURRET, BOUNCER]
var hardEnemies: Array[PackedScene] = [KAMIKAZE, TURRET, BOUNCER, SPIN_ENEMY]
var maxHealth: int = 10
var currentHealth: int = 10

var initialAttackFinished: bool = false
var proyectilesRecibidos: int = 0

var wall_idx: int = 1
var can_attack: bool = false

var player_pos: Vector2
var haveToFadeOut: bool = true
var haveToFadeIn: bool = false
var posibleSpawns: Array[Vector2] = [Vector2(120, 150), Vector2(120, 500), Vector2(1050, 150), Vector2(1050, 500)]
var shieldHealth: int = 4
var enough_damage: bool = false

var waitRiftAppear = 0.5
var delayPhaseThree = 3
var setPositionPhaseThree = false
var hasDoneTheExplosion = false
var hardEnemy = true
var hasAppeared = false
var bounce = 1
var collision
var concentratedAttackCounter = 2

@onready var healthPoints = $stateBody/healthPoints
@onready var boss_dialogs: RichTextLabel = $bossDialogs
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var firing_point: Marker2D = $firingPoint
@onready var dialog_hide_timer: Timer = $DialogHideTimer

@onready var protective_aura: Area2D = $protectiveAura
@onready var shield_timer: Timer = $shieldTimer
@onready var dialog_timer: Timer = $DialogTimer


func _ready():
	player = $"../../../player"
	UI = $"../../../player/UI"
	speed *= 3

	set_physics_process(false)
	anim_player.play("talking")
	dialog_timer.start()
	await dialog_timer.timeout
	boss_dialogs.text = "[center] BIENVENIDO, PALADIN DE LA LUZ"

	dialog_timer.wait_time = 2
	dialog_timer.start()
	await dialog_timer.timeout
	boss_dialogs.text = "[center] ESTA SERA TU TUMBA DENTRO DE MUY POCO"

	dialog_timer.start()
	await dialog_timer.timeout
	boss_dialogs.visible = false
	anim_player.stop(true)

	protective_aura.queue_free()
	set_physics_process(true)


func _physics_process(delta):
	var movement: Vector2 = Vector2.ZERO

	if state == State.INITIAL:
		if not initialAttackFinished:
			tripleAroundAttack()
			state = State.WALL_CRAWLER

	elif state == State.WALL_CRAWLER:
		anim_player.play("chargedShoot")

		if can_attack:
			can_attack = false
			shootFocusedToPlayerProjectile()

		movement = directions[wall_idx] * speed * 1.35 * delta
		if move_and_collide(movement):
			if randf() <= 0.25:
				tripleAroundAttack()

			if currentHealth >= 9:
				wall_idx = randi_range(0, 3)
			else:
				$stateBody/bossSkullShield.self_modulate = Color.RED
				$stateBody/bossMouthShield.self_modulate = Color.RED
				$blockBody/blockBodyHitbox.disabled = true
				state = State.TELEPORT

	elif state == State.TELEPORT:
		if currentHealth <= 3:
			state = State.EXPLOSION
			haveToFadeOut = false
			$stateBody.visible = false

		if haveToFadeOut:
			haveToFadeOut = false
			anim_player.play("fadeOut")
			$fadeOutTimer.start()

		if not haveToFadeIn:
			return

		haveToFadeIn = false
		player_pos = player.global_position
		if player_pos.x > 12096:
			if player_pos.y > 6720:
				position = posibleSpawns[0]
			else:
				position = posibleSpawns[1]
		else:
			if player_pos.y > 6720:
				position = posibleSpawns[2]
			else:
				position = posibleSpawns[3]

		anim_player.play("fadeIn")
		$fadeInTimer.start()
		tripleAroundAttack()

	elif state == State.EXPLOSION:
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
				anim_player.play("fadeIn")

			if bounce % 2 == 0:
				collision = move_and_collide(Vector2.UP * speed * delta)
			else:
				collision = move_and_collide(Vector2.DOWN * speed * delta)
			if collision != null:
				bounce += 1

			if currentHealth <= 2:
				if shield_timer.is_stopped():
					shield_timer.start()

			if $attackTimer.is_stopped():
				$attackTimer.start()

			if can_attack:
				can_attack = false
				concentratedAttackCounter += 1
				shootFocusedToPlayerProjectile()
				if concentratedAttackCounter == 3:
					shootAroundProjectiles()
					concentratedAttackCounter = 0


func spawnEnemies():
	var enemyObj

	if hardEnemy:
		enemyObj = hardEnemies[randi() % 4].instantiate()
		hardEnemy = false
	else:
		enemyObj = baseEnemies[randi() % 3].instantiate()
		hardEnemy = true

	add_child(enemyObj)
	var xMinMaxRoom = [10340, 10741]
	var yMinMaxRoom = [6515, 6934]

	enemyObj.setupSpawn(xMinMaxRoom, yMinMaxRoom, player)


func tripleAroundAttack():
	initialAttackFinished = true
	var new_timer = Timer.new()
	new_timer.set_wait_time(0.5)
	add_child(new_timer)

	for i in range(3):
		new_timer.start()
		await new_timer.timeout
		shootAroundProjectiles()

	new_timer.queue_free()


func shootFocusedToPlayerProjectile():
	for i in range(3):
		var bossArrow: BossProjectile = BOSS_ARROW.instantiate()
		add_sibling(bossArrow)
		var direction = global_position.direction_to(player.global_position)
		direction *= randf_range(0.7, 1.3)
		bossArrow.setup(position, direction, randf_range(500, 750))


func shootAroundProjectiles():
	for i in range(0, maxHealth + 1):
		var angle = i * 36 + firing_point.rotation_degrees
		var direction = Vector2(cos(angle), sin(angle))
		var bossArrow: BossProjectile = BOSS_ARROW.instantiate()
		add_sibling(bossArrow)
		bossArrow.setup(position, direction, 400)
	firing_point.rotation_degrees += 10


func _on_hitbox_area_entered(area):
	if state == State.WALL_CRAWLER:
		if "nearAttack" in area.name:
			currentHealth = currentHealth - 1
			healthPoints.text = "0" + str(currentHealth)
		elif "magicAttack" in area.name or "rangedAttack" in area.name:
			proyectilesRecibidos += 1
			if proyectilesRecibidos <= 4:
				boss_dialogs.text = "[center] TUS PROYECTILES SON INUTILES CONTRA MI"
			else:
				boss_dialogs.text = "[center] PERO ES QUE NO TE ENTERAS?! NO SIRVE DE NADA DISPARARME, IMBECIL."
			boss_dialogs.visible = true
			dialog_hide_timer.start()

	elif state == State.TELEPORT:
		if "nearAttack" in area.name or "magicAttack" in area.name or "rangedAttack" in area.name:
			shield_timer.start()
			shieldHealth -= 1
			match(shieldHealth):
				4:
					$stateBody/bossSkullShield.self_modulate = "#FF0000"
					$stateBody/bossMouthShield.self_modulate = "#FF0000"
				3:
					$stateBody/bossSkullShield.self_modulate = "#FFB900"
					$stateBody/bossMouthShield.self_modulate = "#FFB900"
				2:
					$stateBody/bossSkullShield.self_modulate = "#FCFF08"
					$stateBody/bossMouthShield.self_modulate = "#FCFF08"
				1:
					$stateBody/bossSkullShield.self_modulate = "#00ffffff"
					$stateBody/bossMouthShield.self_modulate = "#00ffffff"
				_: enough_damage = true

			if enough_damage:
				currentHealth -= 1
				healthPoints.text = "0" + str(currentHealth)

	elif state == State.EXPLOSION:
		if "rangedAttack" in area.name:
			currentHealth -= 1
			healthPoints.text = "0" + str(currentHealth)
			$lowerDodge/lowerDodgeHitbox.shape.extents.y *= 1.2
			$upperDodge/upperDodgeHitbox.shape.extents.y *= 1.2

	if currentHealth <= 0:
		state = State.END
		boss_dialogs.text = "[center]IMPOSIBLE\nYO TE MALDIGO"
		dialog_hide_timer.wait_time = 3
		dialog_hide_timer.start()
		move_and_collide(Vector2(0, 0))
		anim_player.set_speed_scale(0.4)
		anim_player.play("fadeOut")
		createExplosion()
		UI.gameWon()


func _on_dialogDeath_timeout():
	proyectilesRecibidos = 0
	boss_dialogs.visible = false


func _on_attackTimer_timeout():
	can_attack = true


func _on_fadeOutTimer_timeout():
	haveToFadeIn = true


func _on_fadeInTimer_timeout():
	haveToFadeOut = true


func _on_shieldTimer_timeout():
	if state == 2:
		shieldHealth = 4
		$stateBody/bossSkullShield.self_modulate = "#ff0000"
		$stateBody/bossMouthShield.self_modulate = "#ff0000"
		if not enough_damage:
			boss_dialogs.visible = true
			boss_dialogs.text = "[center] DISPARANDO TAN LENTO NUNCA ATRAVESARAS MI ESCUDO"
			dialog_hide_timer.start()
		enough_damage = false


func _on_lowerDodge_area_entered(area):
	if state == 3:
		bounce = 0
		if "magicAttack" in area.name or "rangedAttack" in area.name:
			boss_dialogs.visible = true
			boss_dialogs.text = "[center] PREVISIBLE"
			dialog_hide_timer.start()


func _on_upperDodge_area_entered(area):
	if state == 3:
		bounce = 1
		if "magicAttack" in area.name or "rangedAttack" in area.name:
			boss_dialogs.visible = true
			boss_dialogs.text = "[center] FACIL"
			dialog_hide_timer.start()


func _on_protective_aura_area_entered(area: Area2D) -> void:
	if not area.is_in_group("pjBullets"):
		return

	area.queue_free()
