extends Area2D
# Exp — 经验掉落物，菱形黄色，带拖尾飞向主角

var expValue: int = 1
var target: Node2D
var lifeTimer: float = 0.0
var maxLife: float = 12.0
var popTimer: float = 0.0
var trailPositions: Array = []
var trailLength: int = 8

# 脉冲速度（吸铁石技能写入，逐帧衰减飞向主角）
var _attractVelocity: Vector2 = Vector2.ZERO

const BASE_ATTRACT_RANGE: float = 100.0   # 基础被动吸经范围
const BASE_ATTRACT_SPEED: float = 400.0   # 基础吸经飞行速度


func setup(value: int, playerRef: Node2D):
	expValue = value
	target = playerRef

func _ready():
	area_entered.connect(_onAreaEntered)
	add_to_group("exp")
	popTimer = 0.15
	queue_redraw()

func _process(delta):
	lifeTimer += delta
	if lifeTimer > maxLife:
		queue_free()
		return

	popTimer -= delta

	var aliveTarget = is_instance_valid(target) and target.hp > 0

	if aliveTarget:
		var dist = position.distance_to(target.position)

		# 基础被动吸经：小范围自动飞向主角
		if dist < BASE_ATTRACT_RANGE and dist > 0.5:
			var dir = (target.position - position).normalized()
			position += dir * BASE_ATTRACT_SPEED * delta
		# 脉冲吸引力（吸铁石写入，持续衰减）
		elif _attractVelocity.length() > 0.5:
			position += _attractVelocity * delta
			_attractVelocity *= 0.92   # 每帧衰减 8%
		else:
			# 微漂移
			position.y += sin(lifeTimer * 4.0) * 0.3
	else:
		# 微漂移
		position.y += sin(lifeTimer * 4.0) * 0.3

	# 衰减清理
	if _attractVelocity.length() < 0.5:
		_attractVelocity = Vector2.ZERO

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
