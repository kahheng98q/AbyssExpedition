class_name EventEffects
extends RefCounted

static func choice(run, id: StringName) -> EventChoice:
	if run.events.current.is_empty(): return null
	var definition = run.catalog.events[StringName(run.events.current.kind)]
	for option in definition.choices:
		if option.id == id: return option
	return null

static func unavailable(run, id: StringName) -> String:
	var option = choice(run, id)
	if option == null: return "Offer is no longer available."
	for cost in option.costs:
		match cost.kind:
			"coins":
				if run.coins < cost.amount: return "Need %d coins (have %d)." % [cost.amount, run.coins]
			"health":
				if run.hero.health.current - run.hero.health.maximum * cost.amount < 1: return "Must leave at least 1 HP."
			"corruption":
				if not run.corruption.can_add(int(cost.amount)): return "Need %d corruption headroom (have %d)." % [cost.amount, 100 - run.corruption.value]
	return ""

static func apply(run, id: StringName) -> bool:
	if run.phase != "active" or unavailable(run, id) != "": return false
	var option = choice(run, id)
	# Validate every cost before any deduction. The offer's coordinator consumes once.
	for cost in option.costs:
		match cost.kind:
			"coins": run.coins -= int(cost.amount)
			"health": run.hero.health.current -= run.hero.health.maximum * cost.amount
			"corruption": run.corruption.add(int(cost.amount))
	for effect in option.effects:
		match effect.kind:
			"heal": run.hero.health.heal(run.hero.health.maximum * effect.amount)
			"might": UpgradeEffects.apply(run.catalog.upgrades[&"might"], run.hero, run.progression)
			"damage", "frequency":
				for member in run.party:
					if member.health.dead: continue
					member.contract_bonuses[effect.kind] = member.contract_bonuses.get(effect.kind, 0.0) + effect.amount
					UpgradeEffects.derive(member, run.progression)
	return true
