extends Marker2D

var active = false
var actionButton = "F"
var cryptEntranceFee = 1000
var cryptAccessGranted = false
var objectiveRooms

@onready var roomCam = get_node("../../../cameras/roomCam")
@onready var player = get_node("../../../player")


func _ready():
	objectiveRooms = int(roomCam.getMaxRooms() * 0.7)


func _input(_event):
	if active:
		if Input.is_action_just_pressed("actionButton"):
			if cryptAccessGranted:
				player.position = Vector2(11 * 1024 - 200, 11 * 640 - 200)

			if roomCam.getRoomsCleared() >= objectiveRooms:
				if roomCam.isControllerConnected():
					actionButton = "RT"
				else:
					actionButton = "F"

				cryptAccessGranted = true
				$dialog.setText("Fantasma de la Cripta:\n\nBuena suerte, paladín de la luz. Eres nuestra última esperanza.\n\nENTRAR A LA CRIPTA (" + actionButton + ")")
			else:
				if roomCam.isControllerConnected():
					actionButton = "RT"
				else:
					actionButton = "F"
				$dialog.setText("Fantasma de la Cripta:\n\nLo siento, paladín de la luz. Parece que aún no es el momento para combatir.\n\n[color=red]Vuelve cuando hayas superado " + String(objectiveRooms) + " salas.[/color]")


func setup(pos):
	position = pos


func _on_cryptArea_body_entered(_body):
	roomCam.activateColorInfo()
	if roomCam.getRoomsCleared() >= 7:
		if roomCam.isControllerConnected():
			actionButton = "RT"
		else:
			actionButton = "F"
	active = true
	$dialog.visible = true
	if !cryptAccessGranted:
		if roomCam.getRoomsCleared() < objectiveRooms:
			$dialog.setText("Fantasma de la Cripta:\n\n¿Podrás vencer a la oscuridad que puebla estas tierras?\n[color=red](Limpia " + String(objectiveRooms) + " salas)[/color]\n\nQUIERO PELEAR (" + actionButton + ")")
		else:
			$dialog.setText("Fantasma de la Cripta:\n\n¿Podrás vencer a la oscuridad que puebla estas tierras?\n[color=#3990d6](Limpia " + String(objectiveRooms) + " salas)[/color]\n\nQUIERO PELEAR (" + actionButton + ")")
	else:
		$dialog.setText("Fantasma de la Cripta:\n\nBuena suerte, paladín de la luz.\n\nENTRAR A LA CRIPTA (" + actionButton + ")")


func _on_cryptArea_body_exited(_body):
	active = false
	$dialog.visible = false


func _on_dialog_gui_input(_event):
	pass
