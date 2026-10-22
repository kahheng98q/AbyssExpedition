class_name CharacterFactory
extends RefCounted

static func create(definition: CharacterDefinition, run, member_index: int = 0, member_override: Dictionary = {}):
	var hero = load("res://scenes/actors/hero.tscn").instantiate()
	hero.name = "Player" if member_index == 0 else "Companion%d" % member_index
	hero.setup(definition, -member_index, run, true)
	hero.is_companion = member_index > 0
	hero.companion_slot = member_index - 1
	if not member_override.is_empty() or not run.snapshot.members.is_empty():
		var member = member_override if not member_override.is_empty() else run.snapshot.members[member_index]
		configure_progression(hero, member)
		hero.health = ActorHealth.new(hero.stats.max_health)
	hero.position = Vector2(480, 270) if member_index == 0 else CompanionController.formation(Vector2(480, 270), member_index - 1)
	if hero.passive == null:
		configure_progression(hero, {"profession": String(definition.base_profession.id), "level": 1})
		hero.health = ActorHealth.new(hero.stats.max_health)
	return hero

static func configure_progression(actor, member: Dictionary) -> void:
	actor.profession = actor.run.catalog.professions[StringName(member.profession)]
	actor.passive = actor.definition.passive
	actor.stats = progression_stats(actor.definition, actor.profession, 1)
	actor.starting_stats = actor.stats.duplicate(true)

static func progression_stats(definition: CharacterDefinition, profession: ProfessionDefinition, _level: int = 1) -> StatBlock:
	var stats: StatBlock = profession.starting_stats.duplicate(true)
	PassiveExecutor.starting({"stats": stats, "passive": definition.passive})
	return stats

static func apply_run_profession(actor, profession_id: String) -> void:
	var ratio = actor.health.current / actor.health.maximum
	configure_progression(actor, {"profession": profession_id, "level": 1})
	UpgradeEffects.derive(actor, actor.run.progression)
	actor.health.current = 0.0 if actor.health.dead else clampf(ratio * actor.health.maximum, 0.0, actor.health.maximum)
	actor.queue_redraw()
