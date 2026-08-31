extends Marker2D

var player_inside = false
var action_button = "F"
var action_button_alt = "G"
var heal_price = 200
var spawn_price = 500
var spawn_created = false

@onready var player: Player = $"../../../player"
@onready var UI: UserInterface = $"../../../player/UI"
@onready var dialog: Control = $dialog
@onready var firepit_sprite: Sprite2D = $firepitVer2


func _unhandled_key_input(event: InputEvent) -> void:
	if player_inside:
		if !spawn_created:
			if event.is_action_pressed("actionButtonAlternative"):
				if UI.getPlayerSouls() >= spawn_price:
					UI.updateSoulsValue(-spawn_price)
					player.createSpawn(position)
					firepit_sprite.modulate = Color("ffffff")
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
		firepit_sprite.modulate = Color("000000")

	if UI.isControllerConnected():
		action_button = "RT"
		action_button_alt = "LT"
	else:
		action_button = "F"
		action_button_alt = "G"
	player_inside = true
	dialog.visible = true
	if !spawn_created:
		dialog.setText("Hoguera:\n \nRecuperar vida (" + action_button + ") = " + str(heal_price) + " Almas" + "\nCrear un checkpoint(" + action_button_alt + ") = " + str(spawn_price) + " Almas")
	else:
		dialog.setText("Hoguera:\n \nRecuperar vida (" + action_button + ") = " + str(heal_price) + " Almas" + "\nCheckpoint creado")


func _on_firepitCenterArea_body_exited(_body):
	player_inside = false
	dialog.visible = false
