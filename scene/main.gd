extends Node2D

const SCREEN_W = 720.0
const SCREEN_H = 1280.0
const TILE_SIZE = 72

@export var spawnInterval: float = 1.5
@export var maxEnemies: int = 15
@export var spawnMargin: float = 80.0

var player
var camera: Camera2D
var scoreLabel: Label
var hitFlash: Control
var hitFlashTimer: float = 0.0
var gameOverScene = preload("res://scene/gameOver.tscn")
var enemyScene = preload("res://chr/enemy/basic/basicEnemy.tscn")
var expScene = preload("res://item/exp/exp.tscn")
var digitScene = preload("res://item/damageNumber/damageDigit.tscn")
var upgradePopupScene = preload("res://scene/upgradePopup.tscn")
var enemiesAlive = 0
var killCount = 0
var spawnTimer: float = 0.0

func _ready():
	player = $Player
	camera = $Camera2D
	scoreLabel = $HUD/ScoreLabel
	hitFlash = $HUD/HitFlash

	ValueHub.initFromConfig()

	player.position = Vector2.ZERO
	
	player.hpChanged.connect(func(hp, mx): SignalHub.hpChanged.emit(player, hp, mx))
	player.died.connect(func(p): SignalHub.chrDied.emit(player, p))
	player.damaged.connect(_onPlayerDamaged)
	
	SignalHub.hpChanged.connect(_onHpChanged)
	SignalHub.chrDied.connect(_onChrDied)
	SignalHub.gameOver.connect(_onGameOver)
	SignalHub.playerHit.connect(_onPlayerHit)
	player.expChanged.connect(func(_e): updateHud())
	SignalHub.levelUp.connect(_onLevelUp)
	SignalHub.levelUp.connect(func(lv): ValueHub.updateLevelMult(lv))
	
	spawnTimer = spawnInterval
	updateHud()

func _process(delta):
	if not player or player.hp <= 0:
		return
	
	# smooth camera follow
	camera.position = camera.position.lerp(player.position, 6.0 * delta)
	
	# spawn enemies
	spawnTimer -= delta
	if spawnTimer <= 0 and enemiesAlive < maxEnemies:
		spawnEnemy()
		spawnTimer = spawnInterval
	
	# hit flash fade
	if hitFlashTimer > 0:
		hitFlashTimer -= delta
		if hitFlashTimer <= 0:
			hitFlash.visible = false
	
	queue_redraw()

func spawnEnemy():
	if not player or not is_instance_valid(player) or player.hp <= 0:
		return
	var sm = int(ValueHub.spawnMult)
	var hm = int(ValueHub.hpMult)
	for _i in range(max(1, sm)):
		var pos = _randomEdgePos()
		var enemy = enemyScene.instantiate()
		enemy.add_to_group("enemy")
		add_child(enemy)
		enemy.setup(pos, player)
		enemy.hp *= hm
		enemy.maxHp *= hm
		enemy.expValue = int(enemy.expValue * hm)
		enemy.hpChanged.connect(func(hp, mx): SignalHub.hpChanged.emit(enemy, hp, mx))
		enemy.died.connect(func(p): SignalHub.chrDied.emit(enemy, p))
		enemy.damaged.connect(func(dmg, atPos): _spawnDamageNumber(atPos, dmg, Color.RED))
		enemiesAlive += 1

func _randomEdgePos() -> Vector2:
	var cx = camera.position.x
	var cy = camera.position.y
	var hw = SCREEN_W / 2 + spawnMargin
	var hh = SCREEN_H / 2 + spawnMargin
	var side = randi() % 4
	match side:
		0: return Vector2(randf_range(cx - hw, cx + hw), cy - hh)
		1: return Vector2(randf_range(cx - hw, cx + hw), cy + hh)
		2: return Vector2(cx - hw, randf_range(cy - hh, cy + hh))
		_: return Vector2(cx + hw, randf_range(cy - hh, cy + hh))

func updateHud():
	scoreLabel.text = "HP: %d/%d  |  Lv.%d  EXP: %d/%d" % [player.hp, player.maxHp, player.level, player.currentExp, player.expToNext()]

func _onHpChanged(who: Node, _currentHp: int, _maxHp: int):
	if who == player:
		updateHud()
		if who.hp <= 0:
			SignalHub.gameOver.emit()

func _onPlayerHit(_damage: int):
	hitFlash.visible = true
	hitFlash.queue_redraw()
	hitFlashTimer = 0.15

