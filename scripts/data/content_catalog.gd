class_name ContentCatalog
extends Node

const CHARACTERS = ["aren", "lia", "milo", "sera", "brann", "nyra"]
const PROFESSIONS = ["swordsman", "archer", "mage", "swordmaster", "abyss_swordsman", "sharpshooter", "star_hunter", "elemental_sage", "void_caster"]
const SKILLS = ["resolute", "fleet_step", "arcane_pulse", "guiding_light", "bastion", "far_sight"]
const WEAPONS = ["arc", "straight", "homing"]
const ENEMIES = ["saltbound_thrall", "skittering_brinejaw", "lantern_cantor", "shellbound_husk", "reef_broodmother", "broodling"]
const UPGRADES = ["might", "quick_hands", "reach", "echo_strike", "ironhide", "vitality", "swift_boots", "magnet", "force", "ember_touch", "frost_mark", "battle_mend"]
const SCENES = {
	"event_choice": "res://scenes/ui/event_choice.tscn",
	"corruption_summary": "res://scenes/ui/corruption_summary.tscn",
	"guild": "res://scenes/ui/guild.tscn", "recruitment": "res://scenes/ui/recruitment.tscn", "rescue_prompt": "res://scenes/ui/rescue_prompt.tscn", "rescue_zone": "res://scenes/events/rescue_zone.tscn",
	"app": "res://scenes/app/app.tscn", "expedition": "res://scenes/world/expedition.tscn", "coast_field": "res://scenes/world/coast_field.tscn",
	"hero": "res://scenes/actors/hero.tscn", "enemy": "res://scenes/actors/enemy.tscn", "boss": "res://scenes/actors/boss.tscn",
	"projectile": "res://scenes/combat/projectile.tscn", "melee_arc": "res://scenes/combat/melee_arc.tscn", "telegraph": "res://scenes/combat/telegraph.tscn", "xp_gem": "res://scenes/pickups/xp_gem.tscn",
	"main_menu": "res://scenes/ui/main_menu.tscn", "character_selection": "res://scenes/ui/character_selection.tscn", "combat_hud": "res://scenes/ui/combat_hud.tscn", "level_up": "res://scenes/ui/level_up.tscn", "pause_menu": "res://scenes/ui/pause_menu.tscn", "run_results": "res://scenes/ui/run_results.tscn",
	"save_error": "res://scenes/ui/save_error.tscn", "damage_zone": "res://scenes/combat/damage_zone.tscn", "pull_zone": "res://scenes/combat/pull_zone.tscn", "roster": "res://scenes/ui/roster.tscn", "promotion": "res://scenes/ui/promotion.tscn"
}
var characters: Dictionary = {}
var professions: Dictionary = {}
var skills: Dictionary = {}
var weapons: Dictionary = {}
var enemies: Dictionary = {}
var upgrades: Dictionary = {}
var combat_audio: CombatAudioDefinition
var waves: WaveSchedule
var field: FieldDefinition
var boss: BossDefinition
var pool: GachaPoolDefinition
var rescue: RescueDefinition
var corruption: CorruptionDefinition
var events: Dictionary = {}
var errors: Array[String] = []
var resources: Array[Resource] = []
var packed: Dictionary = {}
var digest: String = ""

