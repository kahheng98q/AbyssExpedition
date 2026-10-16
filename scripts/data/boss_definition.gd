class_name BossDefinition
extends Resource

@export var id: StringName = &"tidebound_hierophant"
@export var stats: StatBlock
@export var visual_set: VisualSet
@export var patterns: Array[BossPattern] = []
@export var knockback_resistant: bool = true
@export var arrival_tick: int = 32400

func validate() -> String:
	if arrival_tick != 32400 or stats == null or visual_set == null or patterns.size() < 2: return "invalid boss definition"
	for pattern in patterns:
		var error = pattern.validate()
		if not error.is_empty(): return error
	return ""
