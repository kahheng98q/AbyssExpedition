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
	return hero

static func configure_progression(actor, member: Dictionary) -> void:
	actor.profession = actor.run.catalog.professions[StringName(member.profession)]
	actor.passive = actor.definition.passive
	actor.permanent_level = int(member.level)
	actor.stats = progression_stats(actor.definition, actor.profession, int(member.level))
	actor.starting_stats = actor.stats.duplicate(true)

static func progression_stats(definition: CharacterDefinition, profession: ProfessionDefinition, level: int) -> StatBlock:
	var stats: StatBlock = profession.starting_stats.duplicate(true)
	var factor = 1.0 + 0.02 * (clampi(level, 1, 30) - 1)
	stats.damage *= factor
	stats.max_health *= factor
	PassiveExecutor.starting({"stats": stats, "passive": definition.passive})
	return stats
