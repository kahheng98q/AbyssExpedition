class_name EventDirector
extends RefCounted

var next_slot: int = 0
var current: Dictionary = {}

const SLOTS = [7200, 14400, 21600]

func offer(tick: int, owned: bool, rng: RandomNumberGenerator) -> Dictionary:
	if not current.is_empty(): return current.duplicate(true)
	if tick >= 32400: return {}
	# Active simulation reaches every slot; skipped fixture/debug time has no backlog.
	while next_slot < SLOTS.size() and SLOTS[next_slot] < tick: next_slot += 1
	if next_slot >= SLOTS.size() or tick != SLOTS[next_slot]: return {}
	var kind: String
	if not owned and tick == 14400: kind = "lost_adventurer"
	elif owned: kind = ["mysterious_merchant", "forbidden_altar", "lost_adventurer"][rng.randi_range(0, 2)]
	else: kind = ["mysterious_merchant", "forbidden_altar"][rng.randi_range(0, 1)]
	current = {"id": next_slot + 1, "tick": tick, "kind": kind}
	next_slot += 1
	return current.duplicate(true)

func resolve(identity: int) -> bool:
	if current.is_empty() or current.id != identity: return false
	current = {}
	return true
