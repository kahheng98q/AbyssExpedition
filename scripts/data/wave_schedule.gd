class_name WaveSchedule
extends Resource

@export var id: StringName = &"coast_waves"
@export var interval: int = 600
@export var stop_tick: int = 32400
@export var cap: int = 100
@export var phases: Array[Dictionary] = []
@export var opening_segments: Array[Dictionary] = []

func phase_at(tick: int) -> Dictionary:
	for phase in phases:
		if tick >= phase.start and tick < phase.end: return phase
	return {}

func opening_segment_at(tick: int) -> Dictionary:
	for segment in opening_segments:
		if tick >= segment.start and tick < segment.end: return segment
	return {}

func composition(tick: int, rng: RandomNumberGenerator, modifiers: Dictionary = {}) -> Array[StringName]:
	var result: Array[StringName] = []
	var phase = phase_at(tick)
	if phase.is_empty(): return result
	if tick < 7200:
		var segment = opening_segment_at(tick)
		# Invalid authored data is rejected by validate, never silently fallback.
		if segment.is_empty(): return result
		for id_value in segment.slots: result.append(StringName(id_value))
		var count = ceili(4 * modifiers.get("count", 1.0))
		while result.size() < count: result.append(&"saltbound_thrall")
		var thralls = result.count(&"saltbound_thrall")
		for index in result.size():
			var roll = rng.randi_range(0, 10 * thralls - 1)
			if modifiers.get("brood", false) and result[index] == &"saltbound_thrall" and roll < count:
				result[index] = &"reef_broodmother"
		return result
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
	var starts = [0, 1800, 3600, 5400, 6600]
	var ends = [1800, 3600, 5400, 6600, 7200]
	var t = "saltbound_thrall"
	var b = "skittering_brinejaw"
	var c = "lantern_cantor"
	var exact = [[t,t,t,t], [t,t,t,b], [t,t,t,c], [t,t,t,t], [t,t,b,c]]
	if opening_segments.size() != 5: return "opening requires five segments"
	for index in 5:
		var segment = opening_segments[index]
		for key in ["start", "end", "slots"]:
			if not segment.has(key): return "missing opening field " + key
		if not segment.start is int or not segment.end is int or not segment.slots is Array: return "invalid opening field type"
		if segment.start != starts[index] or segment.end != ends[index] or segment.start % 600 != 0 or segment.end % 600 != 0: return "opening ranges/gaps/overlap"
		if segment.slots.size() != 4: return "opening requires four slots"
		for id_value in segment.slots:
			if not id_value is String and not id_value is StringName: return "invalid opening ID type"
		if segment.slots.map(func(id_value): return String(id_value)) != exact[index]: return "opening slot order/unknown ID"
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
