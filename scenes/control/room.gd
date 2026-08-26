class_name RoomHandler
extends Node2D

var roomCoord = Vector2(0, 0)
var neighbors = []
var corridors = []

var NW
var SE
var dir
var initCorridor
var finCorridor

var NWinPixels
var SEinPixels
var windowsSizeInBlocks

var roomCenterPoint

var cellSize

var doorNodes = []
var enemyNodes
var kamikaze = preload("res://scenes/enemies/kamikaze.tscn")
var turret = preload("res://scenes/enemies/turret.tscn")
var spinEnemy = preload("res://scenes/enemies/spinEnemy.tscn")
var bouncer = preload("res://scenes/enemies/bouncer.tscn")
var finalBoss = preload("res://scenes/enemies/finalBoss.tscn")

var baseEnemies = [kamikaze, turret, bouncer]
var hardEnemies = [kamikaze, turret, spinEnemy, bouncer]

var door = preload("res://scenes/control/door.tscn")
var cryptStairs = preload("res://scenes/control/cryptEntrance.tscn")
var firepit = preload("res://scenes/control/firepit.tscn")

var enemiesToCreate
var typeOfRoom = "withEnemies"
var doorsClosed = true

var cryptNotCreated = true
var firepitNotCreated = true
var isPlayerDead = false
var roomsCleared = 0
var enteredFinalBossRoom = false

@onready var camera: RoomCamera = get_node("../../cameras/roomCam")

@onready var tile_map: TileMapLayer = $TileMap


func setTypeOfRoom(newRoom):
	typeOfRoom = newRoom


func getCellSize():
	cellSize = Vector2(tile_map.tile_set.tile_size)
	return cellSize


func setCoord(coordPos):
	roomCoord = coordPos
	position = coordPos * Vector2(1152, 640)


func getCoord():
#	return [coordX, coordY]
	return roomCoord


func getsetCorners(sizeInBlocks, new_cellSize):
	#Esquina North/West y South/East de tipo vector2
	NW = Vector2(sizeInBlocks.x * roomCoord.x, sizeInBlocks.y * roomCoord.y)
	SE = Vector2(sizeInBlocks.x * roomCoord.x + sizeInBlocks.x, sizeInBlocks.y * roomCoord.y + sizeInBlocks.y)

	NWinPixels = NW * new_cellSize
	SEinPixels = SE * new_cellSize

	#El punto central de la sala es la suma de ambas esquinas (en Vector2) y dividirlo entre 2.
	roomCenterPoint = (NWinPixels + SEinPixels) / 2

	$NW.position = NWinPixels
	$SE.position = SEinPixels

#	print("roomCord: ", roomCoord)
#	print("roomCorners-> NW: ", NWinPixels, " SE: ", SEinPixels  )

#	# To make bigger rooms, need implemntation!
#	var middlePosition = Vector2(roomCoord.x*(SEinPixels.x-NWinPixels.x)*0.5, roomCoord.y*(SEinPixels.y-NWinPixels.y)*0.5)
#	print("midPos: ", middlePosition)
#	$Area2D/CollisionShape2D.scale = middlePosition*0.1

	return [NW, SE]


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


func makeCorridor(sizeInBlocks):
	for neighbor in neighbors:
		dir = roomCoord.direction_to(neighbor)

		if dir == Vector2.LEFT:
			initCorridor = Vector2(roomCoord.x, roomCoord.y + 9)
			finCorridor = Vector2(roomCoord.x, roomCoord.y + 12)
			drawBlockLine(initCorridor, finCorridor, 1)
			corridors.append([Vector2(16, 320), 0])
