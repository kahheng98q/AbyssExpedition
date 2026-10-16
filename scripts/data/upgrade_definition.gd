class_name UpgradeDefinition
extends Resource

@export var id: StringName
@export var label: String
@export var description: String
@export var effects: Array[EffectDefinition] = []
@export var required_capabilities: Array[StringName] = []
@export var max_stacks: int = 0
@export var fallback: bool = false

func validate() -> String:
	if max_stacks < 0 or effects.is_empty(): return "invalid upgrade cap/effects"
	var seen = {}
	for capability in required_capabilities:
		if capability not in [&"melee", &"projectile", &"homing"] or seen.has(capability): return "unknown/duplicate required capability"
		seen[capability] = true
	for effect in effects:
		if effect == null: return "missing upgrade effect"
		var error = effect.validate()
		if not error.is_empty(): return error
	return ""

func effect_preview() -> String:
	var parts: PackedStringArray = []
	for effect in effects:
		var percent = str(roundi(effect.amount * 100)) + "%"
		match effect.kind:
			&"percent": parts.append("+%s starting %s" % [percent, String(effect.stat_category).replace("_", " ")])
			&"flat": parts.append("+%s %s" % [effect.amount, effect.stat_category])
			&"heal": parts.append("Heal %s maximum HP" % percent)
			&"heal_added": parts.append("Heal %s of added maximum HP" % percent)
			&"echo": parts.append("+%d shot / %d%% follow-up arc" % [effect.amount, roundi(effect.secondary_scale * 100)])
			&"burn": parts.append("Burn %s over %.1fs; refresh" % [percent, effect.duration_ticks / 60.0])
			&"frost": parts.append("Slow %s for %.1fs; refresh" % [percent, effect.duration_ticks / 60.0])
	return ". ".join(parts)
