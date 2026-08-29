class_name RoomHandler
extends Node2D

var roomCoord = Vector2(0, 0)
var neighbors = []
var corridors = []

var doorNodes = []
var enemyNodes

var typeOfRoom = "common"
var doorsClosed = true

var cryptNotCreated = true
var firepitNotCreated = true
var isPlayerDead = false
var enteredFinalBossRoom = false

@onready var kamikaze = preload("res://scenes/enemies/kamikaze.tscn")
@onready var turret = preload("res://scenes/enemies/turret.tscn")
@onready var spinEnemy = preload("res://scenes/enemies/spinEnemy.tscn")
@onready var bouncer = preload("res://scenes/enemies/bouncer.tscn")
@onready var finalBoss = preload("res://scenes/enemies/finalBoss.tscn")

@onready var baseEnemies = [kamikaze, kamikaze, kamikaze]
@onready var hardEnemies = [kamikaze, turret, spinEnemy, bouncer]

@onready var door = preload("res://scenes/control/door.tscn")
@onready var camera: RoomCamera = get_node("../../cameras/roomCam")
@onready var tile_map: TileMapLayer = $TileMap


func setTypeOfRoom(newRoom):
	typeOfRoom = newRoom
	name = newRoom + " Room"


func setCoord(coordPos):
	roomCoord = coordPos
	position = coordPos * Vector2(1152, 640)


func getCoord():
#	return [coordX, coordY]
	return roomCoord


func drawBlockLine(startPosLine, finalPosLine, blockIndex): # only works form left-right or up-down, not in diagonal
	var dirLine = startPosLine.direction_to(finalPosLine)
	var distLine = startPosLine.distance_to(finalPosLine)

	if dirLine == Vector2.RIGHT:
		for block in range(0, distLine):
			tile_map.set_cell(Vector2i(startPosLine.x + block, startPosLine.y), 0, Vector2i(blockIndex, 0))
	if dirLine == Vector2.DOWN:
		for block in range(0, distLine):
			tile_map.set_cell(Vector2i(startPosLine.x, startPosLine.y + block), 0, Vector2i(blockIndex, 0))


func drawRoom(startCoord, finCoord, wallBlockType = 0, _doorBlockType = 1):
#	print("--- Up Line ---")
#	print("startCoord: ",startCoord)
	var upCoord = Vector2(finCoord.x, startCoord.y)
#	print("upCoord: ", upCoord)

	drawBlockLine(startCoord, upCoord, wallBlockType)

#	print("--- Down Line ---")
#	print("startCoord: ",startCoord)
	var downCoordS = Vector2(startCoord.x, finCoord.y - 1)
#	print("downCoordS: ", downCoordS)
	var downCoordF = Vector2(finCoord.x, finCoord.y - 1)
#	print("downCoordF: ", downCoordF)

	drawBlockLine(downCoordS, downCoordF, wallBlockType)

#	print("--- Left Line ---")
	drawBlockLine(startCoord, downCoordS, wallBlockType)

#	print("--- Right Line ---")
#	var upCoordR = upCoord - Vector2.LEFT 
	drawBlockLine(upCoord - Vector2.RIGHT, downCoordF - Vector2.RIGHT, wallBlockType)


func addNeighbor(neighbor):
	neighbors.append(neighbor)


func makeCorridor(_sizeInBlocks):
	var initCorridor: Vector2
	var finCorridor: Vector2

	for neighbor in neighbors:
		var dir = roomCoord.direction_to(neighbor)

		if dir == Vector2.LEFT:
			initCorridor = Vector2(0, 8)
			finCorridor = Vector2(0, 12)
			drawBlockLine(initCorridor, finCorridor, 1)
			corridors.append([Vector2(16, 320), 0])
#			print(corridors["L"])

		elif dir == Vector2.RIGHT:
			initCorridor = Vector2(35, 8)
			finCorridor = Vector2(35, 12)
			drawBlockLine(initCorridor, finCorridor, 1)
			corridors.append([Vector2(1136, 320), 0])

		elif dir == Vector2.DOWN:
			initCorridor = Vector2(16, 19)
			finCorridor = Vector2(20, 19)
			drawBlockLine(initCorridor, finCorridor, 1)
			corridors.append([Vector2(576, 624), -90])

		elif dir == Vector2.UP:
			initCorridor = Vector2(16, 0)
			finCorridor = Vector2(20, 0)
			drawBlockLine(initCorridor, finCorridor, 1)
			corridors.append([Vector2(576, 16), -90])


