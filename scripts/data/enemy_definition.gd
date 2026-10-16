class_name EnemyDefinition
extends Resource

@export var id: StringName
@export var behavior_kind: String
@export var stats: StatBlock
@export var weapon: WeaponDefinition
@export var resistances: Array[StringName] = []
@export var damage_reduction: float = 1.0
@export var xp_drop: int = 10
@export var visual_set: VisualSet
@export var summon_definition: StringName
@export var summon_interval: int = 360
@export var max_living_children: int = 3

func validate() -> String:
	if stats == null or visual_set == null: return "missing enemy dependency"
	if behavior_kind not in ["pursuit", "rush", "ranged", "armored", "summoner", "broodling"]: return "unknown behavior"
	if xp_drop != 10 or max_living_children < 0 or max_living_children > 3 or summon_interval <= 0: return "invalid reward/summon constraints"
	if not is_finite(damage_reduction) or damage_reduction <= 0 or damage_reduction > 1: return "invalid resistance"
	return ""
