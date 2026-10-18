class_name BroodmotherBehavior
extends RefCounted

static func decide(actor, run, tick: int) -> Vector2:
	if tick >= actor.deadline and tick < 32400:
		run.spawns.summon(run, actor, tick)
		actor.deadline = tick + actor.definition.summon_interval
		actor.attack_until = tick + 45
	if tick < actor.attack_until: return Vector2.ZERO
	return actor.position.direction_to(run.hero.position) * actor.stats.speed
