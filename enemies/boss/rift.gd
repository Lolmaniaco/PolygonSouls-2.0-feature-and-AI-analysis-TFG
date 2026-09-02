class_name Rift
extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var smoke: GPUParticles2D = $Smoke
@onready var explosion: GPUParticles2D = $Explosion
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	sprite.visible = false
	collision_shape.disabled = true


func make_rift() -> void:
	audio_stream_player.play()
	explosion.emitting = true
	await get_tree().create_timer(0.2).timeout
	sprite.visible = true
	collision_shape.disabled = false
	await get_tree().create_timer(0.3).timeout
	explosion.emitting = false
	smoke.emitting = true
	await get_tree().create_timer(1).timeout
	smoke.emitting = false
