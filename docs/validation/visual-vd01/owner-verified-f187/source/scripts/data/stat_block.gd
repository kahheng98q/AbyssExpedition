class_name StatBlock
extends Resource

@export var max_health: float = 100.0
@export var damage: float = 20.0
@export var frequency: float = 1.0
@export var speed: float = 96.0
@export var reach: float = 48.0
@export var defense: float = 0.0
@export var knockback: float = 80.0
@export var pickup_radius: float = 24.0

func validate() -> String:
	for value in [max_health, damage, frequency, speed, reach, pickup_radius]:
		if not is_finite(value) or value <= 0: return "positive finite stat required"
	for value in [defense, knockback]:
		if not is_finite(value) or value < 0: return "negative/nonfinite defense or knockback"
	return ""