func load_all() -> bool:
	errors.clear()
	resources.clear()
	packed.clear()
	for group in [[CHARACTERS, "characters", characters, CharacterDefinition], [PROFESSIONS, "professions", professions, ProfessionDefinition], [SKILLS, "skills", skills, SkillDefinition], [WEAPONS, "weapons", weapons, WeaponDefinition], [ENEMIES, "enemies", enemies, EnemyDefinition], [UPGRADES, "upgrades", upgrades, UpgradeDefinition]]:
		group[2].clear()
		for id_value in group[0]:
			var path = "res://data/%s/%s.tres" % [group[1], id_value]
			var resource = definition(path, group[3])
			if resource == null:
				errors.append(path + ": missing content")
				continue
			if resource is CharacterDefinition and resource.base_profession != null:
				resource.visual_set = resource.base_profession.visual_set
			if String(resource.id) != id_value: errors.append(path + ": ID mismatch")
			group[2][StringName(id_value)] = resource
			resources.append(resource)
	combat_audio = definition("res://data/audio/combat_audio.tres", CombatAudioDefinition)
	resources.append(combat_audio)
	waves = definition("res://data/encounters/coast_waves.tres", WaveSchedule)
	field = definition("res://data/encounters/coast_field.tres", FieldDefinition)
	boss = definition("res://data/encounters/tidebound_hierophant.tres", BossDefinition)
	pool = definition("res://data/gacha/guild_pool.tres", GachaPoolDefinition)
	rescue = definition("res://data/events/sera_rescue.tres", RescueDefinition)
	corruption = definition("res://data/encounters/coast_corruption.tres", CorruptionDefinition)
	resources.append_array([waves, field, boss, pool, rescue, corruption])
	events.clear()
	for id in ["mysterious_merchant", "forbidden_altar", "lost_adventurer"]:
		var event = definition("res://data/events/%s.tres" % id, EventDefinition)
		events[StringName(id)] = event
		resources.append(event)
	var visited: Dictionary = {}
	for resource in resources: validate_resource(resource, visited)
	if not errors.is_empty(): return false
	for key in SCENES:
		var scene_resource = load(SCENES[key])
		if not scene_resource is PackedScene: errors.append(SCENES[key] + ": missing PackedScene")
		else: packed[key] = scene_resource
	if waves != null:
		for phase in waves.phases:
			for id_value in phase.ids:
				if not enemies.has(StringName(id_value)): errors.append("coast_waves: unknown enemy " + id_value)
		for segment in waves.opening_segments:
			for id_value in segment.slots:
				if not enemies.has(StringName(id_value)): errors.append("coast_waves opening: unknown enemy " + String(id_value))
	for enemy in enemies.values():
		if enemy.behavior_kind == "summoner" and not enemies.has(enemy.summon_definition): errors.append("unknown summon ID")
	for id in [&"swordsman", &"archer", &"mage"]:
		var base = professions.get(id)
		if base == null or base.promotion_ids.size() != 2:
			errors.append("M2 requires exactly two promotion branches per base")
			continue
		var seen = {}
		for branch in base.promotion_ids:
			if seen.has(branch) or not professions.has(branch) or not professions[branch].is_promotion or professions[branch].base_id != id:
				errors.append("invalid branch reference/cycle: " + String(branch))
			seen[branch] = true
	for id in characters:
		if characters[id].passive == null or String(characters[id].passive.id) != ProfileData.PASSIVES[String(id)]: errors.append("incorrect character passive: " + String(id))
		var route = "starter" if String(id) in ProfileData.STARTERS else ("story" if id == &"sera" else "draw-exchange")
		if characters[id].acquisition_route != route or String(characters[id].base_profession.id) != ProfileData.BASES[String(id)]: errors.append("incorrect acquisition/base: " + String(id))
	var paths: Array[String] = []
	for resource in resources:
		if resource != null: paths.append(resource.resource_path)
	paths.sort()
	var bytes = PackedByteArray()
	for path in paths: bytes.append_array(FileAccess.get_file_as_bytes(path))
	digest = bytes.hex_encode().sha256_text()
	return errors.is_empty()

func definition(path: String, expected_type) -> Resource:
	var value = load(path)
	if value == null or not is_instance_of(value, expected_type):
		errors.append(path + ": missing or wrong registered Resource type")
		return null
	return value

func validate_resource(resource: Resource, visited: Dictionary) -> void:
	if resource == null:
		errors.append("null Resource")
		return
	if visited.has(resource.get_instance_id()): return
	visited[resource.get_instance_id()] = true
	var has_id = resource.get_property_list().any(func(property): return property.name == "id")
	var identity = String(resource.get("id")) if has_id else resource.get_class()
	if has_id:
		var pattern = RegEx.new()
		pattern.compile("^[a-z][a-z0-9_]*$")
		if pattern.search(identity) == null: errors.append("%s [%s]: invalid lowercase ID" % [resource.resource_path, identity])
		var ids = visited.get("definition_ids", {})
		# Choice IDs (for example Decline) are local to their event catalog.
		var scope = resource.resource_path.get_slice("::", 0) if resource is EventChoice else ""
		var key = resource.get_script().resource_path + ":" + scope + ":" + identity
		if ids.has(key): errors.append("%s [%s]: duplicate definition ID" % [resource.resource_path, identity])
		ids[key] = true
		visited["definition_ids"] = ids
	if resource.has_method("validate"):
		var error = resource.validate()
		if not error.is_empty(): errors.append("%s [%s]: %s" % [resource.resource_path, identity, error])
	for property in resource.get_property_list():
		if property.usage & PROPERTY_USAGE_STORAGE == 0 or property.name == "script": continue
		var value = resource.get(property.name)
		if value is Resource and not value is PackedScene and not value is Texture2D: validate_resource(value, visited)
		elif value is Array:
			for item in value:
				if item is Resource: validate_resource(item, visited)

func scene(id_value: String) -> PackedScene:
	return packed[id_value]
