extends Node
# ConfigLoader — loads JSON config tables from config/json/

var _data: Dictionary = {}

func _ready():
	_loadFile("res://config/json/game_config.json")

func _loadFile(path: String):
	var f = FileAccess.open(path, FileAccess.READ)
	if not f:
		push_warning("ConfigLoader: cannot open ", path)
		return
	var text = f.get_as_text()
	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		push_warning("ConfigLoader: JSON parse error in ", path)
		return
	_data = json.data
	print("ConfigLoader: loaded ", _data.size(), " sheets from ", path)

func getSheet(sheetName: String) -> Dictionary:
	return _data.get(sheetName, {})

func getRow(sheetName: String, rowId: String) -> Dictionary:
	var sheet = getSheet(sheetName)
	return sheet.get(rowId, {})

func getVal(sheetName: String, rowId: String, key: String):
	var row = getRow(sheetName, rowId)
	return row.get(key)
