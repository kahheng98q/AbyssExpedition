class_name PermanentProgression
extends RefCounted

static func preview(outcome: String, ticks: int, rescue: Dictionary = {}) -> Dictionary:
	if outcome not in ["victory", "defeat"]: return {"xp": 0, "items": 0, "tickets": 0, "sera": false}
	ticks = maxi(0, ticks)
	var rescued = rescue.get("state") == "succeeded"
	var repeat = rescued and rescue.get("owned_at_start", false)
	return {"xp": 20 * (ticks / 3600) + (100 if outcome == "victory" else 0), "items": 1 if outcome == "victory" else 0, "tickets": (1 if ticks >= 18000 else 0) + (2 if outcome == "victory" else 0) + int(rescue.get("repeat_successes", 1 if repeat else 0)), "sera": rescued and not repeat}

static func settle(payload: Dictionary, summary: Dictionary) -> Dictionary:
	var rewards = preview(summary.outcome, int(summary.ticks), summary.get("rescue", {}))
	if payload.promotion_items > ProfileData.MAX_INTEGER - rewards.items: return {}
	if payload.tickets > ProfileData.MAX_INTEGER - rewards.tickets: return {}
	var next = payload.duplicate(true)
	var seen = {}
	for id in summary.get("participants", [String(summary.hero)]):
		if not next.owned.has(String(id)) or seen.has(String(id)): return {}
		seen[String(id)] = true
		var h = next.owned[String(id)]
		next.owned[String(id)] = OwnedHero.record(String(id), mini(2900, int(h.total_xp) + rewards.xp), h.promotion_id)
	next.promotion_items += rewards.items
	next.tickets += rewards.tickets
	if rewards.sera and not next.owned.has("sera"): next.owned.sera = OwnedHero.record("sera")
	if summary.outcome == "victory": next.chapters.coast = true
	return next

static func add_character_xp(payload: Dictionary, character_id: String, value: int) -> Dictionary:
	if value < 0 or not payload.owned.has(character_id): return {}
	var next = payload.duplicate(true)
	var h = next.owned[character_id]
	next.owned[character_id] = OwnedHero.record(character_id, int(h.total_xp) + mini(value, 2900), h.promotion_id)
	return next

static func settlement_gains(before: Dictionary, after: Dictionary, participants: Array) -> Array:
	var rows: Array = []
	for id in participants:
		var prior = before.owned[String(id)]
		var current = after.owned[String(id)]
		rows.append({"id": String(id), "xp": int(current.total_xp) - int(prior.total_xp), "from_level": int(prior.level), "level": int(current.level), "capped": int(current.level) == 30})
	return rows

static func settlement_receipt(summary: Dictionary) -> Dictionary:
	# Diagnostics can grow with every input. Keep them out of the bounded profile.
	# The complete immutable trace remains in the in-session result, never resumes a run.
	var durable = {}
	for key in ["outcome", "hero", "seed", "ticks", "participants", "rewards", "participant_gains", "chapter"]:
		if summary.has(key): durable[key] = summary[key]
	return {"kind": "settlement", "summary": durable}
