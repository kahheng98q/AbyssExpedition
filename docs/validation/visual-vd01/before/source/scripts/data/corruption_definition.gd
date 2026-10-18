class_name CorruptionDefinition
extends Resource

@export var id: StringName = &"coast_corruption"
@export var max_value: int = 100
@export var minute_increment: int = 5
@export var thresholds: Array[Dictionary] = []

func validate() -> String:
	var expected = [
		{"value": 25, "count": 1.1, "xp": 1.1},
		{"value": 50, "brood": true, "xp": 1.2},
		{"value": 75, "damage": 1.15, "xp": 1.3},
		{"value": 100, "count": 1.2, "second_circle": true, "xp": 1.4}]
	return "" if max_value == 100 and minute_increment == 5 and thresholds == expected else "Corruption threshold totals must match the coast contract."
