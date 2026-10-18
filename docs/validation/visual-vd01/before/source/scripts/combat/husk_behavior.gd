class_name HuskBehavior
extends RefCounted

static func decide(actor, run) -> Vector2:
	return actor.position.direction_to(run.hero.position) * actor.stats.speed
