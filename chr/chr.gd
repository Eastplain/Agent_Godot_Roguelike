extends Area2D
# Chr — base class for all characters (player, enemy, NPC)

const SHAKE_DURATION: float = 0.18
const SHAKE_INTENSITY: float = 4.0

signal hpChanged(currentHp: int, maxHp: int)
signal died(pos: Vector2)
signal damaged(actualDamage: int, atPosition: Vector2)

@export var hp: int = 10
@export var maxHp: int = 10
@export var atk: int = 3
@export var speed: float = 100.0
@export var safeDistance: float = 56.0
@export var pushStrength: float = 350.0
@export var damping: float = 0.88
var weapon = null

var velocity: Vector2 = Vector2.ZERO
var knockbackVelocity: Vector2 = Vector2.ZERO

# -- 受击抖动 --
var _isShaking: bool = false
var _shakeTimer: float = 0.0


func _ready():
	add_to_group("chr")
	queue_redraw()


func _process(delta):
	_applySeparation(delta)
	velocity += knockbackVelocity
	position += velocity * delta
	velocity *= damping
	knockbackVelocity *= 0.85
	if velocity.length() < 0.5:
		velocity = Vector2.ZERO
	if knockbackVelocity.length() < 0.5:
		knockbackVelocity = Vector2.ZERO

	# 抖动
	if _isShaking:
		_shakeTimer -= delta
		var visual = _getVisual()
		if _shakeTimer <= 0.0:
			if visual: visual.position = Vector2.ZERO
			_isShaking = false
		elif visual:
			var intensity = (_shakeTimer / SHAKE_DURATION) * SHAKE_INTENSITY
			visual.position = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))


func _applySeparation(delta):
	var allChr = get_tree().get_nodes_in_group("chr")
	for other in allChr:
		if other == self or not is_instance_valid(other):
			continue
		var dist = position.distance_to(other.position)
		if dist < safeDistance and dist > 0.001:
			var away = (position - other.position).normalized()
			var ratio = dist / safeDistance
			var force = (1.0 - ratio) * (1.0 - ratio)
			velocity += away * force * pushStrength * delta


func takeDamage(amount: int):
	var actual = mini(amount, hp)
	hp -= actual
	damaged.emit(actual, position)
	hpChanged.emit(hp, maxHp)
	if hp <= 0:
		died.emit(position)
		queue_free()
	elif not _isShaking:
		_isShaking = true
		_shakeTimer = SHAKE_DURATION


func heal(amount: int):
	hp = min(hp + amount, maxHp)
	hpChanged.emit(hp, maxHp)


func _getVisual() -> Node2D:
	return $Visual if has_node("Visual") else null


func _draw():
	pass
