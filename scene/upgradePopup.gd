extends CanvasLayer
# UpgradePopup — 升级时弹出 3 个随机技能选 1 个

signal giftChosen(giftId: String)

var _giftIds: Array = []
var _player: Node2D

func showChoices(playerRef: Node2D):
	_player = playerRef
	var allGifts = ConfigLoader.getSheet("gift")
	var available: Array = []
	for giftId in allGifts:
		var row = allGifts[giftId]
		var valuesStr = str(row.get("values", ""))
		var maxLv = valuesStr.split(",").size()
		var currentLv = _player.getGiftLevel(giftId) if _player.has_method("getGiftLevel") else 0
		if currentLv < maxLv:
			available.append(giftId)

	available.shuffle()
	_giftIds = available.slice(0, mini(3, available.size()))

	var cards = $Cards
	for c in cards.get_children():
		c.queue_free()

	for id in _giftIds:
		var row = allGifts[id]
		var card = _makeCard(id, row)
		cards.add_child(card)

	visible = true
	get_tree().paused = true


func _makeCard(giftId: String, row: Dictionary) -> Button:
	var btn = Button.new()
	btn.process_mode = 3
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var lv = _player.getGiftLevel(giftId) + 1
	var valuesStr = str(row.get("values", "0"))
	var values = valuesStr.split(",")
	var idx = mini(lv - 1, values.size() - 1)
	var val = str(values[idx]).strip_edges()
	var desc = str(row.get("desc", ""))
	var nameStr = str(row.get("name", giftId))

	btn.text = "%s Lv.%d\n%s" % [nameStr, lv, desc.replace("%s", val)]
	btn.pressed.connect(func():
		giftChosen.emit(giftId)
		_close()
	)
	return btn


func _close():
	visible = false
	get_tree().paused = false
	queue_free()
