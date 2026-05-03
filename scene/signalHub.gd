extends Node

signal hpChanged(who: Node, currentHp: int, maxHp: int)
signal chrDied(who: Node, pos: Vector2)
signal playerMoved(newPos: Vector2)
signal playerHit(damage: int)
signal gameOver()
signal levelUp(newLevel: int)

var isUpgrading: bool = false
