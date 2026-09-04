extends Node2D

const CONTROLS_VER_2_CONTROLLER = preload("uid://do10oxvlyy5vx")
const CONTROLS_VER_2 = preload("uid://cuefxxc41y8x8")

const ROOM = preload("uid://dies2o4ldgdk5")
const CRYPT_ENTRANCE = preload("uid://6xgbmu2hka2v")
const FIREPIT = preload("uid://cf1jgsbpl4471")

var roomArray: Array[RoomHandler] = []

@onready var controls: TextureRect = $Control/controlsVer2
@onready var room_node: Node2D = $Rooms
@onready var cameras: Node2D = $cameras


func _ready():
	Global.cameras = cameras
	Global.soulsCollected = 0
	Global.roomsCleared = 0
	Music.play_level_music()

	if not Input.get_connected_joypads().is_empty():
		controls.set_texture(CONTROLS_VER_2_CONTROLLER)

	var arrayRooms = []
	var distance_index: Array[int] = []
	distance_index.resize(Utils.MAX_ROOMS)
	distance_index.fill(-1)

	create_room(arrayRooms, Vector2.ZERO, "initial")
	create_room(arrayRooms, Vector2(10, 10), "final")

	var room_idx = 0
	var nearRoom
	var dirTemp

	while arrayRooms.size() < Utils.MAX_ROOMS:
		dirTemp = Utils.DIRECTIONS.duplicate()
		var numberOfNearRooms = 0

		for possibleDirs in Utils.DIRECTIONS:
			nearRoom = arrayRooms[room_idx] + possibleDirs
			if arrayRooms.has(nearRoom):
				dirTemp.erase(possibleDirs)

		dirTemp.shuffle()

		if arrayRooms.size() < Utils.MAX_ROOMS and arrayRooms.size() > room_idx:
			numberOfNearRooms = randi_range(1, min(3, Utils.MAX_ROOMS - arrayRooms.size(), dirTemp.size()))

		for dirs in range(0, numberOfNearRooms):
			nearRoom = arrayRooms[room_idx] + dirTemp[dirs]

			if !arrayRooms.has(nearRoom):
				create_room(arrayRooms, nearRoom, "common")
		room_idx += 1

	distance_index[0] = 0
	for idx: int in range(roomArray.size()):
		for dir in Utils.DIRECTIONS:
			nearRoom = roomArray[idx].getCoord() + dir

			if arrayRooms.has(nearRoom):
				var neighbour_idx = arrayRooms.find(nearRoom)
				if distance_index[neighbour_idx] == -1:
					distance_index[neighbour_idx] = distance_index[idx] + 1
				roomArray[idx].add_neighbor(nearRoom)

		roomArray[idx].open_tilemap_for_doors(Utils.WINDOWS_SIZE) # Create corridor in one direction
		roomArray[idx].create_doors()
		roomArray[idx].open_all_doors()

	var max_dist_idx = distance_index.find(distance_index.max())
	roomArray[max_dist_idx].setTypeOfRoom("boss")
	var cryptObj = CRYPT_ENTRANCE.instantiate()
	roomArray[max_dist_idx].call_deferred("add_child", cryptObj)
	cryptObj.position = Utils.CENTER

	var mean_dist_idx = distance_index.find(roundi(distance_index.max() / 2.0))
	roomArray[mean_dist_idx].setTypeOfRoom("firepit")
	var firepitObj = FIREPIT.instantiate()
	roomArray[mean_dist_idx].call_deferred("add_child", firepitObj)
	firepitObj.position = Utils.CENTER


func create_room(array: Array, coords: Vector2, type_of_room: String) -> void:
	var new_room: RoomHandler = ROOM.instantiate()

	new_room.setTypeOfRoom(type_of_room)
	new_room.name = type_of_room + " Room" if type_of_room != "common" else "Room " + str(array.size())

	room_node.add_child(new_room)
	new_room.drawRoom(Vector2.ZERO, Utils.WINDOWS_SIZE)
	new_room.setCoord(coords)
	new_room.visible = false

	if type_of_room == "final":
		return

	roomArray.append(new_room)
	array.append(new_room.getCoord())


func randomElement(array):
	return array[randi() % array.size()]
