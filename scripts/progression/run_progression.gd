class_name RunProgression
extends RefCounted

var level: int = 1
var xp: int = 0
var pending: int = 0
var stacks: Dictionary = {}
var pickups: Dictionary = {}

func collect_xp(id_value: int, value: int) -> bool:
	if pickups.has(id_value) or value < 0: return false
	pickups[id_value] = true
	xp += value
	while xp >= 100 * level:
		xp -= 100 * level
		level += 1
		pending += 1
	return true

func has(id_value: StringName) -> bool:
	return stacks.get(id_value, 0) > 0
