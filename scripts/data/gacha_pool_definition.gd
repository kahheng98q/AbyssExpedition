class_name GachaPoolDefinition
extends Resource

@export var id: StringName = &"guild_pool"
@export var entries: Array[GachaEntry] = []
@export var single_cost: int = 1
@export var batch_count: int = 10
@export var batch_cost: int = 10
@export var duplicate_tokens: int = 1
@export var exchange_cost: int = 5

func validate() -> String:
	if entries.size() != 2 or single_cost != 1 or batch_count != 10 or batch_cost != 10 or duplicate_tokens != 1 or exchange_cost != 5: return "invalid guild pool costs/size"
	var ids = []
	for entry in entries:
		if entry == null or entry.validate() != "" or ids.has(entry.character_id): return "invalid or duplicate pool entry"
		ids.append(entry.character_id)
	return ""

func total_weight() -> int:
	var total = 0
	for entry in entries: total += entry.integer_weight
	return total

func hero_at(interval: int) -> String:
	for entry in entries:
		if interval < entry.integer_weight: return String(entry.character_id)
		interval -= entry.integer_weight
	return ""