#			print(corridors["L"])

		if dir == Vector2.RIGHT:
			initCorridor = Vector2(roomCoord.x + sizeInBlocks.x - 1, roomCoord.y + 8)
			finCorridor = Vector2(roomCoord.x + sizeInBlocks.x - 1, roomCoord.y + 12)
			drawBlockLine(initCorridor, finCorridor, 1)
			corridors.append([Vector2(1136, 320), 0])

		if dir == Vector2.DOWN:
			initCorridor = Vector2(16, 20)
			finCorridor = Vector2(20, 20)
			drawBlockLine(initCorridor, finCorridor, 1)
			corridors.append([Vector2(576, 624), -90])

		if dir == Vector2.UP:
			initCorridor = Vector2(roomCoord.x + 16, roomCoord.y)
			finCorridor = Vector2(roomCoord.x + 20, roomCoord.y)
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
	var aux
	var lastNumberDeaths

	var index = 1
	while index != 3: # iterate through all lines until the end of file is reached
		if index == 1:
			aux = int(f.get_line())
		elif index == 2:
			lastNumberDeaths = int(f.get_line())
		index += 1
	f.close()

	return lastNumberDeaths


func createEnemies(enemyPressence, minNumEnemies = 1, maxNumEnemies = 4):
	var random = RandomNumberGenerator.new()
	random.randomize()
	enemiesToCreate = random.randi_range(minNumEnemies, maxNumEnemies)
	print("")
	print("Salas limpiadas: ", camera.getRoomsCleared())
	print("enemyPressence: ", enemyPressence, ". min: ", minNumEnemies, ". max: ", maxNumEnemies)
	print("Enemigos a crear: ", enemiesToCreate)
	print("")

	for enemyToCreate in enemiesToCreate:
		var enemyObj
		if enemyPressence > 2.5:
			enemyObj = hardEnemies[randi() % 4].instantiate()
		else:
			enemyObj = baseEnemies[randi() % 3].instantiate()

		add_child(enemyObj)
		var xMinMaxRoom = [64, 1152 - 64]
		var yMinMaxRoom = [64, 640 - 96]

		enemyObj.setupSpawn(xMinMaxRoom, yMinMaxRoom)


func _on_roomArea_body_entered(body):
	# when player node enters room area do:
	if body.name == "player":
		print("ENTERING ", name)
		body.setActualRoom(self) # set player actual room
		camera.setCorners(NWinPixels, SEinPixels) # set camera corners 
		visible = true # room is now visible

		if typeOfRoom == "withEnemies":
			var playerDeaths = float(getPlayerDeaths())
			var x = playerDeaths / 3
			var y = float(camera.getRoomsCleared())
			var enemyPressence = float((-50 - x) / float(y + 12)) + 6
			var minimumEnemies = clamp(enemyPressence * 0.90, 2, 7)
			var maximumEnemies = clamp(enemyPressence * 1.4, 2, 7)
			createEnemies(enemyPressence, minimumEnemies, maximumEnemies) # default: create enemies between 1 and 4
			closeDoors()
		elif typeOfRoom == "cryptEntrance" and cryptNotCreated:
			var cryptObj = cryptStairs.instantiate()
			add_child(cryptObj)
			cryptObj.setup(roomCenterPoint)
			cryptNotCreated = false
		elif typeOfRoom == "firepitRoom" and firepitNotCreated:
			var firepitObj = firepit.instantiate()
			add_child(firepitObj)
			firepitObj.setup(roomCenterPoint)
			firepitNotCreated = false
		elif typeOfRoom == "final":
			var finalBoss1 = finalBoss.instantiate()
			add_child(finalBoss1)
			finalBoss1.setup(roomCenterPoint)
			enteredFinalBossRoom = true
		else:
			pass

		$checkRoomClear.start()


func _on_roomArea_body_exited(body):
	if body.name == "player":
		print("EXITING ", name)
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
			print("Tipo de Sala: ", typeOfRoom)
			if typeOfRoom != "enemiesKilled" and typeOfRoom != "cryptEntrance" and typeOfRoom != "initial":
				camera.updateRoomsCleared(1)
				camera.updateRoomsLabel()
			typeOfRoom = "enemiesKilled"

			body.inputDisabled()
			var lastDir = body.getLastUsedDir().normalized()
			body.setPos(lastDir * 43)
		isPlayerDead = false


func _on_checkRoomClear_timeout():
	enemyNodes = get_tree().get_nodes_in_group("Enemies")
	if enemyNodes.size() == 0: # room cleared
		$checkRoomClear.stop()
		if doorsClosed:
			openDoors()
