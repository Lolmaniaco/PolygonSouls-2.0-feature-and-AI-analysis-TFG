class_name RoomHandler
extends Node2D

enum tile_type {
	WALL,
	EMPTY,
}

const TURRET = preload("uid://d6hqfkgirjyl")
const KAMIKAZE = preload("uid://cbocpuwmn6qsf")
const BOUNCER = preload("uid://cjhy5jdp4knd4")
const SPIN_ENEMY = preload("uid://c7dq5i3oueuk")
const FINAL_BOSS = preload("uid://bw3k6flp2e5o1")

const RIFT = preload("uid://b7obr3bc1ihef")
const DOOR = preload("uid://jg0smtbft8fp")

const CORRIDOR_DATA := {
	Vector2.LEFT: {
		"start": Vector2(0, 8),
		"end": Vector2(0, 12),
		"door_position": Vector2(16, 320),
		"vertical": false
	} ,
	Vector2.RIGHT: {
		"start": Vector2(35, 8),
		"end": Vector2(35, 12),
		"door_position": Vector2(1136, 320),
		"vertical": false
	} ,
	Vector2.DOWN: {
		"start": Vector2(16, 19),
		"end": Vector2(20, 19),
		"door_position": Vector2(576, 624),
		"vertical": true
	} ,
	Vector2.UP: {
		"start": Vector2(16, 0),
		"end": Vector2(20, 0),
		"door_position": Vector2(576, 16),
		"vertical": true
	}
}

var roomCoord = Vector2(0, 0)
var neighbors = []
var doors_positions = []

var doorNodes: Array[Door] = []
var enemyNodes: Array = []

var room_type = "common"
var doors_closed = true

@onready var baseEnemies = [KAMIKAZE, TURRET, BOUNCER]
@onready var hardEnemies = [KAMIKAZE, TURRET, BOUNCER, SPIN_ENEMY]

@onready var tile_map: TileMapLayer = $TileMap
@onready var room_cam: Camera2D = $"../../cameras/roomCam"
@onready var enemy_nodes: Node2D = $EnemyNodes
@onready var check_timer: Timer = $checkRoomClear
@onready var UI: UserInterface = $"../../player/UI"


func setTypeOfRoom(newRoom):
	room_type = newRoom
	name = newRoom + " Room"


func setCoord(coordPos):
	roomCoord = coordPos
	position = coordPos * Vector2(1152, 640)


func getCoord():
	return roomCoord


func drawBlockLine(startPosLine: Vector2, finalPosLine: Vector2, blockIndex: tile_type):
	var dirLine = startPosLine.direction_to(finalPosLine)
	var distLine = startPosLine.distance_to(finalPosLine)

	if dirLine == Vector2.RIGHT:
		for block in range(0, distLine):
			@warning_ignore("narrowing_conversion")
			tile_map.set_cell(Vector2i(startPosLine.x + block, startPosLine.y), 0, Vector2i(blockIndex, 0))
	if dirLine == Vector2.DOWN:
		for block in range(0, distLine):
			@warning_ignore("narrowing_conversion")
			tile_map.set_cell(Vector2i(startPosLine.x, startPosLine.y + block), 0, Vector2i(blockIndex, 0))


func drawRoom(startCoord: Vector2, finCoord: Vector2, wallBlockType: tile_type = tile_type.WALL):
	var upCoord = Vector2(finCoord.x, startCoord.y)
	drawBlockLine(startCoord, upCoord, wallBlockType)

	var downCoordS = Vector2(startCoord.x, finCoord.y - 1)
	var downCoordF = Vector2(finCoord.x, finCoord.y - 1)

	drawBlockLine(downCoordS, downCoordF, wallBlockType)
	drawBlockLine(startCoord, downCoordS, wallBlockType)
	drawBlockLine(upCoord - Vector2.RIGHT, downCoordF - Vector2.RIGHT, wallBlockType)


func add_neighbor(neighbor):
	neighbors.append(neighbor)


func open_tilemap_for_doors(_sizeInBlocks):
	for neighbor in neighbors:
		var direction = roomCoord.direction_to(neighbor)
		var data: Dictionary = CORRIDOR_DATA[direction]

		drawBlockLine(data.start, data.end, tile_type.EMPTY)
		doors_positions.append(
			DoorData.new(data.door_position, data.vertical)
		)


func create_doors():
	for data: DoorData in doors_positions:
		var doorObj: Door = DOOR.instantiate()
		add_child(doorObj)
		doorObj.setup(data.position, data.vertical)

		doorNodes.append(doorObj)


func open_all_doors():
	for doorNode in doorNodes:
		doorNode.queue_door_animation("open")
	doors_closed = false


func close_all_doors():
	for doorNode in doorNodes:
		doorNode.queue_door_animation("close")
	doors_closed = true


func get_player_deaths():
	var user_file = "user://score.txt"
	var f = FileAccess.open(user_file, FileAccess.READ)
	var lastNumberDeaths

	if not f:
		return 5

	var index = 1
	while index != 3:
		if index == 1:
			f.get_line()
		elif index == 2:
			lastNumberDeaths = int(f.get_line())
		index += 1
	f.close()

	return lastNumberDeaths


func create_enemies(enemyPressence, minNumEnemies = 1, maxNumEnemies = 4):
	var enemiesToCreate: int = randi_range(minNumEnemies, maxNumEnemies)

	for i in enemiesToCreate:
		var new_scene: PackedScene
		new_scene = hardEnemies.pick_random() if enemyPressence > 2.5 else baseEnemies.pick_random()

		var new_enemy: Enemy = new_scene.instantiate()
		new_enemy.position = Vector2(randi_range(192, 960), randi_range(192, 448))
		enemy_nodes.call_deferred("add_child", new_enemy)


func _on_roomArea_body_entered(body):
	if not body is Player:
		return

	visible = true
	room_cam.position = roomCoord * Vector2(1152, 640)
	visible = true

	if room_type == "common":
		var playerDeaths = float(get_player_deaths())
		var x = playerDeaths / 3
		var y = float(Global.getRoomsCleared())

		var enemyPressence = float((-50 - x) / float(y + 12)) + 6
		var minimumEnemies = clamp(enemyPressence * 0.90, 2, 7)
		var maximumEnemies = clamp(enemyPressence * 1.4, 2, 7)
		create_enemies(enemyPressence, minimumEnemies, maximumEnemies)
		close_all_doors()
	elif room_type == "final":
		Music.fade_out_music()
		var rift: Rift = RIFT.instantiate()
		call_deferred("add_child", rift)
		rift.position = Utils.CENTER
		var boss: Boss = FINAL_BOSS.instantiate()
		call_deferred("add_child", boss)
		boss.position = Utils.CENTER

	check_timer.start()


func _on_roomArea_body_exited(body):
	if not body is Player:
		return

	body.inputDisabled()


func _on_checkRoomClear_timeout():
	enemyNodes = enemy_nodes.get_children()
	if enemyNodes.is_empty():
		if room_type == "common":
			Global.updateRoomsCleared()
			room_type = "cleared"
		check_timer.stop()
		if doors_closed:
			open_all_doors()


class DoorData:
	var position: Vector2
	var vertical: bool


	func _init(new_position: Vector2, new_vertical: bool):
		self.position = new_position
		self.vertical = new_vertical
