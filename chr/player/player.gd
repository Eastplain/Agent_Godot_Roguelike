extends "res://chr/chr.gd"

signal expChanged(currentExp: int)

var weaponSlot: Node2D
var visual: Node2D
var _weapons: Array = []
var _weaponScene   # 当前武器场景引用
@export var startWeapon: PackedScene

# ── 经验/等级 ──
var currentExp: int = 0
var level: int = 1
var _levelData: Dictionary = {}
var _giftLevels: Dictionary = {}   # {giftId: 已选次数}

# ── 虚拟摇杆引用 ──
var _joystick = null

# ── 吸铁石脉冲 ──
var _magnetTimer: float = 0.0
var _magnetPulseAlpha: float = 0.0   # 蓝圈透明度
var _magnetPulseRadius: float = 0.0  # 当前脉冲圈半径
var _magnetPulseMax: float = 0.0     # 脉冲圈最大半径


func _ready():
	super._ready()
	maxHp = ValueHub.maxHp()
	hp = maxHp
	atk = 0
	speed = ValueHub.moveSpeed()

	visual = $Visual
	weaponSlot = $WeaponSlot
	_equipWeapon(startWeapon)
	_loadLevelData()
	_joystick = get_tree().get_first_node_in_group("joystick")


func _equipWeapon(weaponScene: PackedScene):
	_weaponScene = weaponScene
	for w in _weapons:
		if is_instance_valid(w):
			w.queue_free()
	_weapons.clear()
	_rebuildWeapons()


func _rebuildWeapons():
	for w in _weapons:
		if is_instance_valid(w):
			w.queue_free()
	_weapons.clear()
	if not _weaponScene:
		return
	var count = ValueHub.weaponCount()
	for i in range(count):
		var angle = float(i) / count * TAU
		var w = _weaponScene.instantiate()
		var r = 75.0
		w.position = Vector2(cos(angle) * r, sin(angle) * r)
		w.rotation = angle + PI / 2.0   # 刀刃冲外
		weaponSlot.add_child(w)
		_weapons.append(w)


func _process(delta):
	speed = ValueHub.moveSpeed()

	# 武器转速
	var spin = ValueHub.weaponSpinSpeed()
	weaponSlot.rotation += spin * delta

	# 武器缩放
	var scl = ValueHub.weaponScale()
	for w in _weapons:
		if is_instance_valid(w):
			var scaleNode = w.get_node_or_null("Scale")
			if scaleNode:
				scaleNode.scale = Vector2(scl, scl)

	# ── 吸铁石脉冲 ──
	if ValueHub.hasMagnet():
		_magnetTimer -= delta
		if _magnetTimer <= 0.0:
			_triggerMagnetPulse()
			_magnetTimer = ValueHub.magnetInterval()

	# 蓝圈渐隐
	if _magnetPulseAlpha > 0.0:
		_magnetPulseAlpha -= delta * 3.0   # ~0.33s 消失
		_magnetPulseRadius += delta * 600.0  # 扩散速度
		if _magnetPulseAlpha <= 0.0:
			_magnetPulseAlpha = 0.0
			_magnetPulseRadius = 0.0
		queue_redraw()

	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir == Vector2.ZERO and _joystick:
		dir = _joystick.dir
	velocity = dir * speed
	if dir.length() > 0:
		SignalHub.playerMoved.emit(position)
	super._process(delta)


func _triggerMagnetPulse():
	var rng = ValueHub.magnetRange()
	if rng <= 0:
		return

	# 视觉
	_magnetPulseAlpha = 0.6
	_magnetPulseRadius = 0.0
	_magnetPulseMax = rng

	# 给范围内全部经验写入朝向玩家的脉冲速度
	var exps = get_tree().get_nodes_in_group("exp")
	for e in exps:
		if not is_instance_valid(e):
			continue
		var dist = position.distance_to(e.position)
		if dist < rng and dist > 1.0:
			var dir = (position - e.position).normalized()
			e._attractVelocity = dir * 600.0   # 脉冲初速，由 exp._process 衰减


func _draw():
	# 吸铁石脉冲蓝圈
	if _magnetPulseAlpha > 0.0:
		# 范围填充 — 半透明蓝色
		draw_circle(Vector2.ZERO, _magnetPulseMax, Color(0.2, 0.5, 1.0, _magnetPulseAlpha * 0.3))
		# 范围边缘
		draw_arc(Vector2.ZERO, _magnetPulseMax, 0, TAU, 64, Color(0.3, 0.6, 1.0, _magnetPulseAlpha * 0.5), 2.0)
		# 扩散波纹
		if _magnetPulseRadius > 0.0:
			var r = min(_magnetPulseRadius, _magnetPulseMax)
			draw_arc(Vector2.ZERO, r, 0, TAU, 64, Color(0.4, 0.7, 1.0, _magnetPulseAlpha * 0.25), 1.5)


func takeDamage(amount: int):
	super.takeDamage(amount)
	SignalHub.playerHit.emit(amount)


# ── 经验/等级 ──

func _loadLevelData():
	_levelData = ConfigLoader.getSheet("levelSet")
	if _levelData.is_empty():
		_levelData = {"1": {"expRequired": 10}, "2": {"expRequired": 30}, "3": {"expRequired": 50}, "4": {"expRequired": 100}, "5": {"expRequired": 300}}

func expToNext() -> int:
	var row = _levelData.get(str(level), {})
	return int(row.get("expRequired", 999999))

func addExp(amount: int):
	currentExp += amount
	expChanged.emit(currentExp)
	_checkLevelUp()

func _checkLevelUp():
	while true:
		var required = expToNext()
		if required <= 0 or currentExp < required:
			break
		currentExp -= required
		level += 1
		SignalHub.levelUp.emit(level)


# ── 技能选择 ──

func pickGift(giftId: String):
	var row = ConfigLoader.getRow("gift", giftId)
	if row.is_empty():
		return
	if not _giftLevels.has(giftId):
		_giftLevels[giftId] = 0
	_giftLevels[giftId] += 1
	var lv = _giftLevels[giftId]
	var valuesStr = str(row.get("values", "0"))
	var giftType: String = str(row.get("type", "add"))
	var effectVar: String = str(row.get("effectVar", ""))

	if giftType == "magnet":
		# 解析 "range:interval" 对
		var parts = valuesStr.split(",")
		var idx = mini(lv - 1, parts.size() - 1)
		var pair = str(parts[idx]).strip_edges().split(":")
		var rangeVal = float(pair[0])
		var interval = float(pair[1]) if pair.size() > 1 else 8.0
		ValueHub.setMagnet(lv, rangeVal, interval)
		_magnetTimer = interval   # 拿到技能立即开始计时
		return

	var values2 = valuesStr.split(",")
	var idx2 = mini(lv - 1, values2.size() - 1)
	var value = float(values2[idx2].strip_edges())

	ValueHub.applyGift(effectVar, value, giftType)

	# 更新受影响属性
	match effectVar:
		"maxHp":
			maxHp = ValueHub.maxHp()
			hp = min(hp + int(value * float(maxHp - hp + value) / 100.0), maxHp)
			hp = clampi(hp, 1, maxHp)
		"weaponCount":
			_rebuildWeapons()

func getGiftLevel(giftId: String) -> int:
	return _giftLevels.get(giftId, 0)
