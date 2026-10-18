class_name SkillDefinition
extends Resource

@export var id: StringName
@export var trigger_kind: String = "on_hit"
@export var activation_interval: int = 1
@export var period_ticks: int = 60
@export var effect_kind: StringName
@export var magnitude: float = 0.0
@export var duration_ticks: int = 0
@export var radius: float = 0.0
@export var target_policy: String = "target"
@export var required_capabilities: Array[StringName] = []

func validate() -> String:
	if effect_kind not in [&"incoming_reduction", &"starting_speed", &"fifth_damage", &"party_heal", &"interval_guard", &"starting_reach"]: return "unknown passive capability"
	if activation_interval <= 0 or period_ticks <= 0 or duration_ticks < 0: return "invalid trigger period/count"
	if not is_finite(magnitude) or not is_finite(radius) or radius < 0: return "invalid skill numeric field"
	if magnitude <= 0 or magnitude >= 1: return "invalid passive magnitude"
	return ""
