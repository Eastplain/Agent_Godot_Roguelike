extends "res://weapon/weapon.gd"

func _ready():
	super._ready()
	atk = 0
	knockbackStrength = 2000.0
	spinSpeed = 5.0
	orbitRadius = 100.0

func _onHitEnemy(area: Area2D):
	# 击退测试：零伤害，极限击退
	if not area.is_in_group("enemy"):
		return
	# 不调用 takeDamage（atk=0）
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var pushDir = (area.position - player.position).normalized()
		area.knockbackVelocity += pushDir * knockbackStrength

func _draw():
	# === 击退测试锤 — 橙色冲击锤 ===
	var padColor    = Color(1.0, 0.45, 0.0, 0.9)   # 亮橙
	var padEdge     = Color(0.85, 0.25, 0.0)
	var coreColor   = Color(1.0, 0.75, 0.15)        # 金黄核心
	var glowColor   = Color(1.0, 0.55, 0.0, 0.35)
	var handleColor = Color(0.3, 0.25, 0.18)
	var stripeColor = Color(0.9, 0.9, 0.1)

	# 外圈 — 冲击垫
	draw_circle(Vector2(0, -20), 16, padColor)
	draw_arc(Vector2(0, -20), 16, 0, TAU, 32, padEdge, 2.5)

	# 内核
	draw_circle(Vector2(0, -20), 8, coreColor)

	# 光环
	draw_arc(Vector2(0, -20), 12, 0, TAU, 32, glowColor, 3.5)

	# 十字准星
	draw_line(Vector2(-12, -20), Vector2(-4, -20), Color.WHITE, 1.5)
	draw_line(Vector2(4, -20), Vector2(12, -20), Color.WHITE, 1.5)
	draw_line(Vector2(0, -32), Vector2(0, -26), Color.WHITE, 1.5)
	draw_line(Vector2(0, -14), Vector2(0, -8), Color.WHITE, 1.5)

	# 手柄
	draw_rect(Rect2(-3, -4, 6, 28), handleColor)

	# 警示条纹
	for i in range(6):
		var y = 0.0 + i * 4.0
		if i % 2 == 0:
			draw_rect(Rect2(-4, y, 8, 3), stripeColor)

	# "T" 标记点
	draw_circle(Vector2(-6, -24), 1.5, Color.WHITE)
	draw_circle(Vector2(0, -28), 1.5, Color.WHITE)
	draw_circle(Vector2(6, -24), 1.5, Color.WHITE)
