class_name PermanentProgression
extends RefCounted

static func preview(outcome: String, ticks: int, rescue: Dictionary = {}) -> Dictionary:
	if outcome not in ["victory", "defeat"]: return {"tickets": 0, "sera": false}
	ticks = maxi(0, ticks)
	var rescued = rescue.get("state") == "succeeded"
	var repeat = rescued and rescue.get("owned_at_start", false)
	return {"tickets": (1 if ticks >= 18000 else 0) + (2 if outcome == "victory" else 0) + int(rescue.get("repeat_successes", 1 if repeat else 0)), "sera": rescued and not repeat}

static func settle(payload: Dictionary, summary: Dictionary) -> Dictionary:
	var rewards = preview(summary.outcome, int(summary.ticks), summary.get("rescue", {}))
	if payload.tickets > ProfileData.MAX_INTEGER - rewards.tickets: return {}
	var next = payload.duplicate(true)
	var seen = {}
	for id in summary.get("participants", [String(summary.hero)]):
		if not next.owned.has(String(id)) or seen.has(String(id)): return {}
		seen[String(id)] = true

	next.tickets += rewards.tickets
	if rewards.sera and not next.owned.has("sera"): next.owned.sera = OwnedHero.record("sera")
	if summary.outcome == "victory": next.chapters.coast = true
	return next

static func settlement_receipt(summary: Dictionary) -> Dictionary:
	# Diagnostics can grow with every input. Keep them out of the bounded profile.
	# The complete immutable trace remains in the in-session result, never resumes a run.
	var durable = {}
	for key in ["outcome", "hero", "seed", "ticks", "participants", "rewards", "chapter"]:
		if summary.has(key): durable[key] = summary[key]
	return {"kind": "settlement", "summary": durable}
