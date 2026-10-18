class_name SpawnDirector
extends RefCounted

var reservations: Array[Dictionary] = []
var boss_pending: bool = false
var boss_placed: bool = false

static func edge_candidate(rng: RandomNumberGenerator) -> Vector2:
	# Exactly two RNG draws per attempt: edge then coordinate, clockwise edges.
	var edge = rng.randi_range(0, 3)
	var fraction = rng.randf()
	match edge:
		0: return Vector2(16 + fraction * 928, 16)
		1: return Vector2(944, 16 + fraction * 508)
		2: return Vector2(944 - fraction * 928, 524)
		_: return Vector2(16, 524 - fraction * 508)

static func safe(run, point: Vector2, boss: bool = false, separation: float = 96.0) -> bool:
	if not Rect2(8, 8, 944, 524).has_point(point): return false
	for member in run.party:
		if not member.health.dead and point.distance_to(member.position) < separation: return false
	if boss:
		for actor in run.enemies:
			if not actor.health.dead and point.distance_to(actor.position) < 40: return false
	return true

func reserve(run, id_value: StringName, point: Vector2, tick: int, parent: int = -1, boss: bool = false, modifiers: Dictionary = {}) -> bool:
	if not boss and (tick >= 32400 or run.enemies.size() + reservations.size() >= 100): return false
	if not safe(run, point, boss, 24 if parent >= 0 else 96): return false
	var warning = run.create_warning(point, "circle", 28 if boss else 13, Vector2.RIGHT, 70, tick + 45)
	reservations.append({"id": id_value, "point": point, "due": tick + 45, "parent": parent, "boss": boss, "warning": warning, "modifiers": run.corruption.modifiers() if modifiers.is_empty() else modifiers.duplicate(true)})
	return true

func schedule_wave(run, tick: int) -> void:
	var modifiers = run.corruption.modifiers()
	var ids = run.catalog.waves.composition(tick, run.rng.stream("wave_types"), modifiers)
	run.trace.waves.append({"tick": tick, "ids": ids.duplicate()})
	for id_value in ids:
		if run.enemies.size() + reservations.size() >= 100:
			run.trace.spawns.append({"tick": tick, "id": id_value, "attempts": 0, "result": "cap"})
			continue
		var attempts = 0
		var candidate = Vector2.ZERO
		var found = false
		while attempts < 16:
			candidate = edge_candidate(run.rng.stream("spawn_positions"))
			attempts += 1
			if safe(run, candidate):
				found = reserve(run, id_value, candidate, tick, -1, false, modifiers)
				break
		run.trace.spawns.append({"tick": tick, "id": id_value, "point": [candidate.x, candidate.y], "attempts": attempts, "result": "warned" if found else "unsafe"})

func summon(run, mother, tick: int) -> void:
	if tick >= 32400 or mother.health.dead: return
	var children = 0
	for actor in run.enemies:
		if actor.parent_id == mother.actor_id and not actor.health.dead: children += 1
	for slot in reservations:
		if slot.parent == mother.actor_id: children += 1
	if children >= 3: return
	for offset in [Vector2(24, 0), Vector2(0, 24), Vector2(-24, 0), Vector2(0, -24)]:
		if reserve(run, &"broodling", mother.position + offset, tick, mother.actor_id): return

func simulate(run, tick: int) -> void:
	if tick >= 32400: boss_pending = not boss_placed
	for index in range(reservations.size() - 1, -1, -1):
		var slot = reservations[index]
		var parent = run.actor_by_id(slot.parent) if slot.parent >= 0 else null
		var canceled = not slot.boss and (tick >= 32400 or (slot.parent >= 0 and (parent == null or parent.health.dead)))
		if tick < slot.due and not canceled: continue
		if not canceled and safe(run, slot.point, slot.boss, 24 if slot.parent >= 0 else 96):
			run.spawn_enemy(slot.id, slot.point, slot.parent, slot.boss, slot.modifiers)
		elif slot.boss:
			boss_placed = false
			boss_pending = true
		if is_instance_valid(slot.warning): slot.warning.queue_free()
		reservations.remove_at(index)
	if boss_pending and not boss_placed:
		# One retained request; deterministic candidate search, no discarded only boss.
		for point in [Vector2(480, 48), Vector2(912, 270), Vector2(480, 492), Vector2(48, 270), Vector2(48, 48), Vector2(912, 492)]:
			if reserve(run, &"tidebound_hierophant", point, tick, -1, true):
				boss_placed = true
				boss_pending = false
				break
