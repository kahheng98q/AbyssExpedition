class_name ProfileMigrations
extends RefCounted

static func v2_to_v3(payload: Dictionary) -> Dictionary:
	var next = payload.duplicate(true)
	next["chapters"] = {"coast": false}
	return next

static func v1_to_v2(payload: Dictionary, independent_seed: String) -> Dictionary:
	var next = payload.duplicate(true)
	next["tickets"] = 0
	next["tokens"] = 0
	next["history"] = []
	next["draw_rng"] = DrawRng.initial(independent_seed)
	return next

static func v3_to_v4(payload: Dictionary) -> Dictionary:
	var next = payload.duplicate(true)
	next.erase("promotion_items")
	for id in next.owned: next.owned[id] = OwnedHero.record(String(id))
	return next

static func upgrade(payload: Dictionary, schema: int) -> Dictionary:
	var next = payload.duplicate(true)
	if schema < 2: next = v1_to_v2(next, DrawRng.initial().seed)
	if schema < 3: next = v2_to_v3(next)
	if schema < 4: next = v3_to_v4(next)
	return next
