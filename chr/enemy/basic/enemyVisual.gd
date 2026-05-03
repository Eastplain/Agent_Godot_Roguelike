extends Node2D
# EnemyVisual — 敌人程序化绘制，由 chr 基类抖动驱动

func _ready():
	queue_redraw()

func _draw():
	var p = get_parent()
	var hp = p.hp if p else 10
	var maxHp = p.maxHp if p else 10

	var s = 18.0
	draw_rect(Rect2(-s, -s, s * 2, s * 2), Color(0.6, 0.15, 0.15))
	draw_rect(Rect2(-s, -s, s * 2, s * 2), Color(0.9, 0.2, 0.2), false, 2.0)
	draw_line(Vector2(-10, -7), Vector2(-3, -3), Color.WHITE, 2.0)
	draw_line(Vector2(-10, -3), Vector2(-3, -7), Color.WHITE, 2.0)
	draw_line(Vector2(10, -7), Vector2(3, -3), Color.WHITE, 2.0)
	draw_line(Vector2(10, -3), Vector2(3, -7), Color.WHITE, 2.0)
	draw_line(Vector2(-4, 5), Vector2(0, 10), Color.WHITE, 1.5)
	draw_line(Vector2(0, 10), Vector2(4, 5), Color.WHITE, 1.5)
	if hp < maxHp:
		var barW = 32.0
		var ratio = float(hp) / maxHp
		draw_rect(Rect2(-barW / 2, -s - 8, barW, 4), Color(0.3, 0.1, 0.1))
		draw_rect(Rect2(-barW / 2, -s - 8, barW * ratio, 4), Color(0.9, 0.2, 0.2))
