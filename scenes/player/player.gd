class_name Player
extends CharacterBody2D

enum Weapon {
	MELEE,
	RANGED,
	MAGIC,
}

const PAmax = 10 # Max number of player attack saved

@export var maxHealth: int = 100
@export var maxStamina: int = 100
@export var speed = 340

var current_weapon: Weapon = Weapon.MELEE
var directions = [Vector2.UP, Vector2(1, -1), Vector2.RIGHT, Vector2(1, 1), Vector2.DOWN, Vector2(-1, 1), Vector2.LEFT, Vector2(-1, -1)]

var player_control: bool = false

var lastDir: Vector2 = Vector2.ZERO
var respawn: bool = false
var respawn_pos: Vector2 = Vector2.ZERO
var attack_cost: int = 10
var PA = [] # Player Attacks
var PAP = { 'C': 0, 'R': 0, 'M': 0 }
var PAsize = 07

var god_mode: bool = false

@onready var user_file = "res://score.txt"
@onready var arrow = preload("res://scenes/player/rangedAttack.tscn")
@onready var fireball = preload("res://scenes/player/magicAttack.tscn")

@onready var input_disabled: Timer = $inputDisabled


func _ready():
	position = Vector2(400, 400)

	$playerUI.maxHealthUpdate(maxHealth)
	$playerUI.maxStaminaUpdate(maxStamina)

	$playerUI.setHealth(maxHealth)
	$playerUI.setStamina(maxStamina)


func _physics_process(delta):
	if not player_control:
		get_input()
	move_and_collide(velocity * delta)
	isDead()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("godMode"):
		if god_mode:
			god_mode = false
		else:
			god_mode = true
			$playerUI.setHealth(maxHealth)
			$playerUI.setStamina(maxStamina)
		print("GOD MODE TO ", god_mode)


func setHealth(value):
	$playerUI.setHealth(value)


func getHealth():
	return $playerUI.getHealthValue()


func get_input():
	# Detect up/down/left/right keystate and only move when pressed.
	velocity = Vector2.ZERO
	var direction = Input.get_vector("left", "right", "up", "down")

	# Get last used direction
	if velocity != Vector2.ZERO:
		lastDir = direction

	velocity = direction * speed

	if Input.is_action_just_pressed("prevWeapon"):
		change_weapon(-1)
	elif Input.is_action_just_pressed("nextWeapon"):
		change_weapon(1)

	if $playerUI/staminaBar.value >= attack_cost:
		if Input.is_action_pressed("attack") and $rangedReloadTimer.is_stopped() and $meleeReloadTimer.is_stopped() and $magicReloadTimer.is_stopped():
			attack()
			if not god_mode:
				$playerUI.staminaUpdate(-attack_cost)
				$staminaRecharge.start()
				$playerUI.recoverStamina(false)


func change_weapon(direction: int) -> void:
	current_weapon = ((current_weapon + direction + Weapon.size()) % Weapon.size()) as Weapon
	swap_weapons()


func swap_weapons() -> void:
	match(current_weapon):
		Weapon.MELEE:
			$meleeAttack.visible = true
			$rangedAttack.visible = false
			$magicAttack.visible = false
			attack_cost = 10
		Weapon.RANGED:
			$meleeAttack.visible = false
			$rangedAttack.visible = true
			$magicAttack.visible = false
			attack_cost = 10
		Weapon.MAGIC:
			$meleeAttack.visible = false
			$rangedAttack.visible = false
			$magicAttack.visible = true
			attack_cost = 20


func inputDisabled():
	player_control = true
	input_disabled.start()


func createSpawn(pos):
	respawn = true
	respawn_pos = pos


func has_respawn():
	return respawn


func isDead():
	if $playerUI/healthBar.value <= 0:
		if respawn:
			position = respawn_pos
			$playerUI.setHealth(maxHealth)
			respawn = false
		else:
			#addPlayerDeath()
			Global.deathCounter += 1
			print("Muertes: ", Global.deathCounter)
			get_tree().change_scene_to_file("res://scenes/control/gameOverScreen.tscn")
			$playerUI.setHealth(maxHealth)


func attack():
	var facingDir: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("attackUp"):
		if Input.is_action_pressed("attackRight"):
			$weapons.rotation_degrees = 45
			facingDir = directions[1]
		elif Input.is_action_pressed("attackLeft"):
			$weapons.rotation_degrees = 315
			facingDir = directions[7]
		else:
			$weapons.rotation_degrees = 0
			facingDir = directions[0]
	elif Input.is_action_pressed("attackDown"):
		if Input.is_action_pressed("attackRight"):
			$weapons.rotation_degrees = 135
			facingDir = directions[3]
		elif Input.is_action_pressed("attackLeft"):
			$weapons.rotation_degrees = 225
			facingDir = directions[5]
		else:
			$weapons.rotation_degrees = 180
			facingDir = directions[4]
	elif Input.is_action_pressed("attackRight"):
		$weapons.rotation_degrees = 90
		facingDir = directions[2]
	else: #Left
		$weapons.rotation_degrees = 270
		facingDir = directions[6]

	match(current_weapon):
		Weapon.MELEE:
			if $meleeReloadTimer.is_stopped():
				$meleeReloadTimer.start()
				$AnimationPlayer.play("meleeAttack")
				PA.append('C')
		Weapon.RANGED:
			if $rangedReloadTimer.is_stopped():
				$rangedReloadTimer.start()
				var bullet = arrow.instantiate()
				bullet.setup(position, $weapons.rotation_degrees, facingDir)
				get_parent().add_child(bullet)
				PA.append('R')
		Weapon.MAGIC:
			if $magicReloadTimer.is_stopped():
				$magicReloadTimer.start()
				var bullet = fireball.instantiate()
				bullet.setup(position, $weapons.rotation_degrees, facingDir)
				get_parent().add_child(bullet)
				PA.append('M')
	checkPA()
	makePAP()


func checkPA():
	if PA.size() > PAmax and $meleeReloadTimer.is_stopped() and $rangedReloadTimer.is_stopped() and $magicReloadTimer.is_stopped():
		PA.pop_front()


func makePAP():
	PAsize = float(PA.size())

	PAP['C'] = float(PA.count('C')) / PAsize
	PAP['R'] = float(PA.count('R')) / PAsize
	PAP['M'] = float(PA.count('M')) / PAsize


func getPAP():
	return PAP


func receive_damage(lost_life: int):
	if not god_mode:
		$playerUI.healthUpdate(-lost_life)


func _on_inputDisabled_timeout():
	player_control = false


func _on_staminaRecharge_timeout():
	$playerUI.recoverStamina(true)


func _on_near_attack_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_hit()
