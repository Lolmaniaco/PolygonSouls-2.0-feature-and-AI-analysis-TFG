class_name Door
extends Node2D

enum Order {
	OPEN,
	CLOSE,
}

var player_inside: bool = false
var next_animation: String = ""

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _physics_process(_delta: float) -> void:
	if not player_inside and not next_animation == "":
		animation_player.play(next_animation)
		next_animation = ""


func setup(initPos: Vector2, turn_door: bool):
	if initPos.x == 576:
		if initPos.y == 16:
			name = "Upper Door"
		else:
			name = "Down Door"
	else:
		if initPos.x == 16:
			name = "Left Door"
		else:
			name = "Right Door"

	position = initPos
	if turn_door:
		rotation_degrees = -90


func queue_door_animation(animation: String):
	next_animation = animation


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	player_inside = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body is Player:
		return

	player_inside = false
