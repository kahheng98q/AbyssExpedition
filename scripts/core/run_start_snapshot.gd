class_name RunStartSnapshot
extends RefCounted

var _seed: int
var _hero: StringName
var seed_value: int:
	get: return _seed
var hero_id: StringName:
	get: return _hero
var game_version: String = ProfileData.GAME
var _members: Array = []
var _sera_owned: bool = false
var sera_owned: bool:
	get: return _sera_owned
var members: Array:
	get: return _members.duplicate(true)
var engine_version: String = Engine.get_version_info().string

func _init(value: int = 0, hero: StringName = &"aren", party: Array = [], owns_sera: bool = false) -> void:
	assert(value >= 0 and value <= 2147483647)
	_seed = value
	_hero = hero
	_members = []
	for member in party:
		_members.append({"id": member.id, "level": 1, "profession": ProfileData.BASES[member.id], "passive": ProfileData.PASSIVES[member.id]})
	_sera_owned = owns_sera
	if not party.is_empty(): game_version = ProfileData.GAME
