class_name CameraManager
extends Node2D

var roomCam = true
var time_shaking: float = 0

@onready var room_cam: Camera2D = $roomCam
@onready var zoom_camera: Camera2D = $zoomCamera


func _physics_process(delta):
	get_input()

	if not time_shaking:
		room_cam.offset = Vector2.ZERO
	else:
		time_shaking -= delta
		if time_shaking <= 0:
			time_shaking = 0
		room_cam.offset = Vector2(randf_range(-25, 25), randf_range(-25, 25))


func shake_screen(seconds: float) -> void:
	time_shaking = seconds


func get_input():
	if roomCam == true:
		room_cam.make_current()
	else:
		zoom_camera.make_current()

	if Input.is_action_just_pressed("chCam"):
		roomCam = !roomCam

	if zoom_camera.is_current():
		get_tree().paused = true
	else:
		get_tree().paused = false
