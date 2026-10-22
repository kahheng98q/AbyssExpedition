class_name ProfileValidator
extends RefCounted

static func integer(value, low: int = 0, high: int = ProfileData.MAX_INTEGER) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= low and value <= high and float(value) == floor(float(value))

static func party(payload: Dictionary, active: String, companions: Array) -> String:
	if not payload.get("owned", {}).has(active): return "Active character is not owned."
	if companions.size() > 2: return "Choose at most two companions."
	var seen = [active]
	for id in companions:
		if not id is String or not payload.owned.has(id): return "Companion is not owned."
		if seen.has(id): return "Party members must be distinct."
		seen.append(id)
	return ""

static func payload_error(p, schema: int = ProfileData.SCHEMA) -> String:
	if not p is Dictionary: return "Payload must be an object."
	for key in ["owned", "active", "companions", "seed", "receipt"]:
		if not p.has(key): return "Missing payload field: " + key
	if not p.owned is Dictionary or p.owned.size() < 3 or p.owned.size() > (3 if schema == 1 else 6): return "Invalid owned roster size."
	for id in ProfileData.STARTERS:
		if not p.owned.has(id): return "Missing starter " + id
	for id in p.owned:
		if not ProfileData.BASES.has(id) or (schema == 1 and id not in ProfileData.STARTERS): return "Unknown hero."
		var h = p.owned[id]
		if not h is Dictionary: return "Invalid owned record."
		if schema >= 4:
			if h.size() != 1 or not h.get("character_id") is String or h.character_id != String(id): return "Owned record must contain identity only."
		else:
			if h.get("character_id") != id or not integer(h.get("total_xp"), 0, 2900): return "Invalid character XP/identity."
			if not integer(h.get("level"), 1, 30) or int(h.level) != OwnedHero.level(int(h.total_xp)): return "Invalid derived level."
			if not integer(h.get("progress_to_next"), 0, 99) or int(h.progress_to_next) != (int(h.total_xp) % 100 if h.total_xp < 2900 else 0): return "Invalid derived XP."
			var branch = h.get("promotion_id")
			if not branch is String: return "Invalid promotion."
			if branch != "" and (ProfileData.BRANCHES.get(branch) != ProfileData.BASES[id] or h.level < 15): return "Wrong base class or promotion level."
	if not p.active is String or not p.companions is Array: return "Invalid party fields."
	var reason = party(p, p.active, p.companions)
	if reason != "": return reason
	if not integer(p.seed, 0, 2147483647): return "Invalid seed."
	if schema < 4 and not integer(p.get("promotion_items")): return "Invalid legacy material balance."
	if schema >= 4:
		for key in ["promotion_items", "level", "total_xp", "promotion_id", "branches", "pending_promotion"]:
			if p.has(key): return "Run progression cannot be saved: " + key
	if not p.receipt is Dictionary: return "Invalid receipt."
	if not p.receipt.is_empty():
		if not p.receipt.get("operation_id") is String or not integer(p.receipt.get("base_revision")) or not integer(p.receipt.get("result_revision"), 1): return "Invalid operation receipt."
		if p.receipt.result_revision != p.receipt.base_revision + 1 or not p.receipt.get("result") is Dictionary: return "Invalid receipt revision/result."
	if schema >= 2:
		if not integer(p.get("tickets")) or not integer(p.get("tokens")): return "Invalid recruitment balances."
		var draw = p.get("draw_rng")
		if not draw is Dictionary or not DrawRng.decimal(draw.get("seed")) or not DrawRng.decimal(draw.get("state")) or not integer(draw.get("index")): return "Invalid saved draw RNG."
		var history_error = RecruitmentHistory.validate(p.get("history"), int(draw.index), p.owned)
		if history_error != "": return history_error
	if schema >= 3:
		var chapters = p.get("chapters")
		if not chapters is Dictionary or chapters.size() != 1 or not chapters.get("coast") is bool: return "Invalid chapter completion flags."
		for forbidden in ["health", "xp", "upgrades", "time", "enemies", "coins", "corruption", "rescue", "event", "active_rescue", "pending_event"]:
			if p.has(forbidden): return "Expedition state cannot be resumed: " + forbidden
	return ""

static func decode(bytes: String) -> Dictionary:
	if bytes.to_utf8_buffer().size() > 1048576: return {"error": "Save exceeds size limit."}
	var parser = JSON.new()
	if parser.parse(bytes) != OK: return {"error": "Unreadable save envelope: " + parser.get_error_message()}
	var e = parser.data
	if not e is Dictionary: return {"error": "Unreadable save envelope."}
	for key in ["schema_version", "game_version", "content_version", "profile_id", "revision", "saved_at_utc", "operation_id", "payload_json", "payload_sha256"]:
		if not e.has(key): return {"error": "Missing envelope field: " + key}
	if not integer(e.schema_version, 1) or not integer(e.revision, 1): return {"error": "Invalid version/revision."}
	var legacy = (e.schema_version == 1 and e.game_version == "m2.0" and e.content_version == "m2.0") or (e.schema_version == 2 and e.game_version == "m3.0" and e.content_version == "m3.0") or (e.schema_version == 3 and e.game_version == "m4.0" and e.content_version == "m4.0")
	var current = e.schema_version == ProfileData.SCHEMA and e.game_version == ProfileData.GAME and e.content_version == ProfileData.CONTENT
	if not legacy and not current:
		return {"error": "Incompatible save version; files preserved.", "incompatible": true}
	for key in ["profile_id", "saved_at_utc", "operation_id", "payload_json", "payload_sha256"]:
		if not e[key] is String or e[key].is_empty(): return {"error": "Invalid envelope string: " + key}
	if e.profile_id != "default": return {"error": "Wrong profile identity."}
	if e.payload_json.sha256_text() != e.payload_sha256: return {"error": "Payload checksum mismatch."}
	if parser.parse(e.payload_json) != OK: return {"error": "Unreadable payload: " + parser.get_error_message()}
	var p = parser.data
	var reason = payload_error(p, int(e.schema_version))
	if reason != "": return {"error": reason}
	if not p.receipt.is_empty() and (p.receipt.operation_id != e.operation_id or p.receipt.result_revision != e.revision): return {"error": "Receipt does not match envelope."}
	return {"error": "", "envelope": e, "payload": p}
