class_name Player
extends CharacterBody2D

const PAmax = 10 # Max number of player attack saved

@export var maxHealth: int = 100
@export var maxStamina: int = 100

var actualRoom = Vector2.ZERO
var lastRoom = Vector2.ZERO
var currentWeapon = 1
var facingDir
var directions = [Vector2.UP, Vector2(1, -1), Vector2.RIGHT, Vector2(1, 1), Vector2.DOWN, Vector2(-1, 1), Vector2.LEFT, Vector2(-1, -1)]

var arrow = preload("res://scenes/player/rangedAttack.tscn")
var fireball = preload("res://scenes/player/magicAttack.tscn")

var user_file = "res://score.txt"
var lastNumberDeaths

var playerOldPos
var playerVol

var inputIsDisabled = false
var speed = 340
var lastDir = Vector2()
var hasRespawn = false
var spawnPosition
var costOfAttack = 10
var PA = [] # Player Attacks
var PAP = { 'C': 0, 'R': 0, 'M': 0 }
var PAsize = 07

var godMode = false
var attackDamage = 19
var attackMultiplier = 1.0

@onready var input_disabled: Timer = $inputDisabled


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(400, 400)
	playerOldPos = global_position

	$weapons.visible = false
	$playerUI.maxHealthUpdate(maxHealth)
	$playerUI.maxStaminaUpdate(maxStamina)

	$playerUI.setHealth(maxHealth)
	$playerUI.setStamina(maxStamina)


func _physics_process(delta):
	playerVol = global_position - playerOldPos
	playerOldPos = global_position

	if godMode:
		$playerUI.setHealth(maxHealth)
		$playerUI.setStamina(maxStamina)

	if !inputIsDisabled:
		get_input()
	move_and_collide(velocity * delta)
	isDead()


func _input(event):
	if Input.is_action_just_pressed("godMode"):
		if godMode:
			godMode = false
		else:
			godMode = true


func setHealth(value):
	$playerUI.setHealth(value)


func getHealth():
	return $playerUI.getHealthValue()


func getPos():
	return global_position


func setPos(pos):
	position += pos


func getLastUsedDir():
	return lastDir


func get_input():
	# Detect up/down/left/right keystate and only move when pressed.
	velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1

	# Get last used direction
	if velocity != Vector2.ZERO:
		lastDir = velocity

	velocity = velocity.normalized() * speed

	if Input.is_key_pressed(KEY_7):
		position = Vector2(11 * 1024 - 200, 11 * 640 - 200)
	if Input.is_key_pressed(KEY_8):
		position = Vector2(64, 64)

	if Input.is_action_just_pressed("prevWeapon"):
		currentWeapon -= 1
		# 1: melee, 2: ranged, 3: magic
		if currentWeapon < 1:
			currentWeapon = 3

	if Input.is_action_just_pressed("nextWeapon"):
		currentWeapon += 1
		# 1: melee, 2: ranged, 3: magic
		if currentWeapon > 3:
			currentWeapon = 1

	if Input.is_action_just_pressed("nextWeapon") or Input.is_action_just_pressed("prevWeapon"):
		match(currentWeapon):
			1:
				$meleeAttack.visible = true
				$rangedAttack.visible = false
				$magicAttack.visible = false
				costOfAttack = 10
			2:
				$meleeAttack.visible = false
				$rangedAttack.visible = true
				$magicAttack.visible = false
				costOfAttack = 10
			3:
				$meleeAttack.visible = false
				$rangedAttack.visible = false
				$magicAttack.visible = true
				costOfAttack = 20

	if $playerUI/staminaBar.value >= costOfAttack:
		if Input.is_action_pressed("attack") and $rangedReloadTimer.is_stopped() and $meleeReloadTimer.is_stopped() and $magicReloadTimer.is_stopped():
			attack()
			$playerUI.staminaUpdate(-costOfAttack)
			$staminaRecharge.start()
			$playerUI.recoverStamina(false)


func inputDisabled():
	inputIsDisabled = true
	input_disabled.start()


func createSpawn(pos):
	hasRespawn = true
	spawnPosition = pos


func getHasRespawn():
	return hasRespawn

"""
func addPlayerDeath():
	var f = File.new()
	var lastHoursPlayed = -1
	
	if f.file_exists(user_file):
		f.open(user_file, File.READ)
		var index = 1
		while index != 3: # iterate through all lines until the end of file is reached
			if index == 1:
				lastHoursPlayed = int(f.get_line())
			elif index == 2:
				lastNumberDeaths = int(f.get_line())
			index += 1
		f.close()
	
	var currentTime = OS.get_time()
	var file = File.new()
	file.open(user_file, File.WRITE)
	file.store_string(str(currentTime.hour) + "\n")
	
	if lastHoursPlayed != int(currentTime.hour):
		lastNumberDeaths = 0
	else:
		lastNumberDeaths += 1
		
	file.store_line(str(lastNumberDeaths))
	file.close()
"""


func isDead():
	if $playerUI/healthBar.value <= 0:
		if hasRespawn:
			position = spawnPosition
			$playerUI.setHealth(maxHealth)
			hasRespawn = false
		else:
			#addPlayerDeath()
			GlobalVariables.deathCounter += 1
			print("Muertes: ", GlobalVariables.deathCounter)
			get_tree().change_scene_to_file("res://scenes/control/gameOverScreen.tscn")
			$playerUI.setHealth(maxHealth)


func attack():
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

	match(currentWeapon):
		1:
			if $meleeReloadTimer.is_stopped():
				$meleeReloadTimer.start()
				$weapons.visible = true
				$weapons/sword/nearAttack/CollisionShape2D2.disabled = false
				$AnimationPlayer.play("meleeAttack")
				$weapons/sword/nearAttack/CollisionShape2D2.disabled = true
				PA.append('C')
		2:
			if $rangedReloadTimer.is_stopped():
				$rangedReloadTimer.start()
				var bullet = arrow.instantiate()
				bullet.setup(position, $weapons.rotation_degrees, facingDir)
				get_parent().add_child(bullet)
				PA.append('R')
		3:
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


func setActualRoom(room):
	actualRoom = room.roomCoord


func receive_damage(lost_life: int):
	$playerUI.healthUpdate(-lost_life)


func _on_inputDisabled_timeout():
	inputIsDisabled = false


func _on_staminaRecharge_timeout():
	$playerUI.recoverStamina(true)


func _on_near_attack_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_hit()
