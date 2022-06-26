extends Sprite


var initialRoomController = preload("res://img/controlsVer2 Controller.png")
var initialRoom = preload("res://img/controlsVer2.png")

func _ready():
	pass # Replace with function body.


func _process(delta):
	if 	Input.get_connected_joypads().size() > 0:
		set_texture(initialRoomController)
	else:
		set_texture(initialRoom)
