class_name SpawnDirector
extends RefCounted

var reservations: Array[Dictionary] = []
var boss_pending: bool = false
var boss_placed: bool = false
var opening_origin: Vector2
var opening_initialized: bool = false
var reservation_serial: int = 0
var disposed: bool = false

func initialize_opening(origin: Vector2) -> void:
	if opening_initialized: return
	opening_origin = origin
	opening_initialized = true

static func edge_candidate(rng: RandomNumberGenerator) -> Vector2:
	# Exactly two RNG draws per attempt: edge then coordinate, clockwise edges.
	var edge = rng.randi_range(0, 3)
	var fraction = rng.randf()
	match edge:
		0: return Vector2(16 + fraction * 928, 16)
		1: return Vector2(944, 16 + fraction * 508)
		2: return Vector2(944 - fraction * 928, 524)
		_: return Vector2(16, 524 - fraction * 508)

func opening_candidate(rng: RandomNumberGenerator, field: FieldDefinition, index: int) -> Vector2:
	var angle = (index % 4 + rng.randf()) * PI / 2.0
	var radius = rng.randf_range(field.opening_radius_min, field.opening_radius_max)
	return opening_origin + Vector2.from_angle(angle) * radius

static func safe(run, point: Vector2, boss: bool = false, separation: float = 96.0) -> bool:
	if not Rect2(8, 8, 944, 524).has_point(point): return false
	for member in run.party:
		if not member.health.dead and point.distance_to(member.position) < separation: return false
	if boss:
		for actor in run.enemies:
			if not actor.health.dead and point.distance_to(actor.position) < 40: return false
	return true

func available(run) -> bool:
	return not disposed and run.phase == "active"

func plan(run, id_value: StringName, tick: int, source: String, index: int = -1, modifiers: Dictionary = {}) -> Dictionary:
	reservation_serial += 1
	var record = {"reservation_id": reservation_serial, "generation": run.generation, "scheduled_tick": tick, "slot_index": index, "source": source, "id": id_value, "attempts": 0, "modifiers": (run.corruption.modifiers() if modifiers.is_empty() else modifiers).duplicate(true)}
	record_event(run, record, tick, "planned")
	return record

func record_event(run, record: Dictionary, tick: int, result: String, extra: Dictionary = {}) -> void:
	if disposed: return
	var entry = record.duplicate(true)
	entry.merge(extra, true)
	entry["tick"] = tick
	entry["result"] = result
	run.trace.spawns.append(entry)

func full(run) -> bool:
	var regular = run.enemies.filter(func(actor): return not actor.is_boss and not actor.health.dead).size()
	return regular + reservations.filter(func(slot): return not slot.boss).size() >= 100

func reserve(run, id_value: StringName, point: Vector2, tick: int, parent: int = -1, boss: bool = false, modifiers: Dictionary = {}, record: Dictionary = {}) -> bool:
	if not available(run): return false
	if record.is_empty():
		record = plan(run, id_value, tick, "boss" if boss else ("summon" if parent >= 0 else "edge"), -1, modifiers)
		record["attempts"] = 1
		record_event(run, record, tick, "candidate", {"point": [point.x, point.y]})
	if not boss and (tick >= 32400 or full(run)):
		record_event(run, record, tick, "cap")
		return false
	if not safe(run, point, boss, 24 if parent >= 0 else run.catalog.field.separation):
		record_event(run, record, tick, "unsafe", {"point": [point.x, point.y]})
		return false
	var due = tick + run.catalog.field.spawn_warning_ticks
	var warning = run.create_warning(point, "circle", 28 if boss else 13, Vector2.RIGHT, 70, due)
	# Opening circles stay in world space above HUD, below modal and DEV layers.
	if record.source == "opening": warning.reparent(run.opening_warnings)
	var slot = record.duplicate(true)
	slot.merge({"point": point, "due": due, "parent": parent, "boss": boss, "warning": warning}, true)
	reservations.append(slot)
	record_event(run, record, tick, "warned", {"point": [point.x, point.y], "due": due})
	return true

