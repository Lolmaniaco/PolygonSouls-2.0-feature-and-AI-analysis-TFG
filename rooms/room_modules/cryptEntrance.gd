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
			dialog.setText(
				TranslationServer.translate("GHOST") + "\n\n" + TranslationServer.translate("READY1") + "\n" + TranslationServer.translate("READY2") + actionButton + ")"
			)
		else:
			dialog.setText(
				TranslationServer.translate("GHOST") + "\n\n" + TranslationServer.translate("NOT_READY1") + "\n\n" +
				TranslationServer.translate("NOT_READY2") + str(target_rooms) + TranslationServer.translate("NOT_READY3")
			)


func _on_cryptArea_body_entered(_body):
	UI.activateColorInfo()
	if Global.getRoomsCleared() >= target_rooms:
		actionButton = "RT" if UI.controller_connected() else "F"
	active = true
	dialog.visible = true

	if not access_granted:
		if Global.getRoomsCleared() < target_rooms:
			dialog.setText(
				TranslationServer.translate("GHOST") + "\n\n" + TranslationServer.translate("WARNING1") + "\n" + TranslationServer.translate("ENTRANCE_NOT_READY") + str(target_rooms)
				+ TranslationServer.translate("WARNING2") + "\n\n" + TranslationServer.translate("WARNING3") + actionButton + ")"
			)
		else:
			dialog.setText(
				TranslationServer.translate("GHOST") + "\n\n" + TranslationServer.translate("WARNING1") + "\n" + TranslationServer.translate("ENTRANCE_READY") + str(target_rooms)
				+ TranslationServer.translate("WARNING2") + "\n\n" + TranslationServer.translate("WARNING3") + actionButton + ")"
			)
	else:
		dialog.setText(
			TranslationServer.translate("GHOST") + "\n\n" + TranslationServer.translate("READY1") + "\n\n" + TranslationServer.translate("READY2") + actionButton + ")")


func _on_cryptArea_body_exited(body):
	if body is Player:
		active = false
		dialog.visible = false
