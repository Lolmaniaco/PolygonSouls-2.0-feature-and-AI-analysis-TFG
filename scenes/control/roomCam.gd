extends Camera2D

export (int) var maxRooms = 12

var NW = Vector2(0,0)
var SE = Vector2(1024, 640)
var soulsCollected = 0
var roomsCleared = 0
var controllerConnected = false
var time
var colorIndicator = false

func setCorners(NW, SE):
	self.NW = NW
	self.SE = SE
	
	self.position = NW

func getCamPos():
	return self.position

func _ready():
	time = 0

func isControllerConnected():
	return controllerConnected
	
func gameWon():
	var t = Timer.new()
	t.set_wait_time(3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	get_tree().change_scene("res://scenes/control/gameFinished.tscn")
	#$timeComplete.text = "El mal ha sido purgado en " + $gameTime.text + " minutos."
	#$timeComplete.visible = true
	#$gameTime.visible = false

func getMaxRooms():
	return maxRooms
	
func updateRoomsCleared(value):
	self.roomsCleared += value

func getRoomsCleared():
	return self.roomsCleared
	
func updateSoulsValue(amount):
	self.soulsCollected += amount
	updateSoulsLabel()
	
func updateSoulsLabel():
	$soulsCollected.text = str(self.soulsCollected) + " Almas"

func updateRoomsLabel():
	$clearedRooms.text = str(self.roomsCleared) + " Salas"
	if colorIndicator:
		if roomsCleared <= (maxRooms * 0.7) - 1: 
			$clearedRooms.self_modulate = "#ff0000"
		else:
			$clearedRooms.self_modulate = "#3990d6"

func getPlayerSouls():
	return self.soulsCollected

func activateColorInfo():
	colorIndicator = true
	updateRoomsLabel()

func _process(delta):
	if Input.get_connected_joypads().size() > 0:
		controllerConnected = true
	else:
		controllerConnected = false

	time += delta
	var seconds = fmod(time,60)
	var minutes = fmod(time, 3600) / 60
	GlobalVariables.time = "%02d:%02d" % [minutes, seconds]
	$gameTime.text = str(GlobalVariables.time)

