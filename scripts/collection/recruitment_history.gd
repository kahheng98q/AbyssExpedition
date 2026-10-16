class_name RecruitmentHistory
extends RefCounted

static func awaiting(payload: Dictionary) -> Dictionary:
	for receipt in payload.get("history", []):
		if receipt.awaiting_reveal: return receipt.duplicate(true)
	return {}

static func acknowledge(writer: SaveCoordinator, draw: String, revision: int, operation: String) -> bool:
	if writer.receipts.has(operation): return true
	if writer.state != "ready" or writer.revision() != revision: return false
	var next = writer.payload.duplicate(true)
	for receipt in next.history:
		if receipt.operation_id != draw: continue
		if not receipt.awaiting_reveal: return false
		receipt.awaiting_reveal = false
		return writer.mutate(next, revision, operation, {"kind": "reveal", "draw": draw})
	return false

static func validate(history, index: int, owned: Dictionary) -> String:
	if not history is Array: return "Invalid recruitment history."
	var seen = {}
	var acquired = {}
	var expected = 0
	var pending = false
	for receipt in history:
		if not receipt is Dictionary: return "Invalid draw receipt."
		if not receipt.get("operation_id") is String or receipt.operation_id.is_empty() or seen.has(receipt.operation_id): return "Invalid draw identity."
		seen[receipt.operation_id] = true
		if receipt.get("pool") != "guild_pool" or receipt.get("version") != 1 or not ProfileValidator.integer(receipt.get("cost"), 1, 10): return "Invalid draw pool/cost."
		if int(receipt.cost) not in [1, 10]: return "Invalid draw cost."
		if not ProfileValidator.integer(receipt.get("sequence_start")) or not ProfileValidator.integer(receipt.get("sequence_end")) or receipt.sequence_start != expected or receipt.sequence_end != expected + receipt.cost: return "Invalid draw sequence."
		expected += int(receipt.cost)
		if not receipt.get("awaiting_reveal") is bool or pending: return "Invalid reveal ordering."
		pending = receipt.awaiting_reveal
		if not receipt.get("results") is Array or receipt.results.size() != receipt.cost: return "Invalid draw count."
		for result in receipt.results:
			if not result is Dictionary or result.get("hero") not in ["brann", "nyra"]: return "Invalid draw hero."
			if not result.get("duplicate") is bool or not ProfileValidator.integer(result.get("tokens"), 0, 1) or result.tokens != (1 if result.duplicate else 0): return "Invalid duplicate conversion."
			if not owned.has(result.hero) or (acquired.has(result.hero) and not result.duplicate): return "Invalid draw ownership."
			acquired[result.hero] = true
	if expected != index: return "Draw index/history mismatch."
	return ""
