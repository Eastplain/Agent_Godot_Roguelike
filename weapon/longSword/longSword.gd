extends "res://weapon/weapon.gd"

func _ready():
	super._ready()
	atk = 3
	knockbackStrength = 800.0
	spinSpeed = 2.5
	orbitRadius = 100.0

func _draw():
	var bladeLen = 55.0
	var bladeWid = 10.0
	var bladeColor = Color(0.75, 0.82, 0.88)
	var edgeColor = Color(0.5, 0.6, 0.85)
	var hiltColor = Color(0.45, 0.3, 0.15)

	# blade — long, slightly tapered
	var pts = PackedVector2Array([
		Vector2(0, -bladeLen),          # tip
		Vector2(bladeWid, 4),           # right base
		Vector2(0, -2),                 # center notch
		Vector2(-bladeWid, 4)           # left base
	])
	draw_colored_polygon(pts, bladeColor)
	draw_polyline(pts + PackedVector2Array([Vector2(0, -bladeLen)]), edgeColor, 2.0)
	# center ridge
	draw_line(Vector2(0, -bladeLen), Vector2(0, -8), Color(0.9, 0.9, 1.0, 0.35), 1.5)

	# crossguard
	draw_rect(Rect2(-16, 2, 32, 6), Color(0.6, 0.4, 0.2))
	# hilt
	draw_rect(Rect2(-5, 5, 10, 14), hiltColor)
	# pommel
	draw_circle(Vector2(0, 20), 4, Color(0.55, 0.35, 0.15))
