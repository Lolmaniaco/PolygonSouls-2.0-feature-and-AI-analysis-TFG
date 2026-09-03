class_name MagicProjectile
extends Projectile

@onready var sprite: Sprite2D = $Sprite2D

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D


func _physics_process(delta):
	position += facingDirection * speed * delta


func _on_lifespanTimer_timeout():
	col_shape.disabled = true
	particles.emitting = false
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color.TRANSPARENT, 0.1)
	await get_tree().create_timer(0.5).timeout
	queue_free()
