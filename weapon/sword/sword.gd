extends "res://weapon/weapon.gd"

func _ready():
	super._ready()
	atk = 1
	knockbackStrength = 220.0
	spinSpeed = 4.5
	orbitRadius = 80.0

func _draw():
	var bladeLen = 34.0
	var bladeWid = 7.0
	var bladeColor = Color(0.88, 0.88, 0.92)
	var edgeColor = Color(0.6, 0.7, 0.95)
	var hiltColor = Color(0.5, 0.35, 0.2)

	# blade pointing UP (+Y) — root toward center, tip outward
	var pts = PackedVector2Array([
		Vector2(0, -bladeLen),          # tip
		Vector2(bladeWid, 2),           # right base
		Vector2(0, -2),                 # center notch
		Vector2(-bladeWid, 2)           # left base
	])
	draw_colored_polygon(pts, bladeColor)
	draw_polyline(pts + PackedVector2Array([Vector2(0, -bladeLen)]), edgeColor, 1.5)
	draw_line(Vector2(0, -bladeLen), Vector2(0, -5), Color(0.95, 0.95, 1.0, 0.5), 1.0)

	# hilt below blade
	draw_rect(Rect2(-4, 3, 8, 8), hiltColor)
