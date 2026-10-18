class_name RecruitmentService
extends RefCounted

static func candidate(payload: Dictionary, count: int, operation: String, provider = null) -> Dictionary:
	if ProfileValidator.payload_error(payload) != "" or count not in [1, 10] or payload.tickets < count or operation.is_empty(): return {}
	if not RecruitmentHistory.awaiting(payload).is_empty(): return {}
	if payload.draw_rng.index > ProfileData.MAX_INTEGER - count or payload.tokens > ProfileData.MAX_INTEGER - count: return {}
	for receipt in payload.history:
		if receipt.operation_id == operation: return {}
	var pool: GachaPoolDefinition = load("res://data/gacha/guild_pool.tres")
	var next = payload.duplicate(true)
	var rng = DrawRng.restore(payload.draw_rng)
	var results = []
	for i in range(count):
		var interval = DrawRng.draw(rng)
		if provider != null: interval = provider.draw(rng)
		if interval not in [0, 1]: return {}
		var id = pool.hero_at(interval)
		var duplicate = next.owned.has(id)
		if duplicate: next.tokens += pool.duplicate_tokens
		else: next.owned[id] = OwnedHero.record(id)
		results.append({"hero": id, "duplicate": duplicate, "tokens": pool.duplicate_tokens if duplicate else 0})
	next.tickets -= count
	next.draw_rng.state = str(rng.state)
	next.draw_rng.index += count
	next.history.append({"operation_id": operation, "pool": String(pool.id), "version": 1, "cost": count, "sequence_start": payload.draw_rng.index, "sequence_end": next.draw_rng.index, "results": results, "awaiting_reveal": true})
	return next

static func confirm(writer: SaveCoordinator, count: int, revision: int, operation: String, provider = null) -> bool:
	if writer.receipts.has(operation): return true
	if writer.state != "ready" or writer.revision() != revision: return false
	var next = candidate(writer.payload, count, operation, provider)
	if next.is_empty(): return false
	return writer.mutate(next, revision, operation, {"kind": "draw", "draw": operation})
