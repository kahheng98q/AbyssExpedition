class_name ActorVisualOverride
extends Resource

@export var id: StringName
@export var selector_kind: String = ""
@export var definition_id: StringName
@export var profession_id: StringName
@export var visual_set: VisualSet
@export var entries: Array[Resource] = []

func validate() -> String:
	if not entries.is_empty():
		if entries.size()!=3:return "exactly three approved mappings required"
		var seen={}
		for entry in entries:
			if not entry is ActorVisualOverride or not entry.entries.is_empty() or not entry.validate().is_empty():return "invalid mapping"
			var key=entry.selector_kind+":"+String(entry.definition_id)+":"+String(entry.profession_id)
			if seen.has(key):return "duplicate mapping"
			seen[key]=true
		return ""
	if selector_kind=="hero":
		if definition_id!=&"aren" or profession_id!=&"swordsman":return "unapproved hero selector"
	elif selector_kind=="enemy":
		if definition_id not in [&"saltbound_thrall",&"skittering_brinejaw"] or profession_id!=&"":return "unapproved enemy selector"
	else:return "unknown selector kind"
	if visual_set==null or visual_set.sprite_frames==null:return "missing production frames"
	return visual_set.validate()

func resolve(kind: String,definition: StringName,profession: StringName) -> VisualSet:
	for entry in entries:
		if entry.selector_kind==kind and entry.definition_id==definition and entry.profession_id==profession:return entry.visual_set
	return null
