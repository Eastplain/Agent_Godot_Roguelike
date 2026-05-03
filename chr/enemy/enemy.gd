extends "res://chr/chr.gd"
# Enemy — base class for all enemy types

@export var chaseSpeed: float = 120.0
@export var attackCooldown: float = 1.0
@export var expValue: int = 1
@export var enemyId: String = ""
@export var isBoss: bool = false

var target: Node2D = null
var attackTimer: float = 0.0

func _ready():
	super._ready()
	speed = chaseSpeed
	attackTimer = 0.0
	area_entered.connect(_onBodyContact)

func setup(spawnPos: Vector2, playerRef: Node2D):
	position = spawnPos
	target = playerRef

func _process(delta):
	if attackTimer > 0:
		attackTimer -= delta

	if not target or target.hp <= 0:
		velocity = Vector2.ZERO
		super._process(delta)
		return

	# move toward target
	var dir = (target.position - position).normalized()
	velocity = dir * speed
	super._process(delta)

func _onBodyContact(area: Area2D):
	if not area.is_in_group("player"):
		return
	if attackTimer > 0:
		return
	area.takeDamage(atk)
	attackTimer = attackCooldown

func _draw():
	pass
