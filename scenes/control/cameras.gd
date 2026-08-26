extends Node2D

var roomCam = true


# Called when the node enters the scene tree for the first time.
func _ready():
	$paused.visible = false


func _physics_process(delta):
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
