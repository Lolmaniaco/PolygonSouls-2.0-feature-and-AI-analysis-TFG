extends Marker2D

var active: bool = false
var actionButton: String = "F"
var access_granted: bool = false
var target_rooms: int = 0

@onready var roomCam: RoomCamera = $"../../../cameras/roomCam"
@onready var player: Player = $"../../../player"


func _ready():
	target_rooms = int(roomCam.getMaxRooms() * 0.7)


func _input(_event):
	if active:
		if Input.is_action_just_pressed("actionButton"):
			if access_granted:
				player.position = Vector2(11 * 1024 - 200, 11 * 640 - 200)

			actionButton = "F" if roomCam.isControllerConnected() else "RT"

			if roomCam.getRoomsCleared() >= target_rooms:
				access_granted = true
				$dialog.setText("Fantasma de la Cripta:\n\n
				Buena suerte, paladín de la luz. Eres nuestra última esperanza.\n\n
				ENTRAR A LA CRIPTA (" + actionButton + ")")
			else:
				$dialog.setText("Fantasma de la Cripta:\n\n
				Lo siento, paladín de la luz. Parece que aún no es el momento para combatir.\n\n
				[color=red]Vuelve cuando hayas superado " + str(target_rooms) + " salas.[/color]")


func setup(pos):
	position = pos


func _on_cryptArea_body_entered(_body):
	roomCam.activateColorInfo()
	if roomCam.getRoomsCleared() >= target_rooms:
		actionButton = "F" if roomCam.isControllerConnected() else "RT"
	active = true
	$dialog.visible = true

	if !access_granted:
		if roomCam.getRoomsCleared() < target_rooms:
			$dialog.setText("Fantasma de la Cripta:\n\n
			¿Podrás vencer a la oscuridad que puebla estas tierras?\n
			[color=red](Limpia " + str(target_rooms) + " salas)[/color]\n\n
			QUIERO PELEAR(" + actionButton + ")")
		else:
			$dialog.setText("Fantasma de la Cripta:\n\n
			¿Podrás vencer a la oscuridad que puebla estas tierras?\n
			[color=#3990d6](Limpia " + str(target_rooms) + " salas)[/color]\n\n
			QUIERO PELEAR(" + actionButton + ")")
	else:
		$dialog.setText("Fantasma de la Cripta:\n\n
		Buena suerte, paladín de la luz.\n\n
		ENTRAR A LA CRIPTA (" + actionButton + ")")


func _on_cryptArea_body_exited(body):
	if body is Player:
		active = false
		$dialog.visible = false