func makeDoors():
	for corridor in corridors:
		var doorObj: Door = door.instantiate()
		add_child(doorObj)
		doorObj.setup(corridor[0], corridor[1])

		doorNodes.append(doorObj)
#	doorNodes = get_tree().get_nodes_in_group("Doors")


func openDoors():
	for doorNode in doorNodes:
		doorNode.playDoorAnimation(true) # to open
	doorsClosed = false


func closeDoors():
	for doorNode in doorNodes:
		doorNode.playDoorAnimation(false) # to close
	doorsClosed = true


func getPlayerDeaths():
	var user_file = "res://score.txt"
	var f = FileAccess.open(user_file, FileAccess.READ)
	var lastNumberDeaths

	var index = 1
	while index != 3: # iterate through all lines until the end of file is reached
		if index == 1:
			f.get_line()
		elif index == 2:
			lastNumberDeaths = int(f.get_line())
		index += 1
	f.close()

	return lastNumberDeaths


func createEnemies(enemyPressence, minNumEnemies = 1, maxNumEnemies = 4):
	var enemiesToCreate: int = randi_range(minNumEnemies, maxNumEnemies)

	for i in enemiesToCreate:
		var enemyObj: Enemy
		var idx: int
		if enemyPressence > 2.5:
			idx = randi_range(0, 3)
			enemyObj = hardEnemies[idx].instantiate()
		else:
			idx = randi_range(0, 2)
			enemyObj = baseEnemies[idx].instantiate()

		enemyObj.position = Vector2(randi_range(192, 960), randi_range(192, 448))
		call_deferred("add_child", enemyObj)

		var spawn_point: ColorRect = ColorRect.new()
		spawn_point.size = Vector2(10, 10)
		spawn_point.color = Color.WHITE
		call_deferred("add_child", spawn_point)
		spawn_point.position = enemyObj.position


func _on_roomArea_body_entered(body):
	# when player node enters room area do:
	if body.name == "player":
		camera.position = roomCoord * Vector2(1152, 640)
		visible = true # room is now visible

		if typeOfRoom == "common":
			var playerDeaths = float(getPlayerDeaths())
			var x = playerDeaths / 3
			var y = float(camera.getRoomsCleared())
			var enemyPressence = float((-50 - x) / float(y + 12)) + 6
			var minimumEnemies = clamp(enemyPressence * 0.90, 2, 7)
			var maximumEnemies = clamp(enemyPressence * 1.4, 2, 7)
			createEnemies(enemyPressence, minimumEnemies, maximumEnemies) # default: create enemies between 1 and 4
			closeDoors()
		elif typeOfRoom == "boss" and cryptNotCreated:
			cryptNotCreated = false
		elif typeOfRoom == "firepit" and firepitNotCreated:
			firepitNotCreated = false
		elif typeOfRoom == "final":
			var finalBoss1 = finalBoss.instantiate()
			call_deferred("add_child", finalBoss1)
			finalBoss1.setup(Vector2(576, 320))
			enteredFinalBossRoom = true
		else:
			pass

		$checkRoomClear.start()


func _on_roomArea_body_exited(body):
	if body.name == "player":
		# Used only when player dies 
		if enemyNodes != null:
			if enemyNodes.size() > 0:
				#for enemyNode in enemyNodes:
					#remove_child(enemyNode)
				isPlayerDead = true
				#$checkRoomClear.stop()
				if doorsClosed:
					openDoors()

		if isPlayerDead == false:
			if typeOfRoom != "enemiesKilled" and typeOfRoom != "boss" and typeOfRoom != "initial":
				camera.updateRoomsCleared(1)
				camera.updateRoomsLabel()
			typeOfRoom = "enemiesKilled"

			body.inputDisabled()

		isPlayerDead = false


func _on_checkRoomClear_timeout():
	enemyNodes = get_tree().get_nodes_in_group("Enemies")
	if enemyNodes.size() == 0: # room cleared
		$checkRoomClear.stop()
		if doorsClosed:
			openDoors()
