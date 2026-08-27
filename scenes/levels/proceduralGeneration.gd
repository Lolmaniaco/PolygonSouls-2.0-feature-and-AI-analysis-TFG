extends Node2D

#Cantidad de salas exportada a la interfaz
const MAX_ROOMS: int = 12

#Array de habitaciones
var roomArray = []
#Habitación que aparece en escena
var tempRoomGlobal

@onready var room = preload("res://scenes/control/room.tscn")
@onready var player = preload("res://scenes/player/player.tscn")
@onready var room_node: Node2D = $Rooms


#Función de inicialización
func _ready():
	#Array de salas en el programa
	var arrayRooms = []
	var arrayRoomsIndex = []
	#Carga la escena de la sala inicial y de jugador

	############################################################################
	#				INICIALIZACIÓN DE LA SALA INICIAL Y DE JEFE				   #
	############################################################################

	#Se crea la sala inicial
	var roomInit: RoomHandler = room.instantiate()
	roomInit.name = "Initial Room"
	#Se añade la sala inicial al array de salas local(arrayRooms) y global(roomArray)
	room_node.add_child(roomInit)
	roomArray.append(roomInit)

	#Asigna la posición y tipo de la primera sala (setters).
	roomInit.setCoord(Vector2.ZERO)
	roomInit.setTypeOfRoom("initial")

	#Inicializa y obtiene el valor del tamaño de una sala, que será usado más veecs
	var cellSize = roomInit.getCellSize()

	#Obtiene el tamaño de la pantalla y lo divide por el tamaño de una sala
	var windowsSizeInBlocks = get_window().get_size() / Vector2i(cellSize)

	var _initCorners = roomInit.getsetCorners(windowsSizeInBlocks, cellSize)
	arrayRooms.append(roomInit.getCoord())

	#Se dibuja la sala inicial
	roomInit.drawRoom(Vector2.ZERO, windowsSizeInBlocks) # Main room

	#Se crea la sala del jefe de nivel
	var finalRoom: RoomHandler = room.instantiate()
	finalRoom.name = "Boss Room"
	#Se añade la sala final al array de salas local (arrayRooms)
	room_node.add_child(finalRoom)

	#Asigna la posición y tipo de la sala del jefe (setters).
	finalRoom.setCoord(Vector2(10, 10))
	finalRoom.setTypeOfRoom("final")

	finalRoom.drawRoom(Vector2.ZERO, windowsSizeInBlocks) # Draw room from top-left to down-right 
	############################################################################
	#						CREACIÓN DE SALAS COMUNES						   #
	############################################################################

	var numRooms = 1
	var roomIndex = 0
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]
	var nearRoom
	#print(directions)
	var dirTemp

	while numRooms < MAX_ROOMS:
		randomize()
		dirTemp = directions.duplicate(true)
		var numberOfNearRooms = 0

		for possibleDirs in directions:
			nearRoom = arrayRooms[roomIndex] + possibleDirs
			if arrayRooms.has(nearRoom):
				dirTemp.erase(possibleDirs)

		dirTemp.shuffle()
		# Get number of near arrayRooms 
		if numRooms < MAX_ROOMS and numRooms > roomIndex:
			var dirTempsSize = dirTemp.size()
			if dirTempsSize == 1:
				numberOfNearRooms = 1
			elif dirTempsSize == 0:
				pass
			else:
				numberOfNearRooms = getRandomNumber(2, 1) # random numbe: 1, 2

		for dirs in range(0, numberOfNearRooms):
			nearRoom = arrayRooms[roomIndex] + dirTemp[dirs]

			if !arrayRooms.has(nearRoom) and numRooms < MAX_ROOMS:
				var new_room: RoomHandler = room.instantiate()
				new_room.setCoord(nearRoom)

				var corners = new_room.getsetCorners(windowsSizeInBlocks, cellSize)
				new_room.name = "Room " + str(numRooms)
				room_node.add_child(new_room)

				new_room.drawRoom(Vector2.ZERO, windowsSizeInBlocks) # Draw room from top-left to down-right 

				roomArray.append(new_room)
				arrayRooms.append(nearRoom) # Append room in room list
				numRooms += 1
		roomIndex += 1

	for roomNode: RoomHandler in roomArray:
		#print(roomNode)
		for dir in directions:
			nearRoom = roomNode.getCoord() + dir

			if arrayRooms.has(nearRoom):
				roomNode.addNeighbor(nearRoom)

		roomNode.makeCorridor(windowsSizeInBlocks) # Create corridor in one direction
		roomNode.makeDoors()

	#####################d#############################################wq##########
	#						CREACIÓN DE SALAS ESPECIALES					   #
	############################################################################
	randomize()

	# Duplicate array
	tempRoomGlobal = roomArray.duplicate(true)

	arrayRoomsIndex.resize(arrayRooms.size())
	arrayRoomsIndex[0] = 0
	for i in range(arrayRooms.size()):
		var foundUp = false
		var j = 1
		while(!foundUp && j < arrayRooms.size()):
			if arrayRooms[i] + Vector2.UP == arrayRooms[j]:
				foundUp = true
				if arrayRoomsIndex[j] == null or arrayRoomsIndex[j] > arrayRoomsIndex[i] + 1:
					arrayRoomsIndex[j] = arrayRoomsIndex[i] + 1
			j += 1
		var foundLeft = false
		j = 1
		while(!foundLeft && j < arrayRooms.size()):
			if arrayRooms[i] + Vector2.LEFT == arrayRooms[j]:
				foundLeft = true
				if arrayRoomsIndex[j] == null or arrayRoomsIndex[j] > arrayRoomsIndex[i] + 1:
					arrayRoomsIndex[j] = arrayRoomsIndex[i] + 1
			j += 1

		var foundRight = false
		j = 1
		while(!foundRight && j < arrayRooms.size()):
			if arrayRooms[i] + Vector2.RIGHT == arrayRooms[j]:
				foundRight = true
				if arrayRoomsIndex[j] == null or arrayRoomsIndex[j] > arrayRoomsIndex[i] + 1:
					arrayRoomsIndex[j] = arrayRoomsIndex[i] + 1
			j += 1

		var foundDown = false
		j = 1
		while(!foundDown && j < arrayRooms.size()):
			if arrayRooms[i] + Vector2.DOWN == arrayRooms[j]:
				foundDown = true
				if arrayRoomsIndex[j] == null or arrayRoomsIndex[j] > arrayRoomsIndex[i] + 1:
					arrayRoomsIndex[j] = arrayRoomsIndex[i] + 1
			j += 1

	# Create special arrayRooms and erase them from list
	var maxValue = arrayRoomsIndex.max()
	var indexMaxValue = arrayRoomsIndex.find(maxValue)
	var cryptRoom = tempRoomGlobal[indexMaxValue]
	cryptRoom.setTypeOfRoom("cryptEntrance")

	var meanValue = ceil(float(arrayRoomsIndex.max()) / 2)
	var indexMeanValue = arrayRoomsIndex.find(int(meanValue))
	var firepitRoom = tempRoomGlobal[indexMeanValue]
	firepitRoom.setTypeOfRoom("firepitRoom")

	print("arrayRoomsIndex: ", arrayRoomsIndex)
	print("maxValue: ", maxValue)
	print("indexMaxValue: ", indexMaxValue)
	print("meanValue: ", meanValue)
	print("indexMeanValue: ", indexMeanValue)

	tempRoomGlobal.erase(roomInit) # Erase initial room as it is a special room already
	tempRoomGlobal.erase(cryptRoom)
	tempRoomGlobal.erase(firepitRoom)

	# Instance node player in this scene
	var pj = player.instantiate()
	pj.position = Vector2(576, 320)
	add_child(pj)


func randomElement(array):
	return array[randi() % array.size()]


func getRandomNumber(maxNumbers = 4, offset = 0): #Default outputs: 0,1,2,3
	randomize()
	return randi()%maxNumbers + offset
