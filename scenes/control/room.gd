extends Node2D

var roomCoord = Vector2(0,0)
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


onready var camera = get_node("../../cameras/roomCam")
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

func setTypeOfRoom(typeOfRoom):
	self.typeOfRoom = typeOfRoom
	
func getCellSize():
	cellSize = $TileMap.cell_size
	return cellSize
	
func setCoord(coordPos):
	self.roomCoord = coordPos

func getCoord():
#	return [self.coordX, self.coordY]
	return self.roomCoord

func getsetCorners(windowsSizeInBlocks, cellSize):
	#Esquina North/West y South/East de tipo vector2
	NW = Vector2(roomCoord.x * windowsSizeInBlocks.x, roomCoord.y * windowsSizeInBlocks.y)
	SE = Vector2(windowsSizeInBlocks.x + roomCoord.x * windowsSizeInBlocks.x, windowsSizeInBlocks.y + roomCoord.y * windowsSizeInBlocks.y)
	
	NWinPixels = NW * cellSize
	SEinPixels = SE * cellSize
	
	#El punto central de la sala es la suma de ambas esquinas (en Vector2) y dividirlo entre 2.
	roomCenterPoint = (NWinPixels + SEinPixels) / 2
	
	$NW.position = NWinPixels
	$SE.position = SEinPixels
	
#	print("roomCord: ", roomCoord)
#	print("roomCorners-> NW: ", NWinPixels, " SE: ", SEinPixels  )
	
#	# To make bigger rooms, need implemntation!
#	var middlePosition = Vector2(self.roomCoord.x*(SEinPixels.x-NWinPixels.x)*0.5, self.roomCoord.y*(SEinPixels.y-NWinPixels.y)*0.5)
#	print("midPos: ", middlePosition)
	$roomArea/CollisionShape2D.scale = $roomArea/CollisionShape2D.position/10 - Vector2.ONE*2 # We leave a margin to avoid bug in camera transition
#	print($Area2D/CollisionShape2D.scale)
	$roomArea/CollisionShape2D.position += NWinPixels
#	$Area2D/CollisionShape2D.scale = middlePosition*0.1

	return [NW, SE]

func _ready():
	pass # Replace with function body.

func drawBlockLine(startPosLine, finalPosLine, blockIndex): # only works form left-right or up-down, not in diagonal
	
	var dirLine = startPosLine.direction_to(finalPosLine)
	var distLine = startPosLine.distance_to(finalPosLine)

	if dirLine == Vector2.RIGHT:
		for block in range(0, distLine):
			$TileMap.set_cell(startPosLine.x + block, startPosLine.y, blockIndex)
	if dirLine == Vector2.DOWN:
		for block in range(0, distLine):
			$TileMap.set_cell(startPosLine.x, startPosLine.y + block, blockIndex)

	pass

func drawRoom(startCoord, finCoord, wallBlockType = 0, doorBlockType = 1):
#	print("--- Up Line ---")
#	print("startCoord: ",startCoord)
	var upCoord = Vector2(finCoord.x, startCoord.y)
#	print("upCoord: ", upCoord)

	drawBlockLine(startCoord, upCoord, wallBlockType)
	
#	print("--- Down Line ---")
#	print("startCoord: ",startCoord)
	var downCoordS = Vector2(startCoord.x, finCoord.y-1)
#	print("downCoordS: ", downCoordS)
	var downCoordF = Vector2(finCoord.x, finCoord.y-1)
#	print("downCoordF: ", downCoordF)

	drawBlockLine(downCoordS, downCoordF, wallBlockType)
	
#	print("--- Left Line ---")
	drawBlockLine(startCoord, downCoordS, wallBlockType)
	
#	print("--- Right Line ---")
#	var upCoordR = upCoord - Vector2.LEFT 
	drawBlockLine(upCoord - Vector2.RIGHT, downCoordF - Vector2.RIGHT, wallBlockType)

func addNeighbor(neighbor):
	self.neighbors.append(neighbor)

func makeCorridor(windowsSizeInBlocks):
	for neighbor in self.neighbors:
		self.dir = self.roomCoord.direction_to(neighbor)

		if self.dir == Vector2.LEFT:
			initCorridor = Vector2(roomCoord.x * windowsSizeInBlocks.x, roomCoord.y * windowsSizeInBlocks.y + 8)
			finCorridor = Vector2(roomCoord.x * windowsSizeInBlocks.x, roomCoord.y * windowsSizeInBlocks.y + 12)
			drawBlockLine(initCorridor,finCorridor,1)
			corridors.append([initCorridor * 32,0])
