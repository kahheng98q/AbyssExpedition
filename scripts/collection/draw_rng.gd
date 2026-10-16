class_name DrawRng
extends RefCounted

static func initial(seed_value: String = "") -> Dictionary:
	var rng = RandomNumberGenerator.new()
	if seed_value == "": rng.randomize()
	else: rng.seed = seed_value.to_int()
	return {"seed": str(rng.seed), "state": str(rng.state), "index": 0}

static func restore(saved: Dictionary) -> RandomNumberGenerator:
	var rng = RandomNumberGenerator.new()
	rng.seed = String(saved.seed).to_int()
	rng.state = String(saved.state).to_int()
	return rng

static func decimal(value) -> bool:
	if not value is String or value.is_empty() or value.length() > 20: return false
	return str(value.to_int()) == value

static func draw(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(0, 1)
