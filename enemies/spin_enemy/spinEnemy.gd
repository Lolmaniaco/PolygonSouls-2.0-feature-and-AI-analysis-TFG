class_name SpinEnemy
extends Enemy

const PROJECTILE = preload("uid://blxhtn368tlov")
const MAGIC_TEXTURE = preload("uid://c0yep0sl8nlbx")
const RANGED_TEXTURE = preload("uid://dpi2whs4cggvo")

const MAGIC_TYPE = preload("uid://b1j80a31wbinc")
const MELEE_TYPE = preload("uid://du77whchfxqwy")
const RANGED_TYPE = preload("uid://c65282by30vy8")

const MAGIC_SHOT = preload("uid://bxcj748t3uu2v")
const TURRET_SHOT = preload("uid://yluj847eimc1")

var player_inside: bool = false
var regenerate: bool = true
var waitUntilStartHealing: float = 1
var flee_player: bool = false

var rPAP # received PAP
var EAPs = { 'C': 0, 'R': 0, 'M': 0 } # Enemy attack patterns

var object_types = [
	{ 'attackType': 'C', 'roll_weight': 0.2, 'acc_weight': 0 } ,
	{ 'attackType': 'R', 'roll_weight': 0.2, 'acc_weight': 0 } ,
	{ 'attackType': 'M', 'roll_weight': 0.6, 'acc_weight': 0 }]

var attackMultiplier = 1.0
var attackDamage = 30
var shields = 3
var spin_speed: int = 2
var current_attack = 'M'
var canShoot = true
var base_attack_speed = 0.8

@onready var spikesCenterPoint = $enemyCenterPos
@onready var health_bar: TextureProgressBar = $healthBar
@onready var healing_timer: Timer = $HealingTimer
@onready var heal_particles: GPUParticles2D = $HealParticles

@onready var reload_timer: Timer = $reloadTimer
@onready var type: Sprite2D = $Type
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var enemy_center_pos: Array = $enemyCenterPos.get_children()
@onready var sfx: AudioStreamPlayer = $sfx


func _ready():
	UI = $"../../../../player/UI"
	player = $"../../../../player"
	_start_delay()
	speed *= 0.7


func _physics_process(delta):
	var movement
	var directionToPlayer

	if not flee_player:
		waitUntilStartHealing = 1
		heal_particles.emitting = false
		directionToPlayer = global_position.direction_to(player.global_position)
		movement = directionToPlayer * speed * 2 * delta
		if getHealth() < 50:
			weakened()
	else:
		if player_inside:
			waitUntilStartHealing = 1
			heal_particles.emitting = false
			directionToPlayer = -global_position.direction_to(player.global_position)
			movement = directionToPlayer * speed * delta
			if getHealth() >= 50:
				continue_fighting()
		else:
			heal_particles.emitting = true
			movement = Vector2(0, 0)
			canShoot = false
			reload_timer.start()

			if waitUntilStartHealing > 0:
				waitUntilStartHealing -= delta
			else:
				if regenerate:
					healthUpdate(0.5)
					regenerate = false
					healing_timer.start()

				if getHealth() >= 100:
					flee_player = false
				elif getHealth() == 50:
					animation_player.play("regenerated")

	match(current_attack):
		'C':
			spin_speed = 6
			type.texture = MELEE_TYPE
		'R':
			spin_speed = 2
			type.texture = RANGED_TYPE
			shootProjectile()
		'M':
			spin_speed = 2
			type.texture = MAGIC_TYPE
			shootProjectile()

	spikesCenterPoint.rotation_degrees += spin_speed
	move_and_collide(movement)


func continue_fighting():
	base_attack_speed = 0.5
	flee_player = false


func weakened():
	animation_player.play("weakened")
	base_attack_speed = 1.5
	flee_player = true


func has_protection() -> bool:
	if enemy_center_pos.is_empty():
		return true

	enemy_center_pos.pop_back().queue_free()
	if enemy_center_pos.is_empty():
		animation_player.play("shieldLess")
		object_types.pop_front()

	return false


func shootProjectile():
	if not canShoot:
		return

	canShoot = false
	reload_timer.wait_time = base_attack_speed + randf_range(-0.3, 0.8)
	reload_timer.start()

	var projectile: SpinProjectile = PROJECTILE.instantiate()
	var proj_speed: float = 500
	var texture: Texture2D = RANGED_TEXTURE
	var move_texture: bool = false

	if current_attack == 'M':
		proj_speed = 250
		texture = MAGIC_TEXTURE
		move_texture = true

	add_sibling(projectile)
	projectile.setup(
		global_position,
		global_position.angle_to_point(player.global_position),
		global_position.direction_to(player.global_position).normalized(),
		proj_speed
	)
	projectile.set_projectile_texture(texture, move_texture)
	sfx.play()


func initProbabilities():
	var total_weight = 0.0

	for obj_type in object_types:
		total_weight += obj_type.roll_weight
		obj_type.acc_weight = total_weight


func pick_type() -> String:
	var roll: float = randf()

	for obj_type in object_types:
		if obj_type.acc_weight > roll:
			return obj_type.attackType

	return ""


func trigger_death(get_souls: bool):
	if get_souls:
		updatePlayerSouls(100)
	queue_free()


func healthUpdate(health):
	health_bar.value += health


func getHealth():
	return health_bar.value


func _on_hitbox_area_entered(area):
	if not area.is_in_group("pjBullets") and not area.name == "nearAttack":
		return

	if "nearAttack" in area.name:
		match(current_attack):
			'C': attackMultiplier = 1
			'R': attackMultiplier = 1.5
			'M': attackMultiplier = 0.5
	elif area is MagicProjectile:
		match(current_attack):
			'C': attackMultiplier = 1.5
			'R': attackMultiplier = 0.5
			'M': attackMultiplier = 1
	elif area is Projectile:
		match(current_attack):
			'C': attackMultiplier = 0.5
			'R': attackMultiplier = 1.0
			'M': attackMultiplier = 1.5

	if has_protection():
		healthUpdate(-attackDamage * attackMultiplier)

	if getHealth() <= 0:
		trigger_death(true)


func _on_processEAP_timeout():
	rPAP = player.getPAP()

	for obj_type in object_types:
		match(obj_type.attackType):
			'C': obj_type.roll_weight = rPAP['R']
			'R': obj_type.roll_weight = rPAP['M']
			'M': obj_type.roll_weight = rPAP['C']
	initProbabilities()

	var new_type = pick_type()
	if new_type == "":
		return
		
	current_attack = new_type
	
	if new_type == 'R':
		sfx.stream = TURRET_SHOT
	elif new_type == 'M':
		sfx.stream = MAGIC_SHOT


func _on_healingTicTimer_timeout():
	regenerate = true


func _on_reloadTimer_timeout():
	canShoot = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player_inside = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player_inside = false


func _on_shield_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("pjBullets"):
		area.queue_free()