func _onGameOver():
	var go = gameOverScene.instantiate()
	add_child(go)
	go.get_node("KillsLabel").text = "Lv.%d  |  Kills: %d" % [player.level, killCount]
	go.get_node("RestartBtn").pressed.connect(_onRestart)

func _onRestart():
	get_tree().reload_current_scene()

# ── 伤害数字 ──

func _onPlayerDamaged(actualDamage: int, atPosition: Vector2):
	_spawnDamageNumber(atPosition + Vector2(0, -40), actualDamage, Color(1.0, 0.35, 0.35))

# ── 升级选择 ──

func _onLevelUp(_newLevel: int):
	var popup = upgradePopupScene.instantiate()
	add_child(popup)
	popup.giftChosen.connect(func(giftId: String):
		player.pickGift(giftId)
		updateHud()
	)
	popup.showChoices(player)

func _spawnDamageNumber(pos: Vector2, amount: int, tint: Color):
	var digits = str(amount)
	var digitW = 80.0
	var totalW = digits.length() * digitW
	var startX = pos.x - totalW / 2.0 + digitW / 2.0
	for i in range(digits.length()):
		var d = int(digits[i])
		var emitter = digitScene.instantiate()
		emitter.position = Vector2(startX + i * digitW, pos.y)
		emitter.setup(d, tint)
		add_child(emitter)

func _spawnExp(pos: Vector2, value: int):
	if not player or not is_instance_valid(player):
		return
	var e = expScene.instantiate()
	add_child(e)
	e.setup(value, player)
	e.position = pos

func _onChrDied(who: Node, _pos: Vector2):
	if who.is_in_group("enemy"):
		enemiesAlive -= 1
		killCount += 1
		var expVal = who.expValue
		call_deferred("_spawnExp", _pos, expVal)
		updateHud()

func _draw():
	var cx = camera.position.x
	var cy = camera.position.y
	
	var startX = int((cx - SCREEN_W / 2 - TILE_SIZE) / TILE_SIZE)
	var startY = int((cy - SCREEN_H / 2 - TILE_SIZE) / TILE_SIZE)
	var endX = int((cx + SCREEN_W / 2 + TILE_SIZE) / TILE_SIZE)
	var endY = int((cy + SCREEN_H / 2 + TILE_SIZE) / TILE_SIZE)
	
	var baseGreen = Color(0.22, 0.40, 0.16)
	var altGreen  = Color(0.26, 0.44, 0.20)
	var bladeColor = Color(0.30, 0.50, 0.24)
	
	for tx in range(startX, endX + 1):
		for ty in range(startY, endY + 1):
			var wx = tx * TILE_SIZE
			var wy = ty * TILE_SIZE
			
			var col = altGreen if (tx + ty) % 2 == 0 else baseGreen
			draw_rect(Rect2(wx, wy, TILE_SIZE, TILE_SIZE), col)
			
			var seed1 = fmod(sin(float(tx) * 12.9898 + float(ty) * 78.233) * 43758.5453, 1.0)
			var seed2 = fmod(cos(float(tx) * 63.7274 + float(ty) * 41.1517) * 52128.8321, 1.0)
			var bladeCount = int(seed1 * 4) + 2
			
			for i in range(bladeCount):
				var bx = wx + 8 + fmod(seed1 * (i + 1) * 173.37, 1.0) * (TILE_SIZE - 16)
				var by = wy + 8 + fmod(seed2 * (i + 1) * 241.19, 1.0) * (TILE_SIZE - 16)
				var sway = sin(bx * 0.3 + seed1 * 6.28) * 2.0
				var h = 5 + seed1 * (i + 1) * 2.5
				draw_line(Vector2(bx, by), Vector2(bx + sway, by - h), bladeColor, 1.2)
	
	# vignette
	var vignette = Color(0, 0, 0, 0.12)
	var ew = 40.0
	draw_rect(Rect2(cx - SCREEN_W / 2, cy - SCREEN_H / 2, SCREEN_W, ew), vignette)
	draw_rect(Rect2(cx - SCREEN_W / 2, cy + SCREEN_H / 2 - ew, SCREEN_W, ew), vignette)
	draw_rect(Rect2(cx - SCREEN_W / 2, cy - SCREEN_H / 2, ew, SCREEN_H), vignette)
	draw_rect(Rect2(cx + SCREEN_W / 2 - ew, cy - SCREEN_H / 2, ew, SCREEN_H), vignette)
