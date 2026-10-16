class_name CantorBehavior
extends RefCounted

static func decide(actor, run, tick: int) -> Vector2:
	if actor.ai_state == "warning":
		if tick >= actor.deadline:
			run.hostile_shot(actor.position, actor.aim, actor.stats.damage, tick)
			actor.ai_state = "ready"
			actor.deadline = tick + 180
		return Vector2.ZERO
	var distance = actor.position.distance_to(run.hero.position)
	if tick >= actor.deadline and distance < 200:
		actor.aim = actor.position.direction_to(run.hero.position)
		actor.ai_state = "warning"
		actor.deadline = tick + 45
		run.create_warning(actor.position, "cone", 180, actor.aim, 8, tick + 45)
		return Vector2.ZERO
	return actor.position.direction_to(run.hero.position) * actor.stats.speed * (1 if distance > 140 else (-1 if distance < 100 else 0))
