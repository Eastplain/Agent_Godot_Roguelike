extends Node2D
# Title screen — draws background, UI via child CanvasLayer

@onready var start_btn: Button = $CanvasLayer/VBox/CenterBtn/StartBtn

func _ready():
	start_btn.pressed.connect(_onStart)
	queue_redraw()

func _onStart():
	get_tree().change_scene_to_file("res://scene/main.tscn")

func _draw():
	var vp = get_viewport().get_visible_rect().size
	var cx = vp.x / 2.0
	var cy = vp.y / 2.0

	var baseGreen = Color(0.22, 0.40, 0.16)
	var altGreen  = Color(0.26, 0.44, 0.20)
	var bladeColor = Color(0.30, 0.50, 0.24)
	var tileSize = 72
	var startX = int((cx - vp.x / 2 - tileSize) / tileSize)
	var startY = int((cy - vp.y / 2 - tileSize) / tileSize)
	var endX = int((cx + vp.x / 2 + tileSize) / tileSize)
	var endY = int((cy + vp.y / 2 + tileSize) / tileSize)

	for tx in range(startX, endX + 1):
		for ty in range(startY, endY + 1):
			var wx = tx * tileSize
			var wy = ty * tileSize
			var col = altGreen if (tx + ty) % 2 == 0 else baseGreen
			draw_rect(Rect2(wx, wy, tileSize, tileSize), col)
			var seed1 = fmod(sin(float(tx) * 12.9898 + float(ty) * 78.233) * 43758.5453, 1.0)
			var seed2 = fmod(cos(float(tx) * 63.7274 + float(ty) * 41.1517) * 52128.8321, 1.0)
			var bladeCount = int(seed1 * 4) + 2
			for i in range(bladeCount):
				var bx = wx + 8 + fmod(seed1 * (i + 1) * 173.37, 1.0) * (tileSize - 16)
				var by = wy + 8 + fmod(seed2 * (i + 1) * 241.19, 1.0) * (tileSize - 16)
				var sway = sin(bx * 0.3 + seed1 * 6.28) * 2.0
				var h = 5 + seed1 * (i + 1) * 2.5
				draw_line(Vector2(bx, by), Vector2(bx + sway, by - h), bladeColor, 1.2)
