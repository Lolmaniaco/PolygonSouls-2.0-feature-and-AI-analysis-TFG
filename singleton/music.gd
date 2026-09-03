extends AudioStreamPlayer

const BG_MUSIC = preload("uid://bghyc4hvyer2q")
const BOSS_THEME = preload("uid://bl3dwpc1rqo71")
const FANFARE = preload("uid://d3o5k8k20yb75")
const GAME_OVERW = preload("uid://bmn06fmtjbw8w")

var fade_out: bool = false
var ready_to_play: bool = true
var song_in_queue: bool = false


func _ready() -> void:
	AudioServer.set_bus_volume_linear(0, 0.5)
	stream = BG_MUSIC


func _physics_process(delta: float) -> void:
	if song_in_queue and ready_to_play:
		song_in_queue = false
		play()

	if not fade_out:
		return

	volume_db -= delta * 10
	if volume_db <= -20:
		stop()
		volume_db = 0
		fade_out = false
		ready_to_play = true


func play_fanfare_music() -> void:
	stream = FANFARE
	volume_db = 5
	song_in_queue = true


func play_boss_music() -> void:
	stream = BOSS_THEME
	volume_db = 10
	song_in_queue = true


func play_level_music() -> void:
	stream = BG_MUSIC
	volume_db = -2.5
	song_in_queue = true


func play_game_over_music() -> void:
	stream = GAME_OVERW
	volume_db = 0
	song_in_queue = true


func fade_out_music() -> void:
	fade_out = true
	ready_to_play = false
