extends Control
# Hit flash — red gradient bars on screen edges

const EDGE_WIDTH: float = 30.0
const OUTER_ALPHA: float = 0.8
const INNER_ALPHA: float = 0.05
var flashColor = Color(1, 0.12, 0.12)

func _draw():
	var r = get_rect()
	var w = r.size.x
	var h = r.size.y
	
	# top edge — gradient from top outward → bottom inward
	for i in range(int(EDGE_WIDTH)):
		var a = lerpf(OUTER_ALPHA, INNER_ALPHA, float(i) / EDGE_WIDTH)
		draw_line(Vector2(0, i), Vector2(w, i), Color(flashColor, a))
	
	# bottom edge
	for i in range(int(EDGE_WIDTH)):
		var a = lerpf(OUTER_ALPHA, INNER_ALPHA, float(i) / EDGE_WIDTH)
		draw_line(Vector2(0, h - 1 - i), Vector2(w, h - 1 - i), Color(flashColor, a))
	
	# left edge
	for i in range(int(EDGE_WIDTH)):
		var a = lerpf(OUTER_ALPHA, INNER_ALPHA, float(i) / EDGE_WIDTH)
		draw_line(Vector2(i, EDGE_WIDTH), Vector2(i, h - EDGE_WIDTH), Color(flashColor, a))
	
	# right edge
	for i in range(int(EDGE_WIDTH)):
		var a = lerpf(OUTER_ALPHA, INNER_ALPHA, float(i) / EDGE_WIDTH)
		draw_line(Vector2(w - 1 - i, EDGE_WIDTH), Vector2(w - 1 - i, h - EDGE_WIDTH), Color(flashColor, a))
