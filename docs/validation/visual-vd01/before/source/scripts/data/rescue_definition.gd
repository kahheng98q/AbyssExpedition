class_name RescueDefinition
extends Resource

@export var id: StringName = &"sera_rescue"
@export var character_id: StringName = &"sera"
@export var duration_ticks: int = 1800
@export var zone_radius: float = 96.0
@export var repeat_ticket_reward: int = 1

func validate() -> String:
	return "" if character_id == &"sera" and duration_ticks == 1800 and zone_radius == 96.0 and repeat_ticket_reward == 1 else "invalid Sera rescue definition"
