extends AudioStreamPlayer

const BG_MUSIC = preload("uid://bghyc4hvyer2q")


func _ready() -> void:
	stream = BG_MUSIC
	play()
