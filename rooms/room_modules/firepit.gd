extends Marker2D

const HEAL_UP = preload("uid://bo1d82ud8lp85")
const LIGHT_UP_FIRE = preload("uid://c3n71qnrhc2dh")

var action_button = "F"
var action_button_alt = "G"
var heal_price = 200
var spawn_price = 500
var player: Player = null

@onready var dialog: Control = $dialog
@onready var firepit_sprite: Sprite2D = $firepitVer2
@onready var sfx: AudioStreamPlayer = $sfx
@onready var smoke: GPUParticles2D = $smoke
@onready var firepit: AnimatedSprite2D = $firepit

func _unhandled_key_input(event: InputEvent) -> void:
	if not player:
		return

	if not player.has_checkpoint():
		if event.is_action_pressed("actionButtonAlternative") and Global.getPlayerSouls() >= spawn_price:
			Global.updateSoulsValue(-spawn_price)
			player.create_checkpoint(position)
			firepit_sprite.modulate = Color.WHITE
			sfx.stream = LIGHT_UP_FIRE
			sfx.play()
			firepit.play("default")
			smoke.emitting = true

	if event.is_action_pressed("actionButton"):
		if player.getHealth() < 100 and Global.getPlayerSouls() >= heal_price:
			Global.updateSoulsValue(-heal_price)
			player.restore_health()
			sfx.stream = HEAL_UP
			sfx.play()


func _on_firepitCenterArea_body_entered(body):
	if not body is Player:
		return

	player = body
	dialog.visible = true

	if player.UI.controller_connected():
		action_button = "RT"
		action_button_alt = "LT"
	else:
		action_button = "F"
		action_button_alt = "G"

	var info: String = "Hoguera:\n \nRecuperar vida (" + action_button + ") = " + str(heal_price) + " Almas" + "\n"
	if not player.has_checkpoint():
		info += "Crear un checkpoint(" + action_button_alt + ") = " + str(spawn_price) + " Almas"
	else:
		info += "Checkpoint creado."
	dialog.setText(info)


func _on_firepitCenterArea_body_exited(body):
	if not body is Player:
		return

	player = null
	dialog.visible = false
