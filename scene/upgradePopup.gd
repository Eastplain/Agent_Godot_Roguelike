extends CanvasLayer
# UpgradePopup — 升级时弹出 3 个随机技能选 1 个，不足时回复药水补齐

signal giftChosen(giftId: String)

@onready var _cards: HBoxContainer = $VBox/Cards

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

	while _giftIds.size() < 3:
		_giftIds.append("healPotion")

	for c in _cards.get_children():
		c.queue_free()

	for id in _giftIds:
		var card
		if id == "healPotion":
			card = _makeHealCard()
		else:
			card = _makeCard(id, allGifts[id])
		_cards.add_child(card)

	visible = true
	get_tree().paused = true


func _makeCard(giftId: String, row: Dictionary) -> Button:
	var btn = Button.new()
	btn.process_mode = 3
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(180, 120)
	btn.add_theme_color_override("font_color", Color(0.92, 0.88, 0.7, 1))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.85, 1))
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_stylebox_override("normal", _loadCardStyle("normal"))
	btn.add_theme_stylebox_override("hover", _loadCardStyle("hover"))

	var lv = _player.getGiftLevel(giftId) + 1
	var valuesStr = str(row.get("values", "0"))
	var values = valuesStr.split(",")
	var idx = mini(lv - 1, values.size() - 1)
	var val = str(values[idx]).strip_edges()

	var giftType: String = str(row.get("type", "add"))
	if giftType == "magnet":
		var parts = val.split(":")
		val = parts[0] if parts.size() > 0 else val

	var desc = str(row.get("desc", ""))
	var nameStr = str(row.get("name", giftId))

	btn.text = "%s Lv.%d\n%s" % [nameStr, lv, desc.replace("%s", val)]
	btn.pressed.connect(func():
		giftChosen.emit(giftId)
		_close()
	)
	return btn


func _makeHealCard() -> Button:
	var btn = Button.new()
	btn.process_mode = 3
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(180, 120)
	btn.add_theme_color_override("font_color", Color(0.6, 0.85, 0.5, 1))
	btn.add_theme_color_override("font_hover_color", Color(0.7, 1, 0.6, 1))
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_stylebox_override("normal", _loadCardStyle("heal"))
	btn.add_theme_stylebox_override("hover", _loadCardStyle("healHover"))
	btn.text = "回复药水\n恢复全部生命值"
	btn.pressed.connect(func():
		giftChosen.emit("healPotion")
		_close()
	)
	return btn


func _loadCardStyle(which: String):
	var s = StyleBoxFlat.new()
	s.content_margin_left = 12
	s.content_margin_top = 10
	s.content_margin_right = 12
	s.content_margin_bottom = 10
	s.corner_radius_top_left = 8
	s.corner_radius_top_right = 8
	s.corner_radius_bottom_right = 8
	s.corner_radius_bottom_left = 8
	s.border_width_left = 2
	s.border_width_top = 2
	s.border_width_right = 2
	s.border_width_bottom = 2
	match which:
		"normal":
			s.bg_color = Color(0.12, 0.22, 0.1, 0.85)
			s.border_color = Color(0.4, 0.5, 0.3, 0.6)
		"hover":
			s.bg_color = Color(0.2, 0.35, 0.15, 0.9)
			s.border_color = Color(0.6, 0.7, 0.4, 0.7)
		"heal":
			s.bg_color = Color(0.1, 0.25, 0.12, 0.85)
			s.border_color = Color(0.3, 0.55, 0.3, 0.6)
		"healHover":
			s.bg_color = Color(0.15, 0.35, 0.18, 0.9)
			s.border_color = Color(0.4, 0.7, 0.4, 0.7)
	return s


func _close():
	visible = false
	get_tree().paused = false
	queue_free()
