extends Marker2D

const ENTERING_CRYPT = preload("uid://cg32g7n3131tv")
const OPEN_CRYPT = preload("uid://xvbxwq0whjin")

var active: bool = false
var actionButton: String = "F"
var access_granted: bool = false
var target_rooms: int = 0

@onready var player: Player = $"../../../player"
@onready var UI: UserInterface = $"../../../player/UI"
@onready var dialog: Control = $dialog
@onready var sfx: AudioStreamPlayer = $sfx


func _ready():
	target_rooms = roundi(Utils.MAX_ROOMS * 0.7)


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return

	if event.is_action_pressed("actionButton"):
		if access_granted:
			sfx.stream = ENTERING_CRYPT
			sfx.play()
			player.position = Vector2(11520 + 200, 6400 + 200)
			return

		actionButton = "RT" if UI.controller_connected() else "F"

		if Global.getRoomsCleared() >= target_rooms:
			sfx.stream = OPEN_CRYPT
			sfx.play()
			access_granted = true
			dialog.setText("Fantasma de la Cripta:\n\nBuena suerte, paladín de la luz. Eres nuestra última esperanza.\n\nENTRAR A LA CRIPTA (" + actionButton + ")")
		else:
			dialog.setText("Fantasma de la Cripta:\n\nLo siento, paladín de la luz. Parece que aún no es el momento para combatir.\n\n[color=red]Vuelve cuando hayas superado " + str(target_rooms) + " salas.[/color]")


func _on_cryptArea_body_entered(_body):
	UI.activateColorInfo()
	if Global.getRoomsCleared() >= target_rooms:
		actionButton = "RT" if UI.controller_connected() else "F"
	active = true
	dialog.visible = true

	if not access_granted:
		if Global.getRoomsCleared() < target_rooms:
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
