extends Node

var time
var death_counter: int = 0
var restart_timer: float = 10
var reset_timer: Timer


func _ready() -> void:
	reset_timer = Timer.new()
	reset_timer.wait_time = 2
	reset_timer.one_shot = true
	reset_timer.autostart = false
	reset_timer.timeout.connect(_on_reset_timer_timeout)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('resetScene', true):
		if reset_timer.is_stopped() and reset_timer.is_inside_tree():
			reset_timer.start()

		restart_timer -= 1
		if restart_timer <= 0:
			get_tree().reload_current_scene()
			restart_timer = 10


func _on_reset_timer_timeout() -> void:
	restart_timer = 10
