extends Marker2D

var active: bool = false
var actionButton: String = "F"
var access_granted: bool = false
var target_rooms: int = 0

@onready var player: Player = $"../../../player"
@onready var UI: UserInterface = $"../../../player/UI"
@onready var dialog: Control = $dialog


func _ready():
	target_rooms = roundi(UI.getMaxRooms() * 0.7)


func _input(_event):
	if active:
		if Input.is_action_just_pressed("actionButton"):
			if access_granted:
				player.position = Vector2(11520 + 200, 6400 + 200)

			actionButton = "RT" if UI.isControllerConnected() else "F"

			if UI.getRoomsCleared() >= target_rooms:
				access_granted = true
				dialog.setText("Fantasma de la Cripta:\n\nBuena suerte, paladín de la luz. Eres nuestra última esperanza.\n\nENTRAR A LA CRIPTA (" + actionButton + ")")
			else:
				dialog.setText("Fantasma de la Cripta:\n\nLo siento, paladín de la luz. Parece que aún no es el momento para combatir.\n\n[color=red]Vuelve cuando hayas superado " + str(target_rooms) + " salas.[/color]")


func setup(pos):
	position = pos


func _on_cryptArea_body_entered(_body):
	UI.activateColorInfo()
	if UI.getRoomsCleared() >= target_rooms:
		actionButton = "RT" if UI.isControllerConnected() else "F"
	active = true
	dialog.visible = true

	if !access_granted:
		if UI.getRoomsCleared() < target_rooms:
			dialog.setText(
				"Fantasma de la Cripta:\n\n¿Podrás vencer a la oscuridad que puebla estas tierras?\n[color=red](Limpia " + str(target_rooms) + " salas)[/color]\n\nQUIERO PELEAR(" + actionButton + ")")
		else:
			dialog.setText("Fantasma de la Cripta:\n\n¿Podrás vencer a la oscuridad que puebla estas tierras?\n[color=#3990d6](Limpia " + str(target_rooms) + " salas)[/color]\n\nQUIERO PELEAR(" + actionButton + ")")
	else:
		dialog.setText(
			"Fantasma de la Cripta:\n\nBuena suerte, paladín de la luz.\n\nENTRAR A LA CRIPTA (" + actionButton + ")")


func _on_cryptArea_body_exited(body):
	if body is Player:
		active = false
		dialog.visible = false
