extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (float) var zoomStepAmount = 0.25


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var first_pos = Vector2()
var resetSafe = 10
var resetTimer = 1

export (float) var maxZoomIn = 1.0 # 1.0 to keep dispaly size, 0.1 to zoom in max without camera being black
var pressedM = false

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				if zoom.x - zoomStepAmount >= maxZoomIn: # works only if zoomX and zoomy are equal
					# call the zoom function
					zoom.x -= zoomStepAmount
					zoom.y -= zoomStepAmount
				
			# zoom out
			if event.button_index == BUTTON_WHEEL_DOWN:
				
				# call the zoom function
				zoom.x += zoomStepAmount
				zoom.y += zoomStepAmount
			

#			if event.button_index == BUTTON_MIDDLE:
#				first_pos = event.position
	if Input.is_action_pressed('resetScene'):
		resetTimer = 1
		resetSafe -= 1
		if resetSafe <= 0:
			get_tree().reload_current_scene()

func _process(delta):
	if resetTimer <= 0:
		resetSafe = 10
	else:
		resetTimer -= delta
