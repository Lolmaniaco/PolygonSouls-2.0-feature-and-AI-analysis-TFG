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

var initialAttackFinished: bool = false

var proyectilesRecibidos: int = 0
var dir_idx: int = 1

var haveToFadeOut: bool = true
var haveToFadeIn: bool = false
var posibleSpawns: Array[Vector2] = [Vector2(120, 150), Vector2(120, 500), Vector2(1050, 150), Vector2(1050, 500)]
var shieldHealth: int = 4
var enough_damage: bool = false

var go_up: bool = true
var concentratedAttackCounter: int = 2

var state: State = State.INITIAL
var maxHealth: int = 10
var health: int = 10
var movement: Vector2 = Vector2.ZERO
var can_attack: bool = false

@onready var health_label = $stateBody/healthPoints
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var firing_point: Marker2D = $firingPoint
@onready var dialog_hide_timer: Timer = $DialogHideTimer

@onready var protective_aura: Area2D = $protectiveAura
@onready var shield_timer: Timer = $shieldTimer
@onready var rift: Rift = $"../rift"
@onready var boss_dialogs: RichTextLabel = $"../rift/bossDialogs"
@onready var hitbox: Area2D = $hitbox
@onready var state_body: Sprite2D = $stateBody

@onready var mouth_shield: Sprite2D = $stateBody/bossMouthShield
@onready var skull_shield: Sprite2D = $stateBody/bossSkullShield
@onready var sfx: AudioStreamPlayer = $SFX
@onready var voice: AudioStreamPlayer = $Voice


func _ready() -> void:
	player = $"../../../player"
	UI = $"../../../player/UI"
	speed *= 3
	modulate.a = 0

	set_physics_process(false)
	await get_tree().create_timer(2).timeout
	Music.play_boss_music()
	player.change_control(true)
	var tween = get_tree().create_tween()
	tween.tween_property(player, "position", Vector2(11520 + 200, player.global_position.y), 0.5)
	tween.tween_property(player, "position", Vector2(11520 + 200, 6720), 0.5)
	await tween.finished

	var dialog_timer = Timer.new()
	dialog_timer.wait_time = 0.5
	dialog_timer.one_shot = true
	add_child(dialog_timer)

	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1, 1)

	dialog_timer.start()
	await dialog_timer.timeout
	anim_player.play("talking")
	boss_dialogs.text = "[center] BIENVENIDO, PALADIN DE LA LUZ"

	dialog_timer.wait_time = 2
	dialog_timer.start()
	await dialog_timer.timeout
	boss_dialogs.text = "[center] ESTA SERA TU TUMBA DENTRO DE MUY POCO"
	voice.play()

	dialog_timer.start()
	await dialog_timer.timeout
	boss_dialogs.visible = false

	anim_player.stop(true)

	tween = get_tree().create_tween()
	tween.tween_property(protective_aura, "scale", Vector2(0.2, 0.2), 1.25)
	await tween.finished
	protective_aura.queue_free()
	mouth_shield.visible = true
	skull_shield.visible = true

	await get_tree().create_timer(1).timeout
	player.change_control(false)
	set_physics_process(true)


func _physics_process(delta) -> void:
	if state == State.INITIAL:
		if not initialAttackFinished:
			shoot_around_thrice()
			state = State.WALL_CRAWLER

	elif state == State.WALL_CRAWLER:
		anim_player.play("chargedShot")

		if can_attack:
			can_attack = false
			anim_player.play("chargedShot")

		movement = directions[dir_idx] * speed * delta
		if move_and_collide(movement):
			if randf() <= 0.2:
				shoot_around()
			dir_idx = randi_range(0, 3)

	elif state == State.TELEPORT:
		if haveToFadeOut:
			haveToFadeOut = false
			anim_player.play("fadeOut")
			$fadeOutTimer.start()

		if not haveToFadeIn:
			return

		haveToFadeIn = false
		if player.global_position.x > 12096:
			if player.global_position.y > 6720:
				position = posibleSpawns[0]
			else:
				position = posibleSpawns[1]
		else:
			if player.global_position.y > 6720:
				position = posibleSpawns[2]
			else:
				position = posibleSpawns[3]

		anim_player.play("fadeIn")
		$fadeInTimer.start()
		shoot_around_thrice()

	elif state == State.EXPLOSION:
		movement = Vector2.UP if go_up else Vector2.DOWN

		if move_and_collide(movement * speed * delta):
			go_up = !go_up

		if can_attack:
			can_attack = false
			concentratedAttackCounter += 1
			anim_player.play("chargedShot")
			if concentratedAttackCounter == 3:
				shoot_around()
				concentratedAttackCounter = 0


func shoot_around_thrice() -> void:
	initialAttackFinished = true
	var new_timer = Timer.new()
	new_timer.set_wait_time(0.5)
	add_child(new_timer)

	for i in range(3):
		new_timer.start()
		await new_timer.timeout
		shoot_around()

	new_timer.queue_free()


