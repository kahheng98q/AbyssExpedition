class_name VisualSet
extends Resource

@export var id: StringName
@export var silhouette: String = "diamond"
@export var palette: Color = Color.WHITE
@export var idle: String = "procedural_idle"
@export var move: String = "procedural_move"
@export var attack: String = "procedural_attack"
@export var hurt: String = "procedural_hurt"
@export var death: String = "procedural_death"
@export var directional_flip: bool = true
@export var sword_identity: StringName = &""

func validate() -> String:
	if sword_identity not in [&"", &"single", &"dual", &"long"]: return "unregistered sword identity"
	for component in [palette.r, palette.g, palette.b, palette.a]:
		if not is_finite(component): return "nonfinite palette component"
	if silhouette not in ["diamond", "sword", "bow", "star", "crab", "lantern", "shell", "tentacles", "triangle", "crown"]: return "unregistered silhouette"
	for state in [idle, move, attack, hurt, death]:
		if state.is_empty(): return "missing visual state"
	return ""
