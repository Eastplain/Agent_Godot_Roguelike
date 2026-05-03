extends Node2D

var parentPlayer = null

func _ready():
	parentPlayer = get_parent()
	queue_redraw()

func _process(_delta):
	if parentPlayer and parentPlayer.has_method("get_hp"):
		queue_redraw()

func _draw():
	if not parentPlayer:
		return
	var hp = parentPlayer.hp
	var maxHp = parentPlayer.maxHp
	var s = 18.0
	
	# body
	draw_rect(Rect2(-s, -s, s * 2, s * 2), Color(0.2, 0.5, 0.8))
	draw_rect(Rect2(-s, -s, s * 2, s * 2), Color(0.3, 0.7, 1.0), false, 2.0)
	# eyes
	draw_circle(Vector2(-6, -4), 3, Color.WHITE)
	draw_circle(Vector2(6, -4), 3, Color.WHITE)
	draw_circle(Vector2(-5, -4), 1.5, Color.BLACK)
	draw_circle(Vector2(7, -4), 1.5, Color.BLACK)
	# mouth
	draw_line(Vector2(-4, 6), Vector2(4, 6), Color.WHITE, 2.0)
	# hp bar
	if hp < maxHp:
		var barW = 32.0
		var ratio = float(hp) / maxHp
		draw_rect(Rect2(-barW / 2, -s - 8, barW, 4), Color(0.3, 0.1, 0.1))
		draw_rect(Rect2(-barW / 2, -s - 8, barW * ratio, 4), Color(0.2, 0.9, 0.2))
