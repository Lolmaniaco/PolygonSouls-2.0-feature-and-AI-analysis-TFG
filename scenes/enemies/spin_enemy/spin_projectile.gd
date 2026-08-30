class_name SpinProjectile
extends EnemyProjectile

@onready var sprite: Sprite2D = $Sprite


func set_projectile_texture(new_texture: Texture2D) -> void:
	sprite.texture = new_texture