func shoot_at_player() -> void:
	for i in range(3):
		var bossArrow: BossProjectile = BOSS_ARROW.instantiate()
		add_sibling(bossArrow)
		var direction = global_position.direction_to(player.global_position)
		direction *= randf_range(0.7, 1.3)
		bossArrow.setup(position, direction, randf_range(400, 600))


func shoot_around() -> void:
	for i in range(0, maxHealth + 1):
		var angle = i * 36 + firing_point.rotation_degrees
		var direction = Vector2(cos(angle), sin(angle))
		var bossArrow: BossProjectile = BOSS_ARROW.instantiate()
		add_sibling(bossArrow)
		bossArrow.setup(position, direction, 400)
	firing_point.rotation_degrees += 10


func pop_invulnerability(seconds: float) -> void:
	hitbox.call_deferred("set_monitoring", false)
	var tween: Tween = get_tree().create_tween()
	var iterations = seconds / 0.1
	for i in range(iterations):
		tween.tween_property(state_body, "modulate:a", 0, 0.1)
		tween.tween_property(state_body, "modulate:a", 1, 0.1)

	await tween.finished
	hitbox.call_deferred("set_monitoring", true)


func change_shield_color(new_color: Color) -> void:
	mouth_shield.self_modulate = new_color
	skull_shield.self_modulate = new_color


func get_hit() -> void:
	health -= 1
	sfx.play()


func _on_hitbox_area_entered(area):
	if state == State.WALL_CRAWLER:
		if "nearAttack" in area.name:
			get_hit()
			pop_invulnerability(1.0)
			health_label.text = str(health)
		elif area is Projectile:
			proyectilesRecibidos += 1
			if proyectilesRecibidos <= 4:
				boss_dialogs.text = "[center] TUS PROYECTILES SON INUTILES CONTRA MI"
			else:
				boss_dialogs.text = "[center] PERO ES QUE NO TE ENTERAS?! NO SIRVE DE NADA DISPARARME, IMBECIL."
			boss_dialogs.visible = true
			dialog_hide_timer.start()

		if health <= 7:
			change_shield_color(Color.RED)
			state = State.TELEPORT

	elif state == State.TELEPORT:
		if "nearAttack" in area.name or area is Projectile:
			if shield_timer.is_stopped():
				shield_timer.start()
			shieldHealth -= 1
			match(shieldHealth):
				4: change_shield_color(Color.RED)
				3: change_shield_color(Color.DARK_ORANGE)
				2: change_shield_color(Color.GOLD)
				1: change_shield_color(Color.CYAN)
				_: enough_damage = true

			if enough_damage:
				get_hit()
				pop_invulnerability(0.3)
				health_label.text = str(health)

			if health <= 4:
				state = State.EXPLOSION
				$stateBody.visible = false
				haveToFadeOut = false
				rift.make_rift()

				if player.global_position.x > 12096:
					position.x = 120
				else:
					position.x = 1050
				position.y = 150
				print("PLAYER POSITION: ", player.global_position)

				set_physics_process(false)
				await get_tree().create_timer(3).timeout
				$stateBody.visible = true
				anim_player.play("fadeIn")
				await anim_player.animation_finished
				set_physics_process(true)

	elif state == State.EXPLOSION:
		if area is Projectile:
			get_hit()
			pop_invulnerability(1.0)
			health_label.text = str(health)
			$lowerDodge/lowerDodgeHitbox.shape.extents.y *= 1.2
			$upperDodge/upperDodgeHitbox.shape.extents.y *= 1.2

	if health <= 0:
		state = State.END
		set_physics_process(false)
		boss_dialogs.text = "[center]IMPOSIBLEEEEE!!\nYO TE MALDIGO"
		anim_player.set_speed_scale(0.4)
		anim_player.play("fadeOut")
		
		Music.fade_out_music()
		Music.play_fanfare_music()
		UI.transition_color(Color.WHITE)
		await get_tree().create_timer(0.5).timeout
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
	if state == State.TELEPORT:
		shieldHealth = 4
		change_shield_color(Color.RED)
		if not enough_damage:
			boss_dialogs.visible = true
			boss_dialogs.text = "[center] DISPARANDO TAN LENTO NUNCA ATRAVESARAS MI ESCUDO"
			dialog_hide_timer.start()
		enough_damage = false


func _on_lowerDodge_area_entered(area):
	if not area is Projectile:
		return

	if state == State.EXPLOSION:
		if movement == Vector2.DOWN:
			go_up = !go_up
		boss_dialogs.visible = true
		boss_dialogs.text = "[center] PREVISIBLE"
		dialog_hide_timer.start()


func _on_upperDodge_area_entered(area):
	if not area is Projectile:
		return

	if state == State.EXPLOSION:
		if movement == Vector2.UP:
			go_up = !go_up
		boss_dialogs.visible = true
		boss_dialogs.text = "[center] FACIL"
		dialog_hide_timer.start()


func _on_protective_aura_area_entered(area: Area2D) -> void:
	if not area.is_in_group("pjBullets"):
		return

	area.queue_free()
