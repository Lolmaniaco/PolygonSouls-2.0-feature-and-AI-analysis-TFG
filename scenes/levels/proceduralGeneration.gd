extends Node2D

#Cantidad de salas exportada a la interfaz
export (int) var maxRooms = 12

#Array de habitaciones
var roomGlobal = []
#Habitación que aparece en escena
var tempRoomGlobal

#Función de inicialización
func _ready():
	#Array de salas en el programa
	var arrayRooms = []
	var arrayRoomsIndex = []
	#Carga la escena de la sala inicial y de jugador
	var classRoom = preload("res://scenes/control/room.tscn")
	var player = preload("res://scenes/player/player.tscn")
	
	#Cantidad de salas especiales
	var specialRooms = 2

	############################################################################
	#				INICIALIZACIÓN DE LA SALA INICIAL Y DE JEFE				   #
	############################################################################
	
	#Se crea la sala inicial
	var roomInit = classRoom.instance()
	
	#Se añade la sala inicial al array de salas local(arrayRooms) y global(roomGlobal)
	$rooms.add_child(roomInit)
	roomGlobal.append(roomInit)
	
	#Asigna la posición y tipo de la primera sala (setters).
	roomInit.setCoord(Vector2.ZERO)
	roomInit.setTypeOfRoom("initial")
	
	#Inicializa y obtiene el valor del tamaño de una sala, que será usado más veecs
	var cellSize = roomInit.getCellSize()
	
	#Obtiene el tamaño de la pantalla y lo divide por el tamaño de una sala
	var windowsSizeInBlocks = OS.get_window_size()/cellSize
	
	#Detecta las esquinas de la sala y devuelve en formato [ESQUINA, ESQUINA2]
	var initCorners = roomInit.getsetCorners(windowsSizeInBlocks, cellSize)
	#Guarda en arrayRooms las coordenadas de la primera sala
	arrayRooms.append(roomInit.getCoord())
	
	#Se dibuja la sala inicial
	var initPos = Vector2.ZERO
	roomInit.drawRoom(initPos, windowsSizeInBlocks) # Main room
	
	#Se crea la sala del jefe de nivel
	var finalRoom = classRoom.instance()
	
	#Se añade la sala final al array de salas local (arrayRooms)
	$rooms.add_child(finalRoom)
	
	#Asigna la posición y tipo de la sala del jefe (setters).
	finalRoom.setCoord(Vector2(10,10))
	finalRoom.setTypeOfRoom("final")
	
	#Se dibuja la sala final
	var finalRoomCorners = finalRoom.getsetCorners(windowsSizeInBlocks, cellSize)
	finalRoom.drawRoom(finalRoomCorners[0], finalRoomCorners[1]) # Draw room from top-left to down-right 

	############################################################################
	#						CREACIÓN DE SALAS COMUNES						   #
	############################################################################
	
	var numRooms = 1
	var roomIndex = 0
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]
	var nearRoom
	var dirTemp

	#Mientras haya menos salas que las máximas crea
	while numRooms < maxRooms:
		randomize()
		dirTemp = directions.duplicate(true)
		var numberOfNearRooms = 0

		#Comprueba si hay salas en alguna dirección
		for possibleDirs in directions:
			nearRoom = arrayRooms[roomIndex] + possibleDirs
			if arrayRooms.has(nearRoom):
				dirTemp.erase(possibleDirs)

		dirTemp.shuffle()
		# Después, en función de la cantidad de espacios libres elige un 
		# número entre 0 o 2 para crear ese número de salas
		if numRooms < maxRooms and numRooms > roomIndex:
			var dirTempsSize = dirTemp.size()
			if dirTempsSize == 1:
				numberOfNearRooms = 1
			elif dirTempsSize == 0:
				pass
			else:
				numberOfNearRooms = getRandomNumber(2,1) # random numbe: 1, 2

		# Se crean salas en las direcciones que haya espacio
		for dirs in range(0, numberOfNearRooms):
			nearRoom = arrayRooms[roomIndex] + dirTemp[dirs]
			
			if !arrayRooms.has(nearRoom) and numRooms < maxRooms:
				var room = classRoom.instance()
				
				room.setCoord(nearRoom)
				var corners = room.getsetCorners(windowsSizeInBlocks, cellSize)
				$rooms.add_child(room)

				room.drawRoom(corners[0], corners[1]) # Draw room from top-left to down-right 
				room.visible = false
				
				roomGlobal.append(room)
				arrayRooms.append(nearRoom) # Append room in room list
				numRooms+=1
		roomIndex+=1

	for roomNode in roomGlobal:
