extends Node

const CENTER: Vector2 = Vector2(576, 320)
const MAX_ROOMS: int = 12
const DIRECTIONS = [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]

@onready var WINDOWS_SIZE: Vector2i = Vector2(get_window().size) / Vector2(32, 32)
