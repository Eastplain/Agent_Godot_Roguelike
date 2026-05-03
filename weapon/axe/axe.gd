extends "res://weapon/weapon.gd"

func _ready():
	super._ready()
	atk = 4
	knockbackStrength = 400.0
	spinSpeed = 2.0
	orbitRadius = 85.0
func _draw():
	# === 战斧 — 纯 rect/circle 绘制，零多边形 ===
	var blade  = Color(0.52, 0.55, 0.60)     # 斧面
	var edge   = Color(0.78, 0.80, 0.85)     # 刃口
	var dark   = Color(0.32, 0.35, 0.40)     # 深铁
	var wood   = Color(0.38, 0.23, 0.10)     # 木柄
	var metal  = Color(0.48, 0.42, 0.36)     # 铁箍

	# ── 斧头：三层叠出梯形轮廓 ──
	# 最外层：宽刃口
	draw_rect(Rect2(-29, -32, 58, 8), edge)
	# 中层：斧面主体
	draw_rect(Rect2(-20, -25, 40, 14), blade)
	# 内层：根部收窄
	draw_rect(Rect2(-12, -12, 24, 10), blade)

	# 刃口亮线 + 底面暗线
	draw_line(Vector2(-30, -31), Vector2(30, -31), Color.WHITE, 1.0)
	draw_line(Vector2(-13, -2),  Vector2(13, -2),  dark, 2.0)

	# 中心加强筋
	draw_line(Vector2(0, -31), Vector2(0, -4), Color(0.85, 0.88, 0.92, 0.4), 2.0)

	# ── 铁箍 ──
	draw_rect(Rect2(-6, -2, 12, 6), metal)
	draw_rect(Rect2(-6, -2, 12, 2), Color(0.6, 0.55, 0.48))

	# ── 木柄 ──
	draw_rect(Rect2(-5, 4, 10, 30), wood)
	# 高光
	draw_rect(Rect2(-4, 5, 4, 28), Color(0.5, 0.3, 0.14))

	# ── 尾锤 ──
	draw_circle(Vector2(0, 35), 5, dark)
	draw_circle(Vector2(0, 35), 3, metal)
