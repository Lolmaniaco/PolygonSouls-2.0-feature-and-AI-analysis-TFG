extends Position2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var active  = false
onready var player = get_node("../../../player")
onready var roomCam = get_node("../../../cameras/roomCam")
var actionButton = "F"
var actionAltButton = "G"
var healingPrice = 200
var spawnPointPrice = 500
var spawnAlreadyCreated = false

func _ready():
	pass # Replace with function body.

func setup(pos):
	position = pos

func _input(event):
	if active:
		# Create spawn
		if !spawnAlreadyCreated:
			if Input.is_action_just_pressed("actionButtonAlternative"):
				if roomCam.getPlayerSouls() >= spawnPointPrice:
					roomCam.updateSoulsValue(-spawnPointPrice)
					#print("New spawn created")
					player.createSpawn(position)
					$firepitVer2.modulate = Color("ffffff")
					spawnAlreadyCreated = true
		
		# Recharge health points to max
		if Input.is_action_just_pressed("actionButton"):
			if player.getHealth() < 100:
				if roomCam.getPlayerSouls() > healingPrice:
					roomCam.updateSoulsValue(-healingPrice)
				
					#print("Full heatlh")
					player.setHealth(100)

func _on_firepitCenterArea_body_entered(body):
	if player.getHasRespawn():
		spawnAlreadyCreated = false
		$firepitVer2.modulate = Color("000000")
		
	if roomCam.isControllerConnected():
		actionButton = "RT"
		actionAltButton = "LT"
	else:
		actionButton = "F"
		actionAltButton = "G"
	active = true
	$dialog.visible = true
	if !spawnAlreadyCreated:
		$dialog.setText("Hoguera:\n \nRecuperar vida (" + actionButton + ") = " + str(healingPrice) + " Almas" +  "\nCrear un checkpoint (" + actionAltButton + ") = " + str(spawnPointPrice) + " Almas")
	else:
		$dialog.setText("Hoguera:\n \nRecuperar vida (" + actionButton + ") = " + str(healingPrice) + " Almas" +  "\nCheckpoint creado")

func _on_firepitCenterArea_body_exited(body):
	active = false
	$dialog.visible = false
	
