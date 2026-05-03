extends Area2D

var healAmount = 10

func _ready():
	area_entered.connect(_onAreaEntered)
	queue_redraw()

func setupWorld(pos: Vector2, heal: int = 10):
	healAmount = heal
	position = pos

func _process(_delta):
	# slowly drift toward player for magnetism?
	pass

func _onAreaEntered(area: Area2D):
	if area.is_in_group("player"):
		if area.has_method("heal"):
			area.heal(healAmount)
		queue_free()

func _draw():
	var r = 14.0
	# bottle
	draw_circle(Vector2.ZERO, r, Color(0.15, 0.7, 0.25))
	draw_circle(Vector2.ZERO, r, Color(0.25, 0.85, 0.35), false, 2.0)
	# liquid
	draw_circle(Vector2(0, 2), r - 5, Color(0.9, 0.2, 0.3))
	# cork
	draw_rect(Rect2(-4, -r - 6, 8, 8), Color(0.6, 0.4, 0.2))
	# highlight
	draw_circle(Vector2(-5, -5), 4, Color(1, 1, 1, 0.3))
