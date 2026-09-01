extends AudioStreamPlayer

const BG_MUSIC = preload("uid://bghyc4hvyer2q")

var fade_out: bool = false


func _ready() -> void:
	AudioServer.set_bus_volume_linear(0, 0.5)
	stream = BG_MUSIC
	play()


func _physics_process(_delta: float) -> void:
	if not fade_out:
		return

	volume_db -= _delta * 10
	if volume_db <= -50:
		stop()
		volume_db = 0


func fade_out_music() -> void:
	fade_out = true
