class_name BrinejawBehavior
extends RefCounted

static func decide(actor, run, tick: int) -> Vector2:
	if actor.ai_state == "warning":
		if tick >= actor.deadline:
			actor.ai_state = "rush"
			actor.deadline = tick + 30
		return Vector2.ZERO
	if actor.ai_state == "rush":
		if tick >= actor.deadline:
			actor.ai_state = "recovery"
			actor.deadline = tick + 90
		return actor.aim * 185
	if actor.ai_state == "recovery":
		if tick >= actor.deadline: actor.ai_state = "ready"
		return Vector2.ZERO
	if actor.position.distance_to(run.hero.position) < 150:
		actor.aim = actor.position.direction_to(run.hero.position)
		actor.ai_state = "warning"
		actor.deadline = tick + 45
		run.create_warning(actor.position, "cone", 105, actor.aim, 16, tick + 45)
		return Vector2.ZERO
	return actor.position.direction_to(run.hero.position) * actor.stats.speed
