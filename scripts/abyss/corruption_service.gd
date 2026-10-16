class_name CorruptionService
extends RefCounted

var value: int = 0
var last_minute: int = 0
var definition: CorruptionDefinition = load("res://data/encounters/coast_corruption.tres")
signal changed

func advance(tick: int) -> void:
	var minute = tick / 3600
	if minute <= last_minute: return
	value = mini(definition.max_value, value + (minute - last_minute) * definition.minute_increment)
	last_minute = minute
	changed.emit()

func can_add(amount: int) -> bool:
	return amount >= 0 and value + amount <= definition.max_value

func add(amount: int) -> bool:
	if not can_add(amount): return false
	value += amount
	changed.emit()
	return true

func modifiers() -> Dictionary:
	var result = {"count": 1.0, "damage": 1.0, "xp": 1.0, "brood": false, "second_circle": false}
	for threshold in definition.thresholds:
		if value >= threshold.value:
			for key in threshold:
				if key != "value": result[key] = threshold[key]
	return result
