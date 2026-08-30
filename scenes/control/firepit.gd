extends Marker2D

var active = false
var actionButton = "F"
var actionAltButton = "G"
var heal_price = 200
var spawn_price = 500
var spawn_created = false

@onready var player: Player = $"../../../player"
@onready var UI: UserInterface = $"../../../player/UI"


func _unhandled_key_input(event: InputEvent) -> void:
	if active:
		if !spawn_created:
			if event.is_action_pressed("actionButtonAlternative"):
				if UI.getPlayerSouls() >= spawn_price:
					UI.updateSoulsValue(-spawn_price)
					player.createSpawn(position)
					$firepitVer2.modulate = Color("ffffff")
					spawn_created = true

		if event.is_action_pressed("actionButton"):
			if player.getHealth() < 100:
				if UI.getPlayerSouls() >= heal_price:
					UI.updateSoulsValue(-heal_price)
					player.restore_health()


func setup(pos):
	position = pos


func _on_firepitCenterArea_body_entered(_body):
	if player.get_respawn():
		spawn_created = false
		$firepitVer2.modulate = Color("000000")

	if UI.isControllerConnected():
		actionButton = "RT"
		actionAltButton = "LT"
	else:
		actionButton = "F"
		actionAltButton = "G"
	active = true
	$dialog.visible = true
	if !spawn_created:
		$dialog.setText("Hoguera:\n \nRecuperar vida (" + actionButton + ") = " + str(heal_price) + " Almas" + "\nCrear un checkpoint(" + actionAltButton + ") = " + str(spawn_price) + " Almas")
	else:
		$dialog.setText("Hoguera:\n \nRecuperar vida (" + actionButton + ") = " + str(heal_price) + " Almas" + "\nCheckpoint creado")


func _on_firepitCenterArea_body_exited(_body):
	active = false
	$dialog.visible = false
