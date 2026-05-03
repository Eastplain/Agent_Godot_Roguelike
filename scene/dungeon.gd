extends Node
# dungeon generator — BSP room placement + corridor carving

const COLS = 18
const ROWS = 30
const MIN_ROOM_SIZE = 3
const MAX_ROOM_SIZE = 8
const MAX_ROOMS = 12

var rng = RandomNumberGenerator.new()
var rooms: Array[Rect2i] = []
var grid: Array = []  # 2D array of ints: 0=wall, 1=floor

func generate():
	rng.randomize()
	rooms.clear()
	grid.clear()
	for y in range(ROWS):
		grid.append([])
		for _x in range(COLS):
			grid[y].append(0)
	
	# place rooms
	for _i in range(MAX_ROOMS):
		var w = rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
		var h = rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
		var x = rng.randi_range(1, COLS - w - 2)
		var y = rng.randi_range(1, ROWS - h - 2)
		
		var newRoom = Rect2i(x, y, w, h)
		var overlaps = false
		for room in rooms:
			if newRoom.intersects(room.grow(1)):
				overlaps = true
				break
		
		if not overlaps:
			carveRoom(newRoom)
			if rooms.size() > 0:
				var prev = rooms[-1]
				carveCorridor(
					Vector2i(prev.position.x + prev.size.x / 2, prev.position.y + prev.size.y / 2),
					Vector2i(newRoom.position.x + newRoom.size.x / 2, newRoom.position.y + newRoom.size.y / 2)
				)
			rooms.append(newRoom)
	
	return rooms

func carveRoom(room: Rect2i):
	for y in range(room.position.y, room.position.y + room.size.y):
		for x in range(room.position.x, room.position.x + room.size.x):
			grid[y][x] = 1

func carveCorridor(a: Vector2i, b: Vector2i):
	var x = a.x; var y = a.y
	var dx = sign(b.x - a.x)
	var dy = sign(b.y - a.y)
	
	# horizontal then vertical
	while x != b.x:
		if y >= 0 and y < ROWS and x >= 0 and x < COLS:
			grid[y][x] = 1
		x += dx
	while y != b.y:
		if y >= 0 and y < ROWS and x >= 0 and x < COLS:
			grid[y][x] = 1
		y += dy

func placePlayer(rooms: Array[Rect2i]) -> Vector2i:
	if rooms.size() > 0:
		var r = rooms[0]
		return Vector2i(r.position.x + r.size.x / 2, r.position.y + r.size.y / 2)
	return Vector2i(9, 15)

func getRandomFloorTile() -> Vector2i:
	var floors = []
	for y in range(ROWS):
		for x in range(COLS):
			if grid[y][x] == 1:
				floors.append(Vector2i(x, y))
	if floors.size() > 0:
		return floors[rng.randi_range(0, floors.size() - 1)]
	return Vector2i(9, 15)

func getFloorTiles(count: int) -> Array:
	var floors = []
	for y in range(ROWS):
		for x in range(COLS):
			if grid[y][x] == 1:
				floors.append(Vector2i(x, y))
	floors.shuffle()
	return floors.slice(0, min(count, floors.size()))
