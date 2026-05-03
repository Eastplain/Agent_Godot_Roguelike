extends Control
# 虚拟摇杆 — 左下角触屏操控，_draw() 画圈

var dir: Vector2 = Vector2.ZERO
var _active: bool = false
var _touchIndex: int = -1
var _basePos: Vector2

@export var baseRadius: float = 90.0
@export var thumbRadius: float = 35.0


func _ready():
	var vp = get_viewport().get_visible_rect().size
	_basePos = Vector2(vp.x / 2, vp.y - baseRadius - 80)
	position = Vector2.ZERO
	add_to_group("joystick")
	queue_redraw()


func _input(event):
	if event is InputEventScreenTouch:
		var dist = event.position.distance_to(_basePos)
		if dist > baseRadius * 2.0 and _touchIndex == -1:
			return  # 不在摇杆区域，放行给UI
		if event.pressed and _touchIndex == -1:
			_touchIndex = event.index
			_active = true
			_updateThumb(event.position)
		elif not event.pressed and event.index == _touchIndex:
			_touchIndex = -1
			_active = false
			dir = Vector2.ZERO
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == _touchIndex:
		_updateThumb(event.position)


func _updateThumb(pos: Vector2):
	var diff = pos - _basePos
	var len = diff.length()
	if len < 15.0:
		dir = Vector2.ZERO
	else:
		dir = (diff / min(len, baseRadius)).limit_length(1.0)
	queue_redraw()


func _draw():
	if not _active and dir.length() < 0.1:
		# 闲置态：只画底座
		draw_circle(_basePos, baseRadius, Color(1, 1, 1, 0.08))
		draw_arc(_basePos, baseRadius, 0, TAU, 32, Color(1, 1, 1, 0.15), 1.5)
		return

	# 激活态：底座 + 拇指
	var base = Color(1, 1, 1, 0.12)
	var ring = Color(1, 1, 1, 0.25)
	draw_circle(_basePos, baseRadius, base)
	draw_arc(_basePos, baseRadius, 0, TAU, 32, ring, 2.0)

	var thumbPos = _basePos + dir * (baseRadius - thumbRadius)
	draw_circle(thumbPos, thumbRadius, Color(1, 1, 1, 0.35))
	draw_circle(thumbPos, thumbRadius * 0.6, Color(1, 1, 1, 0.5))