#		print(roomNode)
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
	tempRoomGlobal = roomGlobal.duplicate(true)

	arrayRoomsIndex.resize(arrayRooms.size())
	arrayRoomsIndex[0] = 0
	for i in range(arrayRooms.size()):
		var foundUp = false
		var j = 1
		while (!foundUp && j < arrayRooms.size()):
			if(arrayRooms[i] + Vector2.UP == arrayRooms[j]):
				foundUp = true
				if (arrayRoomsIndex[j] == null or arrayRoomsIndex[j] > arrayRoomsIndex[i] + 1):
					arrayRoomsIndex[j] = arrayRoomsIndex[i] + 1
			j += 1
		var foundLeft = false
		j = 1
		while (!foundLeft && j < arrayRooms.size()):
			if(arrayRooms[i] + Vector2.LEFT == arrayRooms[j]):
				foundLeft = true
				if (arrayRoomsIndex[j] == null or arrayRoomsIndex[j] > arrayRoomsIndex[i] + 1):
					arrayRoomsIndex[j] = arrayRoomsIndex[i] + 1
			j += 1

		var foundRight = false
		j = 1
		while (!foundRight && j < arrayRooms.size()):
			if(arrayRooms[i] + Vector2.RIGHT == arrayRooms[j]):
				foundRight = true
				if (arrayRoomsIndex[j] == null or arrayRoomsIndex[j] > arrayRoomsIndex[i] + 1):
					arrayRoomsIndex[j] = arrayRoomsIndex[i] + 1
			j += 1

		var foundDown = false
		j = 1
		while (!foundDown && j < arrayRooms.size()):
			if(arrayRooms[i] + Vector2.DOWN == arrayRooms[j]):
				foundDown = true
				if (arrayRoomsIndex[j] == null or arrayRoomsIndex[j] > arrayRoomsIndex[i] + 1):
					arrayRoomsIndex[j] = arrayRoomsIndex[i] + 1
			j += 1

	# Create special arrayRooms and erase them from list
	var maxValue = arrayRoomsIndex.max()
	var indexMaxValue = arrayRoomsIndex.find(maxValue)
	var cryptRoom = tempRoomGlobal[indexMaxValue]
	cryptRoom.setTypeOfRoom("cryptEntrance")
	
	var meanValue = ceil(float(arrayRoomsIndex.max())/2)
	var indexMeanValue = arrayRoomsIndex.find(int(meanValue))
	var firepitRoom = tempRoomGlobal[indexMeanValue]
	firepitRoom.setTypeOfRoom("firepitRoom")

	print("arrayRoomsIndex: ", arrayRoomsIndex)
	print("maxValue: ", maxValue)
	print("indexMaxValue: ", indexMaxValue)
	print("meanValue: ", meanValue)
	print("indexMeanValue: ", indexMeanValue)

	tempRoomGlobal.erase(roomInit)  # Erase initial room as it is a special room already
	tempRoomGlobal.erase(cryptRoom)
	tempRoomGlobal.erase(firepitRoom)

	# Instance node player in this scene
	var pj = player.instance()
	add_child(pj)

#	pj.setActualRoom()
	roomInit.makeDoors()

func randomElement(array):
	return array[randi() % array.size()]
	
func getRandomNumber(maxNumbers = 4, offset=0): #Default outputs: 0,1,2,3
	randomize()
	return randi()%maxNumbers+offset
