class_name CharacterDefinition
extends Resource

@export var id: StringName
@export var display_name: String
@export var base_profession: ProfessionDefinition
@export var portrait: Texture2D
@export var visual_set: VisualSet
@export var passive: SkillDefinition
@export var acquisition_route: String = "starter"
@export var description: String

func validate() -> String:
	if base_profession == null or visual_set == null: return "missing character dependencies"
	if acquisition_route not in ["starter", "story", "draw-exchange"] or passive == null: return "invalid acquisition route/passive"
	return ""
