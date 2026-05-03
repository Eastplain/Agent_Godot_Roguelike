extends Area2D
# Exp — 经验掉落物，菱形黄色，带拖尾飞向主角

var expValue: int = 1
var target: Node2D
var speed: float = 180.0
var magnetRange: float = 120.0
var magnetSpeed: float = 500.0
var lifeTimer: float = 0.0
var maxLife: float = 12.0
var popTimer: float = 0.0
var trailPositions: Array = []
var trailLength: int = 8

func setup(value: int, playerRef: Node2D):
	expValue = value
	target = playerRef

func _ready():
	area_entered.connect(_onAreaEntered)
	# 出生小弹跳
	popTimer = 0.15
	queue_redraw()

func _process(delta):
	lifeTimer += delta
	if lifeTimer > maxLife:
		queue_free()
		return

	popTimer -= delta

	var dist = INF
	var aliveTarget = is_instance_valid(target) and target.hp > 0

	if aliveTarget:
		dist = position.distance_to(target.position)
		var magRange = ValueHub.magnetRange()
		if dist < magRange:
			var dir = (target.position - position).normalized()
			var t = 1.0 - (dist / magRange)
			position += dir * (magnetSpeed * t * t) * delta
		else:
			# 微漂移
			position.y += sin(lifeTimer * 4.0) * 0.3

	# 拖尾
	trailPositions.push_front(position)
	if trailPositions.size() > trailLength:
		trailPositions.pop_back()
	queue_redraw()

func _onAreaEntered(area: Area2D):
	if area.is_in_group("player"):
		if area.has_method("addExp"):
			area.addExp(expValue)
		queue_free()

func _draw():
	# 拖尾 — 渐隐圆点
	for i in range(trailPositions.size()):
		var t = float(i) / trailPositions.size()
		var alpha = (1.0 - t) * 0.35
		var radius = 4.0 * (1.0 - t * 0.6)
		var c = Color(1.0, 0.8, 0.05, alpha)
		if trailPositions[i] is Vector2:
			draw_circle(to_local(trailPositions[i]), radius, c)

	# 菱形主体
	var s = 6.0
	if popTimer > 0:
		s += (0.15 - popTimer) / 0.15 * 3.0  # 弹出动画
	var pts = PackedVector2Array([
		Vector2(0, -s),
		Vector2(s * 0.55, 0),
		Vector2(0, s * 0.45),
		Vector2(-s * 0.55, 0),
	])
	draw_colored_polygon(pts, Color(1.0, 0.82, 0.05))
	# 高光
	draw_circle(Vector2(0, -s * 0.3), s * 0.35, Color(1.0, 0.95, 0.5, 0.6))
