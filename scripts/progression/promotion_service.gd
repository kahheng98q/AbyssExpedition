class_name PromotionService
extends RefCounted

static func reason(payload: Dictionary, hero_id: String, branch: String = "") -> String:
	if not payload.owned.has(hero_id): return "Character is not owned."
	var h = payload.owned[hero_id]
	if h.promotion_id != "": return "Already promoted; this choice is permanent."
	if h.level < 15: return "Requires permanent level 15."
	if payload.promotion_items < 1: return "Requires one promotion item."
	if branch != "" and ProfileData.BRANCHES.get(branch) != ProfileData.BASES[hero_id]: return "Branch belongs to another base class."
	return ""

static func candidate(payload: Dictionary, hero_id: String, branch: String) -> Dictionary:
	if branch.is_empty() or reason(payload, hero_id, branch) != "": return {}
	var next = payload.duplicate(true)
	next.promotion_items -= 1
	next.owned[hero_id].promotion_id = branch
	return next

static func confirm(writer: SaveCoordinator, hero_id: String, branch: String, expected_revision: int, operation: String) -> bool:
	if writer.receipts.has(operation): return true
	var next = candidate(writer.payload, hero_id, branch)
	if next.is_empty():
		writer.error = reason(writer.payload, hero_id, branch)
		return false
	return writer.mutate(next, expected_revision, operation, {"kind": "promotion", "hero": hero_id, "branch": branch})