func schedule_wave(run, tick: int) -> void:
	if not available(run) or tick >= 32400: return
	var modifiers = run.corruption.modifiers()
	var ids = run.catalog.waves.composition(tick, run.rng.stream("wave_types"), modifiers)
	run.trace.waves.append({"tick": tick, "ids": ids.duplicate()})
	for index in ids.size():
		var id_value = ids[index]
		var record = plan(run, id_value, tick, "opening" if tick == 0 else "edge", index, modifiers)
		if full(run):
			record_event(run, record, tick, "cap")
			continue
		var found = false
		for attempt in run.catalog.field.opening_attempts:
			var candidate = opening_candidate(run.rng.stream("spawn_positions"), run.catalog.field, index) if tick == 0 else edge_candidate(run.rng.stream("spawn_positions"))
			record["attempts"] = attempt + 1
			record_event(run, record, tick, "candidate", {"point": [candidate.x, candidate.y]})
			if safe(run, candidate):
				found = reserve(run, id_value, candidate, tick, -1, false, modifiers, record)
				break
		if not found: record_event(run, record, tick, "unsafe")

func summon(run, mother, tick: int) -> void:
	if not available(run) or tick >= 32400 or mother.health.dead: return
	var children = 0
	for actor in run.enemies:
		if actor.parent_id == mother.actor_id and not actor.health.dead: children += 1
	for slot in reservations:
		if slot.parent == mother.actor_id: children += 1
	if children >= 3: return
	var record = plan(run, &"broodling", tick, "summon")
	if full(run):
		record_event(run, record, tick, "cap")
		return
	for offset in [Vector2(24, 0), Vector2(0, 24), Vector2(-24, 0), Vector2(0, -24)]:
		var candidate = mother.position + offset
		record["attempts"] += 1
		record_event(run, record, tick, "candidate", {"point": [candidate.x, candidate.y]})
		if safe(run, candidate, false, 24):
			reserve(run, &"broodling", candidate, tick, mother.actor_id, false, {}, record)
			return
	record_event(run, record, tick, "unsafe")

func trace_slot(slot: Dictionary) -> Dictionary:
	var record = slot.duplicate()
	record.erase("warning")
	record["point"] = [slot.point.x, slot.point.y]
	return record

func simulate(run, tick: int) -> void:
	if not available(run): return
	if tick >= 32400: boss_pending = not boss_placed
	for index in range(reservations.size() - 1, -1, -1):
		var slot = reservations[index]
		var parent = run.actor_by_id(slot.parent) if slot.parent >= 0 else null
		var reason = ""
		if not slot.boss:
			if tick >= 32400: reason = "boss_boundary"
			elif slot.parent >= 0 and (parent == null or parent.health.dead): reason = "parent_dead"
		if tick < slot.due and reason.is_empty(): continue
		if reason.is_empty() and not safe(run, slot.point, slot.boss, 24 if slot.parent >= 0 else 96): reason = "unsafe_at_activation"
		if reason.is_empty():
			var actor = run.spawn_enemy(slot.id, slot.point, slot.parent, slot.boss, slot.modifiers)
			record_event(run, trace_slot(slot), tick, "activated", {"actor_id": actor.actor_id})
		else:
			record_event(run, trace_slot(slot), tick, "canceled", {"reason": reason})
			if slot.boss:
				boss_placed = false
				boss_pending = true
		if is_instance_valid(slot.warning): slot.warning.queue_free()
		reservations.remove_at(index)
	if boss_pending and not boss_placed:
		for point in [Vector2(480, 48), Vector2(912, 270), Vector2(480, 492), Vector2(48, 270), Vector2(48, 48), Vector2(912, 492)]:
			if reserve(run, &"tidebound_hierophant", point, tick, -1, true):
				boss_placed = true
				boss_pending = false
				break

func terminate(run) -> void:
	if disposed: return
	for slot in reservations:
		record_event(run, trace_slot(slot), run.clock.tick, "canceled", {"reason": "run_end"})
		if is_instance_valid(slot.warning): slot.warning.queue_free()
	reservations.clear()
	disposed = true
