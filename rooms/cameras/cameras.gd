extends Node2D

var roomCam = true


func _physics_process(_delta):
	get_input()


func get_input():
	if roomCam == true:
		$roomCam.make_current()
	else:
		$zoomCamera.make_current()

	if Input.is_action_just_pressed("chCam"):
		roomCam = !roomCam

	if $zoomCamera.is_current():
		get_tree().paused = true
	else:
		get_tree().paused = false
