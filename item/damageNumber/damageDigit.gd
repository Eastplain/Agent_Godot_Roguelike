extends Sprite2D
# DamageDigit — 单个数字，向上飘动渐隐

var _life: float = 0.0
var _speed: float = 120.0
var _atlasSheet: Texture2D = preload("res://item/damageNumber/digit.png")

func setup(digit: int, tint: Color = Color.WHITE):
	var atlas = AtlasTexture.new()
	atlas.atlas = _atlasSheet
	atlas.region = Rect2(digit * 11, 0, 11, 11)
	texture = atlas
	modulate = tint
	_life = 0.0

func _process(delta):
	_life += delta
	position.y -= _speed * delta   # 世界坐标向上
	modulate.a = 1.0 - (_life / 1.0)
	if _life > 1.0:
		queue_free()
