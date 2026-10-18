class_name UpgradeEffects
extends RefCounted

static func apply(definition: UpgradeDefinition, actor, progression: RunProgression) -> void:
	progression.stacks[definition.id] = progression.stacks.get(definition.id, 0) + 1
	for member in actor.run.party:
		if not member.health.dead: apply_to(definition, member, progression)

static func apply_to(definition: UpgradeDefinition, actor, progression: RunProgression) -> void:
	var before = actor.health.maximum
	derive(actor, progression)
	for effect in definition.effects:
		if actor.is_companion and effect.target_scope == "hero": continue
		if effect.kind == &"heal_added": actor.health.heal((actor.health.maximum - before) * effect.amount)
		if effect.kind == &"heal": actor.health.heal(actor.health.maximum * effect.amount)

static func derive(actor, progression: RunProgression) -> void:
	var baseline = actor.starting_stats
	actor.stats = baseline.duplicate(true)
	# Derive from immutable class baselines; percentages add within each category.
	for id_value in progression.stacks:
		var upgrade = actor.run.catalog.upgrades[id_value]
		var count = progression.stacks[id_value]
		for effect in upgrade.effects:
			if actor.is_companion and effect.target_scope == "hero": continue
			if effect.kind == &"percent":
				actor.stats.set(effect.stat_category, actor.stats.get(effect.stat_category) + baseline.get(effect.stat_category) * effect.amount * count)
			elif effect.kind == &"flat":
				actor.stats.set(effect.stat_category, actor.stats.get(effect.stat_category) + effect.amount * count)
	for category in actor.contract_bonuses:
		actor.stats.set(category, actor.stats.get(category) + baseline.get(category) * actor.contract_bonuses[category])
	actor.health.maximum = actor.stats.max_health
