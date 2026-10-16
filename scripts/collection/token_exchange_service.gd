class_name TokenExchangeService
extends RefCounted

static func reason(payload: Dictionary, hero: String) -> String:
	if hero not in ["brann", "nyra"]: return "Choose Brann or Nyra."
	if payload.owned.has(hero): return "Already owned."
	if not RecruitmentHistory.awaiting(payload).is_empty(): return "Reveal the saved draw first."
	if payload.tokens < 5: return "Requires 5 duplicate tokens."
	return ""

static func candidate(payload: Dictionary, hero: String) -> Dictionary:
	if reason(payload, hero) != "": return {}
	var next = payload.duplicate(true)
	next.tokens -= 5
	next.owned[hero] = OwnedHero.record(hero)
	return next

static func confirm(writer: SaveCoordinator, hero: String, revision: int, operation: String) -> bool:
	if writer.receipts.has(operation): return true
	if writer.state != "ready" or writer.revision() != revision: return false
	var next = candidate(writer.payload, hero)
	if next.is_empty(): return false
	return writer.mutate(next, revision, operation, {"kind": "exchange", "hero": hero})
