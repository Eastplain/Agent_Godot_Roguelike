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

	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	if dir.length() > 0:
		SignalHub.playerMoved.emit(position)
	super._process(delta)


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
	var values = valuesStr.split(",")
	var idx = mini(lv - 1, values.size() - 1)
	var value = float(values[idx].strip_edges())
	var effectVar: String = row.get("effectVar", "")
	var giftType: String = row.get("type", "add")

	ValueHub.applyGift(effectVar, value, giftType)

	# 更新受影响属性
	match effectVar:
		"maxHp":
			maxHp = ValueHub.maxHp()
			hp = min(hp + int(value * float(maxHp - hp + value) / 100.0), maxHp)  # 近似恢复
			hp = clampi(hp, 1, maxHp)
		"weaponCount":
			_rebuildWeapons()

func getGiftLevel(giftId: String) -> int:
	return _giftLevels.get(giftId, 0)
