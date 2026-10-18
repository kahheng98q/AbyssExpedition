class_name BossPattern
extends Resource

@export var id: StringName
@export_enum("cone", "circle") var geometry: String = "cone"
@export var damage: float = 24.0
@export var windup_ticks: int = 60
@export var recovery_ticks: int = 150
@export var radius: float = 90.0
@export var angle: float = 70.0
@export var direction_lock: bool = true

func validate() -> String:
	if geometry not in ["cone", "circle"]: return "unknown boss geometry"
	if windup_ticks < 45 or recovery_ticks < 0: return "invalid boss warning/recovery"
	for v in [damage, radius, angle]:
		if not is_finite(v) or v <= 0: return "invalid boss geometry"
	return ""
