extends Node2D

var roomCam = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$paused.visible = false

func get_input():
	if roomCam == true:
		$roomCam.current = true
	else:
		$zoomCamera.current = true

	if Input.is_action_just_pressed("chCam"):
		roomCam = !roomCam
		
	if $zoomCamera.current:
		get_tree().paused = true
	else:
		get_tree().paused = false

func _physics_process(delta):
	get_input()
