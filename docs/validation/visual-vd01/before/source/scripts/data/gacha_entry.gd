class_name GachaEntry
extends Resource

@export var character_id: StringName
@export var integer_weight: int = 1

func probability(total: int) -> float:
	return float(integer_weight) / total

func validate() -> String:
	return "" if character_id in [&"brann", &"nyra"] and integer_weight == 1 else "pool entry must be Brann/Nyra with weight 1"
