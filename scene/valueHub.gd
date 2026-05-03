extends Node
# valueHub — 当前对局运行时状态管理

# -- 基础值 --
var _baseMoveSpeed: float = 350.0
var _baseWeaponSpinSpeed: float = 4.5
var _baseMaxHp: int = 30

# -- 增益倍率（*% 类型，累乘） --
var buffMaxHpMult: float = 1.0
var buffSpinSpeedMult: float = 1.0
var buffWeaponScaleMult: float = 1.0
var buffWeaponAtkMult: float = 1.0

# -- 增益加值（add 类型） --
var buffMoveSpeed: float = 0.0
var buffWeaponCount: int = 1

# -- 吸铁石（magnet） --
var _magnetRange: float = 0.0
var _magnetInterval: float = 0.0
var _magnetLevel: int = 0

# -- 升级难度倍率（累乘 + 四舍五入） --
var spawnMult: float = 1.0
var hpMult: float = 1.0

# -- 旧 addBuff 兼容 --
var buffWeaponSpinSpeed: float = 0.0


func initFromConfig(playerId: String = "default"):
	var cfg = ConfigLoader.getRow("player", playerId)
	_baseMoveSpeed = cfg.get("moveSpeed", 350.0)
	_baseWeaponSpinSpeed = cfg.get("weaponSpinSpeed", 4.5)
	_baseMaxHp = cfg.get("maxHp", 30)
	buffMoveSpeed = 0.0
	buffWeaponSpinSpeed = 0.0
	buffMaxHpMult = 1.0
	buffSpinSpeedMult = 1.0
	buffWeaponScaleMult = 1.0
	buffWeaponAtkMult = 1.0
	buffWeaponCount = 1
	_magnetRange = 0.0
	_magnetInterval = 0.0
	_magnetLevel = 0
	spawnMult = 1.0
	hpMult = 1.0


func moveSpeed() -> float:
	return _baseMoveSpeed + buffMoveSpeed

func maxHp() -> int:
	return int(_baseMaxHp * buffMaxHpMult)

func weaponSpinSpeed() -> float:
	return _baseWeaponSpinSpeed * buffSpinSpeedMult + buffWeaponSpinSpeed

func weaponCount() -> int:
	return buffWeaponCount

func weaponScale() -> float:
	return buffWeaponScaleMult

func weaponAtk() -> float:
	return buffWeaponAtkMult

func magnetRange() -> float:
	return _magnetRange

func magnetInterval() -> float:
	return _magnetInterval

func magnetLevel() -> int:
	return _magnetLevel

func hasMagnet() -> bool:
	return _magnetLevel > 0

func updateLevelMult(_newLevel: int):
	spawnMult = round(spawnMult * 1.5)
	hpMult = round(hpMult * 1.3)


func applyGift(effectVar: String, value: float, giftType: String):
	match giftType:
		"*%":
			var mult = 1.0 + value / 100.0
			match effectVar:
				"maxHp":       buffMaxHpMult       *= mult
				"spinSpeed":   buffSpinSpeedMult   *= mult
				"weaponScale": buffWeaponScaleMult *= mult
				"weaponAtk":   buffWeaponAtkMult   *= mult
		"add":
			match effectVar:
				"moveSpeed":    buffMoveSpeed    += value
				"weaponCount":  buffWeaponCount  += int(value)
		"magnet":
			# value 格式为 "range:interval"，由 player.pickGift 解析后传入 range/interval 分开
			# 这里 effectVar="magnet", value 直接是 range (由 pickGift 预处理)
			# interval 通过第二个参数传不过来... 改用 parse
			# 实际由 pickGift 直接调用 _setMagnet
			pass


func setMagnet(level: int, rangeVal: float, interval: float):
	_magnetLevel = level
	_magnetRange = rangeVal
	_magnetInterval = interval


func addBuff(stat: String, amount: float):
	match stat:
		"moveSpeed":        buffMoveSpeed        += amount
		"weaponSpinSpeed":  buffWeaponSpinSpeed  += amount
