class_name WaveSchedule
extends Resource

@export var id: StringName = &"coast_waves"
@export var interval: int = 600
@export var stop_tick: int = 32400
@export var cap: int = 100
@export var phases: Array[Dictionary] = []

func phase_at(tick: int) -> Dictionary:
	for phase in phases:
		if tick >= phase.start and tick < phase.end: return phase
	return {}

func composition(tick: int, rng: RandomNumberGenerator, modifiers: Dictionary = {}) -> Array[StringName]:
	var result: Array[StringName] = []
	var phase = phase_at(tick)
	if phase.is_empty(): return result
	var weights = phase.weights.duplicate()
	for i in ceili(phase.count * modifiers.get("count", 1.0)):
		var roll = rng.randi_range(0, 99)
		if modifiers.get("brood", false) and roll < 10:
			result.append(&"reef_broodmother")
			continue
		var total = 0
		for j in phase.ids.size():
			total += weights[j]
			if roll < total:
				result.append(StringName(phase.ids[j]))
				break
	if tick == phase.start:
		for id_value in phase.introduce:
			if not result.has(StringName(id_value)):
				var index = result.find(&"saltbound_thrall")
				if index < 0: index = 0
				result[index] = StringName(id_value)
	return result

func validate() -> String:
	if interval != 600 or stop_tick != 32400 or cap != 100 or phases.size() != 5: return "M1 schedule constants mismatch"
	var counts = [4, 6, 8, 10, 12]
	var weights = [[100], [70, 30], [50, 25, 25], [40, 20, 20, 20], [30, 20, 20, 20, 10]]
	var ids = ["saltbound_thrall", "skittering_brinejaw", "lantern_cantor", "shellbound_husk", "reef_broodmother"]
	for i in range(5):
		var p = phases[i]
		for key in ["start", "end", "count", "ids", "weights", "introduce"]:
			if not p.has(key): return "missing phase field " + key
		if not p.ids is Array or not p.weights is Array or not p.introduce is Array: return "phase lists must be arrays"
		if p.ids != ids.slice(0, i + 1) or p.introduce != ([] if i == 0 else [ids[i]]): return "unknown/duplicate stage IDs or introduction reference"
		if p.start != i * 7200 or p.end != mini(32400, (i + 1) * 7200) or p.count != counts[i]: return "invalid phase ranges/count"
		if p.weights != weights[i]: return "M1 weight mix mismatch"
		if p.ids.size() != p.weights.size() or p.count <= 0: return "invalid phase"
		var sum = 0
		for weight in p.weights:
			if weight < 0: return "negative weight"
			sum += weight
		if sum != 100: return "weights must total 100"
	return ""
