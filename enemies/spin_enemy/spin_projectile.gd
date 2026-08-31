class_name SpinProjectile
extends EnemyProjectile

@onready var sprite: Sprite2D = $Sprite


func set_projectile_texture(new_texture: Texture2D, move: bool) -> void:
	if move:
		sprite.position = Vector2(0, 0)
	sprite.texture = new_texture
