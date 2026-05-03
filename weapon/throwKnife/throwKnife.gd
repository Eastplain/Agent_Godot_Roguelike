extends "res://weapon/weapon.gd"

func _ready():
	super._ready()
	atk = 1
	knockbackStrength = 50.0
	spinSpeed = 6.0
	orbitRadius = 75.0

func _draw():
	# === 飞刀 — 细长匕首 ===
	var bladeColor = Color(0.82, 0.84, 0.88)   # 亮钢
	var edgeColor  = Color(0.95, 0.95, 1.0)     # 刃口白
	var hiltColor  = Color(0.25, 0.2, 0.15)     # 深色握柄
	var guardColor = Color(0.15, 0.12, 0.1)     # 护手

	# 刀刃 — 细长三角
	var pts = PackedVector2Array([
		Vector2(0, -28),        # 刀尖
		Vector2(4, -4),         # 右根
		Vector2(0, -4),         # 中凹
		Vector2(-4, -4),        # 左根
	])
	draw_colored_polygon(pts, bladeColor)
	draw_polyline(pts + PackedVector2Array([Vector2(0, -28)]), edgeColor, 1.5)

	# 刀脊中线
	draw_line(Vector2(0, -28), Vector2(0, -4), Color.WHITE, 0.8)

	# 护手
	draw_rect(Rect2(-7, -2, 14, 3), guardColor)

	# 握柄
	draw_rect(Rect2(-3, 1, 6, 12), hiltColor)

	# 柄尾
	draw_circle(Vector2(0, 14), 2.5, guardColor)
