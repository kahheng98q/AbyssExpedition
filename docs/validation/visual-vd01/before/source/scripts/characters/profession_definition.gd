class_name ProfessionDefinition
extends Resource

@export var id: StringName
@export var base_id: StringName
@export var is_promotion: bool = false
@export var starting_stats: StatBlock
@export var weapon: WeaponDefinition
@export var automatic_skills: Array[Resource] = []
@export var visual_set: VisualSet
@export var promotion_ids: Array[StringName] = []
@export var attack_policy: StringName = &"base"
@export var description: String = ""
@export var fifth_interval: int = 5
@export var secondary_damage: float = 1.0
@export var effect_radius: float = 48.0
@export var fifth_radius: float = 48.0
@export var effect_ticks: int = 120
@export var effect_period: int = 30
@export var heal_fraction: float = 0.02
@export var volley_angle: float = 15.0
@export var pierce_limit: int = 3
@export var pull_speed: float = 30.0

func validate() -> String:
	if is_promotion:
		if ProfileData.BRANCHES.get(String(id)) != String(base_id) or attack_policy != id or not promotion_ids.is_empty(): return "invalid promotion ownership/policy"
	elif id != base_id or attack_policy != &"base": return "base class mismatch"
	if starting_stats == null or weapon == null or visual_set == null: return "missing profession dependency"
	if fifth_interval != 5 or pierce_limit != 3 or effect_ticks <= 0 or effect_period <= 0: return "invalid branch interval/count"
	for value in [secondary_damage, effect_radius, fifth_radius, heal_fraction, volley_angle, pull_speed]:
		if not is_finite(value) or value <= 0: return "invalid branch numeric field"
	return ""
