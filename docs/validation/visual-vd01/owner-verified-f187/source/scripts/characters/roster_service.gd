class_name RosterService
extends RefCounted

static func selection(payload: Dictionary, active: String, companions: Array, seed_value: int) -> Dictionary:
	if ProfileValidator.party(payload, active, companions) != "" or seed_value < 0 or seed_value > 2147483647: return {}
	var next = payload.duplicate(true)
	next.active = active
	next.companions = companions.duplicate()
	next.seed = seed_value
	return next

static func snapshot(payload: Dictionary, seed_value: int) -> RunStartSnapshot:
	var members: Array = []
	for id in [payload.active] + payload.companions:
		var record = payload.owned[id]
		members.append({"id": id, "level": int(record.level), "profession": record.promotion_id if record.promotion_id != "" else ProfileData.BASES[id], "passive": ProfileData.PASSIVES[id]})
	return RunStartSnapshot.new(seed_value, StringName(payload.active), members, payload.owned.has("sera"))
