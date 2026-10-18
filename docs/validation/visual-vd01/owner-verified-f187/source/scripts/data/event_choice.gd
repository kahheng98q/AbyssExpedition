class_name EventChoice
extends Resource

@export var id: StringName
@export var costs: Array[Dictionary] = []
@export var requirements: Array[String] = []
@export var effects: Array[Dictionary] = []
@export var terminal_choice: bool = true
@export var presentation: String

func validate() -> String:
	if id not in [&"heal", &"might", &"leave", &"blood_tithe", &"unbound_assault", &"decline", &"accept"] or not terminal_choice: return "Unknown event choice."
	for item in costs + effects:
		if not item.has("kind") or not item.has("amount") or not is_finite(float(item.amount)) or item.amount < 0: return "Invalid event amount."
	var expected_costs = {&"heal": [{"kind": "coins", "amount": 20}], &"might": [{"kind": "coins", "amount": 30}], &"blood_tithe": [{"kind": "health", "amount": 0.2}, {"kind": "corruption", "amount": 25}], &"unbound_assault": [{"kind": "corruption", "amount": 35}]}
	var expected_effects = {&"heal": [{"kind": "heal", "amount": 0.25}], &"might": [{"kind": "might", "amount": 1}], &"blood_tithe": [{"kind": "damage", "amount": 0.3}], &"unbound_assault": [{"kind": "frequency", "amount": 0.4}]}
	if costs != expected_costs.get(id, []) or effects != expected_effects.get(id, []): return "Event costs/effects must match the coast contract."
	return ""
