class_name SeedStreams
extends RefCounted

const LABELS = ["wave_types", "spawn_positions", "upgrade_offers", "event_offers"]
var streams: Dictionary = {}

static func valid_seed(value: String) -> bool:
	if value.is_empty() or not value.is_valid_int(): return false
	for c in value:
		if c < "0" or c > "9": return false
	return value.length() <= 10 and value.to_int() <= 2147483647

static func derive(value: int, label: String) -> int:
	var bytes = ("abyss-rng-v1|%d|%s" % [value, label]).sha256_buffer()
	var number: int = bytes[0] & 0x7f
	for i in range(1, 8): number = (number << 8) | bytes[i]
	return number

func _init(value: int = 0) -> void:
	assert(value >= 0 and value <= 2147483647)
	for label in LABELS:
		var rng = RandomNumberGenerator.new()
		rng.seed = derive(value, label)
		streams[label] = rng

func stream(label: String) -> RandomNumberGenerator:
	return streams[label]