#			print(corridors["L"])

		if self.dir == Vector2.RIGHT:
			initCorridor = Vector2(roomCoord.x * windowsSizeInBlocks.x + windowsSizeInBlocks.x -1, roomCoord.y * windowsSizeInBlocks.y + 8)
			finCorridor = Vector2(roomCoord.x * windowsSizeInBlocks.x + windowsSizeInBlocks.x - 1, roomCoord.y * windowsSizeInBlocks.y + 12)
			drawBlockLine(initCorridor,finCorridor,1)
			corridors.append([initCorridor * 32,0])
			
		if self.dir == Vector2.DOWN:
			initCorridor = Vector2(roomCoord.x * windowsSizeInBlocks.x + 14, roomCoord.y * windowsSizeInBlocks.y + windowsSizeInBlocks.y - 1)
			finCorridor = Vector2(roomCoord.x * windowsSizeInBlocks.x + 18, roomCoord.y * windowsSizeInBlocks.y + windowsSizeInBlocks.y - 1)
			drawBlockLine(initCorridor,finCorridor,1)
			corridors.append([initCorridor * 32 + Vector2(0,32),-90])
			
		if self.dir == Vector2.UP:
			initCorridor = Vector2(roomCoord.x * windowsSizeInBlocks.x + 14, roomCoord.y * windowsSizeInBlocks.y)
			finCorridor = Vector2(roomCoord.x * windowsSizeInBlocks.x + 18, roomCoord.y * windowsSizeInBlocks.y )
			drawBlockLine(initCorridor,finCorridor,1)
			corridors.append([initCorridor * 32 + Vector2(0,32), -90])

func makeDoors():
	for corridor in corridors:	
		
		var doorObj = door.instance()
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
	var f = File.new()
	var aux
	var lastNumberDeaths
	if f.file_exists(user_file):
		f.open(user_file, File.READ)
		var index = 1
		while index != 3: # iterate through all lines until the end of file is reached
			if index == 1:
				aux = int(f.get_line())
			elif index == 2:
				lastNumberDeaths = int(f.get_line())
			index += 1
		f.close()

	return lastNumberDeaths

func _on_roomArea_body_entered(body):
	# when player node enters room area do:
	if body.name == "player":

		body.setActualRoom(self) # set player actual room
		camera.setCorners(NWinPixels, SEinPixels) # set camera corners 
		self.visible = true # room is now visible
		
		if typeOfRoom == "withEnemies":
			var playerDeaths = float(getPlayerDeaths())
			var x = playerDeaths/3
			var y = float(camera.getRoomsCleared())
			var enemyPressence = float((-50 - x)/ float(y + 12)) + 6
			var minimumEnemies = clamp(enemyPressence*0.90, 2, 7)
			var maximumEnemies = clamp(enemyPressence*1.4, 2, 7)
			createEnemies(enemyPressence, minimumEnemies, maximumEnemies) # default: create enemies between 1 and 4
			closeDoors()
		elif typeOfRoom == "cryptEntrance" and cryptNotCreated:
			var cryptObj = cryptStairs.instance()
			add_child(cryptObj)
			cryptObj.setup(roomCenterPoint)
			cryptNotCreated = false
		elif typeOfRoom == "firepitRoom" and firepitNotCreated:
			var firepitObj = firepit.instance()
			add_child(firepitObj)
			firepitObj.setup(roomCenterPoint)
			firepitNotCreated = false
		elif typeOfRoom == "final":
			var finalBoss1 = finalBoss.instance()
			add_child(finalBoss1)
			finalBoss1.setup(roomCenterPoint)
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
			print("Tipo de Sala: ", typeOfRoom)
			if typeOfRoom != "enemiesKilled" and typeOfRoom != "cryptEntrance" and typeOfRoom != "initial":
				camera.updateRoomsCleared(1)
				camera.updateRoomsLabel()
			typeOfRoom = "enemiesKilled"
			
			body.inputDisabled()
			var lastDir = body.getLastUsedDir().normalized()
			body.setPos(lastDir * 43)
		isPlayerDead = false

func createEnemies(enemyPressence, minNumEnemies = 1, maxNumEnemies = 4):
	var random = RandomNumberGenerator.new()
	random.randomize()
	enemiesToCreate = random.randi_range(minNumEnemies, maxNumEnemies)
	print("")
	print("Salas limpiadas: ", camera.getRoomsCleared())
	print("enemyPressence: ", enemyPressence, ". min: ", minNumEnemies, ". max: ", maxNumEnemies )
	print("Enemigos a crear: ", enemiesToCreate)
	print("")
	
	for enemyToCreate in enemiesToCreate:
		var enemyObj
		if enemyPressence > 2.5:
			enemyObj = hardEnemies[randi()%4].instance()
		else:
			enemyObj = baseEnemies[randi()%3].instance()
			
		add_child(enemyObj)
		var xMinMaxRoom = [NWinPixels.x+64, SEinPixels.x-96]
		var yMinMaxRoom = [NWinPixels.y+64, SEinPixels.y-96]
		
		enemyObj.setupSpawn(xMinMaxRoom, yMinMaxRoom)

func _on_checkRoomClear_timeout():
	enemyNodes = get_tree().get_nodes_in_group("Enemies")
	if enemyNodes.size() == 0: # room cleared
		$checkRoomClear.stop()
		if doorsClosed:
			openDoors()
