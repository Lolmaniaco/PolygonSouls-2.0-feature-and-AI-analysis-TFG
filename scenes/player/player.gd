class_name Player
extends CharacterBody2D

enum Weapon {
	MELEE,
	RANGED,
	MAGIC,
}

const PAmax = 10
const MELEE_TEXTURE = preload("uid://bwjnr8upy4j35")
const RANGED_TEXTURE = preload("uid://yx8af2m77rnq")
const MAGIC_TEXTURE = preload("uid://do2suxjm4qq3j")

const MELEE_ATTACK = preload("uid://ct8hk6tgjt503")
const RANGED_ATTACK = preload("uid://cpkds4nrxak5s")
const MAGIC_ATTACK = preload("uid://ckf0fqbdq4342")

@export var maxHealth: int = 100
@export var maxStamina: int = 100
@export var speed = 340

var attack_cost: int = 10
var regenerate_stamina: bool = false
var current_weapon: Weapon = Weapon.MELEE
var directions = [Vector2.UP, Vector2(1, -1), Vector2.RIGHT, Vector2(1, 1), Vector2.DOWN, Vector2(-1, 1), Vector2.LEFT, Vector2(-1, -1)]

var has_respawn: bool = false
var respawn_pos: Vector2 = Vector2.ZERO
var lost_control: bool = false

var last_attacks = [] # Player Attacks
var last_attacks_tracker = { 'C': 0, 'R': 0, 'M': 0 }

var god_mode: bool = false

@onready var user_file = "user://score.txt"
@onready var input_disabled: Timer = $inputDisabled
@onready var attack_type: Sprite2D = $AttackType

@onready var attack_reload: Timer = $AttackReload
@onready var health_bar: TextureProgressBar = $healthBar
@onready var stamina_bar: TextureProgressBar = $staminaBar


func _ready():
	health_bar.max_value = maxHealth
	stamina_bar.max_value = maxStamina

	health_bar.value = maxHealth
	stamina_bar.value = maxStamina


func _physics_process(delta):
	if regenerate_stamina:
		stamina_bar.value += 1

	if not lost_control:
		get_input()
	move_and_collide(velocity * delta)
	is_player_dead()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("godMode"):
		if god_mode:
			god_mode = false
		else:
			god_mode = true
			health_bar.value = maxHealth
			stamina_bar.value = maxStamina
		print("GOD MODE TO ", god_mode)


func restore_health() -> void:
	health_bar.value = health_bar.max_value


func getHealth():
	return health_bar.value


func get_input():
	velocity = Vector2.ZERO
	var direction = Input.get_vector("left", "right", "up", "down")

	velocity = direction * speed

	if Input.is_action_just_pressed("prevWeapon"):
		change_weapon(-1)
	elif Input.is_action_just_pressed("nextWeapon"):
		change_weapon(1)

	if stamina_bar.value >= attack_cost:
		if Input.is_action_pressed("attack"):
			if attack_reload.is_stopped():
				attack()
				if not god_mode:
					stamina_bar.value -= attack_cost
					$staminaRecharge.start()
					regenerate_stamina = false


func change_weapon(direction: int) -> void:
	current_weapon = ((current_weapon + direction + Weapon.size()) % Weapon.size()) as Weapon
	swap_weapons()


func swap_weapons() -> void:
	match(current_weapon):
		Weapon.MELEE:
			attack_reload.wait_time = 0.4
			attack_type.texture = MELEE_TEXTURE
			attack_cost = 10
		Weapon.RANGED:
			attack_reload.wait_time = 0.3
			attack_type.texture = RANGED_TEXTURE
			attack_cost = 10
		Weapon.MAGIC:
			attack_reload.wait_time = 0.1
			attack_type.texture = MAGIC_TEXTURE
			attack_cost = 20


func inputDisabled():
	lost_control = true
	input_disabled.start()


func createSpawn(pos):
	has_respawn = true
	respawn_pos = pos


func get_respawn():
	return has_respawn


func is_player_dead():
	if health_bar.value <= 0:
		if has_respawn:
			position = respawn_pos
			has_respawn = false
		else:
			Global.deathCounter += 1
			print("Muertes: ", Global.deathCounter)
			get_tree().change_scene_to_file("res://scenes/control/gameOverScreen.tscn")
		health_bar.value = maxHealth


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

	attack_reload.start()
	match(current_weapon):
		Weapon.MELEE:
			$AnimationPlayer.play("meleeAttack")
			last_attacks.append('C')
		Weapon.RANGED:
			instantiate_bullet(RANGED_ATTACK, 'R', facingDir)
		Weapon.MAGIC:
			instantiate_bullet(MAGIC_ATTACK, 'M', facingDir)
	checkPA()
	makePAP()


func instantiate_bullet(scene: PackedScene, value: String, direction: Vector2):
	var bullet := scene.instantiate()
	bullet.setup(position, $weapons.rotation_degrees, direction)
	add_sibling(bullet)
	last_attacks.append(value)


func checkPA():
	if last_attacks.size() > PAmax and attack_reload.is_stopped():
		last_attacks.pop_front()


func makePAP():
	last_attacks_tracker['C'] = float(last_attacks.count('C')) / last_attacks.size()
	last_attacks_tracker['R'] = float(last_attacks.count('R')) / last_attacks.size()
	last_attacks_tracker['M'] = float(last_attacks.count('M')) / last_attacks.size()


func getPAP():
	return last_attacks_tracker


func receive_damage(lost_life: int):
	if not god_mode:
		health_bar.value -= lost_life


func _on_inputDisabled_timeout():
	lost_control = false


func _on_staminaRecharge_timeout():
	regenerate_stamina = true


func _on_near_attack_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_hit()
