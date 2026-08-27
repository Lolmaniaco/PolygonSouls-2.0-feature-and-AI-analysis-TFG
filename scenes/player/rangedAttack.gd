class_name RangedProjectile
extends Area2D

#EXPORTS
@export var speed: float = 10.0

var facingDirection


func _physics_process(_delta):
	position += facingDirection * speed


func setup(pos, rot, dir):
	position = pos
	rotation_degrees += rot
	facingDirection = dir


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body is TileMapLayer:
		queue_free()
	elif body is Enemy:
		body.take_hit()
		queue_free()
