class_name ActorHealth
extends RefCounted

var current: float = 100.0
var maximum: float = 100.0
var invulnerable_until: int = -1
var hurt_until: int = -1
var dead: bool = false
var debug_invincible: bool = false
var debug_god_mode: bool = false

func _init(value: float = 100.0) -> void:
	current = value
	maximum = value

func receive(value: float, tick: int, hero: bool) -> bool:
	if OS.has_feature("debug") and (debug_invincible or debug_god_mode): return false
	if dead or tick < invulnerable_until: return false
	current = maxf(0.0, current - value)
	hurt_until = tick + 8
	if hero: invulnerable_until = tick + 45
	dead = current <= 0.0
	return true

func heal(value: float) -> void:
	if not dead: current = minf(maximum, current + maxf(value, 0.0))
