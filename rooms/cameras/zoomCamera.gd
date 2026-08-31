extends Camera2D

@export var zoomStepAmount: float = 0.25
@export var maxZoomIn: float = 1.0

var first_pos = Vector2()


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
