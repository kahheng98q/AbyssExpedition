class_name PassiveExecutor
extends RefCounted

static func starting(actor) -> void:
	if actor.passive != null and actor.passive.effect_kind == &"starting_speed":
		actor.stats.speed *= 1.0 + actor.passive.magnitude
	if actor.passive != null and actor.passive.effect_kind == &"starting_reach":
		actor.stats.reach *= 1.0 + actor.passive.magnitude

static func activation_damage(actor) -> float:
	if actor.passive == null: return 1.0
	actor.passive_activations += 1
	if actor.passive.effect_kind == &"fifth_damage" and actor.passive_activations % actor.passive.activation_interval == 0:
		return 1.0 + actor.passive.magnitude
	return 1.0

static func incoming(actor, tick: int = 0) -> float:
	if actor.passive != null and actor.passive.effect_kind == &"incoming_reduction": return 1.0 - actor.passive.magnitude
	if actor.passive != null and actor.passive.effect_kind == &"interval_guard" and actor.bastion_interval != tick / actor.passive.period_ticks: return 1.0 - actor.passive.magnitude
	return 1.0

static func accepted_hit(actor, tick: int) -> void:
	if actor.passive != null and actor.passive.effect_kind == &"interval_guard": actor.bastion_interval = tick / actor.passive.period_ticks

static func periodic(run, tick: int) -> void:
	for actor in run.party:
		if actor.health.dead or actor.passive == null or actor.passive.effect_kind != &"party_heal": continue
		if tick <= 0 or tick % actor.passive.period_ticks != 0 or actor.last_passive_tick == tick: continue
		actor.last_passive_tick = tick
		var target = null
		for member in run.party:
			if member.health.dead: continue
			if target == null or member.health.current / member.health.maximum < target.health.current / target.health.maximum: target = member
		if target != null: target.health.heal(target.health.maximum * actor.passive.magnitude)
