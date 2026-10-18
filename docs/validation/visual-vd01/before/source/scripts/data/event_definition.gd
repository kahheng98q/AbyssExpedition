class_name EventDefinition
extends Resource

@export var id: StringName
@export var kind: StringName
@export var choices: Array[EventChoice] = []
@export var rescue_definition: RescueDefinition
@export var presentation: String

func validate() -> String:
	var expected = {&"mysterious_merchant": [&"heal", &"might", &"leave"], &"forbidden_altar": [&"blood_tithe", &"unbound_assault", &"decline"], &"lost_adventurer": [&"accept", &"decline"]}
	if not expected.has(id) or kind != id: return "M4: merchant/altar/lost adventurer only."
	var ids = []
	for choice in choices:
		if choice == null: return "Missing choice."
		ids.append(choice.id)
	if ids != expected[id]: return "Event choice catalog mismatch."
	if id == &"lost_adventurer" and rescue_definition == null: return "Rescue must delegate to the existing objective."
	return ""
