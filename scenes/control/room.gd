class_name RoomHandler
extends Node2D

const TURRET = preload("uid://d6hqfkgirjyl")
const KAMIKAZE = preload("uid://cbocpuwmn6qsf")
const BOUNCER = preload("uid://cjhy5jdp4knd4")
const SPIN_ENEMY = preload("uid://c7dq5i3oueuk")
const FINAL_BOSS = preload("uid://bw3k6flp2e5o1")

var roomCoord = Vector2(0, 0)
var neighbors = []
var corridors = []

var doorNodes: Array[Door] = []
var enemyNodes: Array = []

var typeOfRoom = "common"
var doorsClosed = true

var cryptNotCreated = true
var firepitNotCreated = true
var isPlayerDead = false

@onready var baseEnemies = [SPIN_ENEMY, SPIN_ENEMY, SPIN_ENEMY]
@onready var hardEnemies = [KAMIKAZE, TURRET, BOUNCER, SPIN_ENEMY]

@onready var door = preload("res://scenes/control/door.tscn")
@onready var tile_map: TileMapLayer = $TileMap
@onready var room_cam: Camera2D = $"../../cameras/roomCam"
@onready var UI: UserInterface = $"../../player/UI"
@onready var enemy_nodes: Node2D = $EnemyNodes


func setTypeOfRoom(newRoom):
	typeOfRoom = newRoom
	name = newRoom + " Room"


func setCoord(coordPos):
	roomCoord = coordPos
	position = coordPos * Vector2(1152, 640)


func getCoord():
	return roomCoord


func drawBlockLine(startPosLine, finalPosLine, blockIndex):
	var dirLine = startPosLine.direction_to(finalPosLine)
	var distLine = startPosLine.distance_to(finalPosLine)

	if dirLine == Vector2.RIGHT:
		for block in range(0, distLine):
			tile_map.set_cell(Vector2i(startPosLine.x + block, startPosLine.y), 0, Vector2i(blockIndex, 0))
	if dirLine == Vector2.DOWN:
		for block in range(0, distLine):
			tile_map.set_cell(Vector2i(startPosLine.x, startPosLine.y + block), 0, Vector2i(blockIndex, 0))


func drawRoom(startCoord, finCoord, wallBlockType = 0, _doorBlockType = 1):
	var upCoord = Vector2(finCoord.x, startCoord.y)
	drawBlockLine(startCoord, upCoord, wallBlockType)

	var downCoordS = Vector2(startCoord.x, finCoord.y - 1)
	var downCoordF = Vector2(finCoord.x, finCoord.y - 1)

	drawBlockLine(downCoordS, downCoordF, wallBlockType)
	drawBlockLine(startCoord, downCoordS, wallBlockType)
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


func openDoors():
	for doorNode in doorNodes:
		doorNode.playDoorAnimation(true)
	doorsClosed = false


func closeDoors():
	for doorNode in doorNodes:
		doorNode.playDoorAnimation(false)
	doorsClosed = true


func getPlayerDeaths():
	var user_file = "user://score.txt"
	var f = FileAccess.open(user_file, FileAccess.READ)
	var lastNumberDeaths

	var index = 1
	while index != 3:
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
		enemy_nodes.call_deferred("add_child", enemyObj)

		var spawn_point: ColorRect = ColorRect.new()
		spawn_point.size = Vector2(10, 10)
		spawn_point.color = Color.WHITE
		call_deferred("add_child", spawn_point)
		spawn_point.position = enemyObj.position
	
	enemyNodes = enemy_nodes.get_children()


func _on_roomArea_body_entered(body):
	if body.name == "player":
		room_cam.position = roomCoord * Vector2(1152, 640)
		visible = true

		if typeOfRoom == "common":
			var playerDeaths = float(getPlayerDeaths())
			var x = playerDeaths / 3
			var y = float(UI.getRoomsCleared())
			var enemyPressence = float((-50 - x) / float(y + 12)) + 6
			var minimumEnemies = clamp(enemyPressence * 0.90, 2, 7)
			var maximumEnemies = clamp(enemyPressence * 1.4, 2, 7)
			createEnemies(enemyPressence, minimumEnemies, maximumEnemies)
			closeDoors()
		elif typeOfRoom == "boss" and cryptNotCreated:
			cryptNotCreated = false
		elif typeOfRoom == "firepit" and firepitNotCreated:
			firepitNotCreated = false
		elif typeOfRoom == "final":
			var boss = FINAL_BOSS.instantiate()
			call_deferred("add_child", boss)
			boss.setup(Vector2(576, 320))

		$checkRoomClear.start()


func _on_roomArea_body_exited(body):
	if not body is Player:
		return

	if not enemyNodes.is_empty():
		isPlayerDead = true
		if doorsClosed:
			openDoors()

	if isPlayerDead == false:
		if typeOfRoom != "enemiesKilled" and typeOfRoom != "boss" and typeOfRoom != "initial":
			UI.updateRoomsCleared(1)
			UI.updateRoomsLabel()
		typeOfRoom = "enemiesKilled"

		body.inputDisabled()
	isPlayerDead = false


func _on_checkRoomClear_timeout():
	if enemyNodes.is_empty():
		$checkRoomClear.stop()
		if doorsClosed:
			openDoors()
