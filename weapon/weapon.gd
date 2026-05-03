extends Node2D
# Weapon — base class for all weapons
# Root = Node2D, collision via Scale/Area child
# Scale node can be scaled independently for weapon size FX

@export var atk: int = 1
@export var knockbackStrength: float = 200.0
var spinSpeed: float = 4.5
var orbitRadius: float = 75.0

var _area: Area2D
var _prevWorldPos: Vector2
var _swingDir: Vector2 = Vector2.ZERO


func _ready():
	_area = $Scale/Area
	_area.area_entered.connect(_onHitEnemy)
	_prevWorldPos = _area.global_position


func _process(_delta):
	var wp = _area.global_position
	var diff = wp - _prevWorldPos
	_swingDir = diff.normalized() if diff.length() > 0.1 else Vector2.ZERO
	_prevWorldPos = wp


func _onHitEnemy(area: Area2D):
	if not area.is_in_group("enemy"):
		return
	var dmg = int(atk * ValueHub.weaponAtk())
	area.takeDamage(dmg)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var pushDir = (area.position - player.position).normalized()
		area.knockbackVelocity += pushDir * knockbackStrength
