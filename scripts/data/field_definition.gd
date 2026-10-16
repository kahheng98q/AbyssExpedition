class_name FieldDefinition
extends Resource

@export var id: StringName = &"coast_field"
@export var bounds: Rect2 = Rect2(0, 0, 960, 540)
@export var hero_footprint: float = 16.0
@export var spawn_warning_ticks: int = 45
@export var separation: float = 96.0
@export var collision_scene: PackedScene

func validate() -> String:
	if not is_finite(hero_footprint) or hero_footprint != 16 or not is_finite(separation): return "invalid field footprint/separation"
	if bounds != Rect2(0, 0, 960, 540) or spawn_warning_ticks < 45 or separation < 96: return "invalid M1 field"
	return ""
