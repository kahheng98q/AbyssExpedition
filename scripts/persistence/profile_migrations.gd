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
