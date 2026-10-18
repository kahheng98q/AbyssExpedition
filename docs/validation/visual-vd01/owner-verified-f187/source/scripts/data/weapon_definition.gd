class_name WeaponDefinition
extends Resource

@export var id: StringName
@export_enum("arc", "straight", "homing") var mode: String = "arc"
@export var damage_scale: float = 1.0
@export var reach: float = 48.0
@export var frequency: float = 1.0
@export var arc_angle: float = 100.0
@export var projectile_scene: PackedScene
@export var speed: float = 240.0
@export var lifetime_ticks: int = 180
@export var pierce_limit: int = 1
@export var ricochet_limit: int = 0
@export var effects: Array[Resource] = []
@export var telegraph_ticks: int = 0

func validate() -> String:
	if mode not in ["arc", "straight", "homing"]: return "unknown weapon mode"
	for v in [reach, frequency, damage_scale, speed, arc_angle]:
		if not is_finite(v) or v <= 0: return "invalid weapon numeric field"
	if lifetime_ticks <= 0 or pierce_limit < 1 or telegraph_ticks < 0: return "invalid weapon timing/count"
	if ricochet_limit < 0 or ricochet_limit > 1 or arc_angle > 360: return "invalid ricochet count/arc angle"
	for effect in effects:
		if not effect is EffectDefinition: return "unregistered weapon effect type"
	if mode != "arc" and projectile_scene == null: return "missing projectile scene"
	return ""
