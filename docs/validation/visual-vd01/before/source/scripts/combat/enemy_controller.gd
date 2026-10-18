class_name EnemyController
extends RefCounted

static func simulate(actor, run, tick: int) -> void:
	if actor.health.dead: return
	var motion = Vector2.ZERO
	if actor.is_boss: motion = BossController.decide(actor, run, tick)
	else:
		match actor.definition.behavior_kind:
			"rush": motion = BrinejawBehavior.decide(actor, run, tick)
			"ranged": motion = CantorBehavior.decide(actor, run, tick)
			"summoner": motion = BroodmotherBehavior.decide(actor, run, tick)
			_: motion = HuskBehavior.decide(actor, run)
	actor.velocity = motion * actor.statuses.speed_multiplier(tick, actor.resistant) + actor.knockback
	actor.move_and_slide()
	actor.position = actor.position.clamp(Vector2(12, 12), Vector2(948, 528))
	actor.knockback = actor.knockback.move_toward(Vector2.ZERO, 9)
	actor.statuses.simulate(actor, run, tick)
	for member in run.party:
		if not member.health.dead and actor.position.distance_to(member.position) < (30 if actor.is_boss else 17):
			run.queue_hit(member, actor.stats.damage, actor.position.direction_to(member.position), 40, false, false)
