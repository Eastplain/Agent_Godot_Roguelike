extends "res://chr/enemy/enemy.gd"

func _ready():
	super._ready()
	var cfg = ConfigLoader.getRow("enemy", "wildMan")
	hp = cfg.get("hp", 1)
	maxHp = cfg.get("maxHp", 1)
	atk = cfg.get("atk", 5)
	chaseSpeed = cfg.get("chaseSpeed", 120.0)
	attackCooldown = cfg.get("attackCooldown", 1.0)
	expValue = cfg.get("expValue", 1)
	isBoss = cfg.get("isBoss", false)
	enemyId = "wildMan"
	speed = chaseSpeed
