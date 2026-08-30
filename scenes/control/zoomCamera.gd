extends Camera2D

@export var zoomStepAmount: float = 0.25
@export var maxZoomIn: float = 1.0

var first_pos = Vector2()
var resetSafe = 10
var resetTimer = 1


func _process(delta):
	if resetTimer <= 0:
		resetSafe = 10
	else:
		resetTimer -= delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if zoom.x - zoomStepAmount >= maxZoomIn:
					zoom.x -= zoomStepAmount
					zoom.y -= zoomStepAmount

			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom.x += zoomStepAmount
				zoom.y += zoomStepAmount

	if Input.is_action_pressed('resetScene'):
		resetTimer = 1
		resetSafe -= 1
		if resetSafe <= 0:
			get_tree().reload_current_scene()
