class_name BossController
extends RefCounted

static func decide(actor, run, tick: int) -> Vector2:
	if actor.ai_state == "warning": return Vector2.ZERO
	if tick < actor.deadline: return Vector2.ZERO
	var pattern = actor.definition.patterns[actor.activations % actor.definition.patterns.size()]
	actor.activations += 1
	var origin = run.hero.position if pattern.geometry == "circle" else actor.position
	var facing = actor.position.direction_to(run.hero.position)
	var warning = run.create_warning(origin, pattern.geometry, pattern.radius, facing, pattern.angle, tick + pattern.windup_ticks)
	run.boss_hits.append({"warning": warning, "due": tick + pattern.windup_ticks, "damage": pattern.damage, "source": actor.actor_id})
	if pattern.geometry == "circle" and run.corruption.modifiers().second_circle:
		# Snapshot geometry now: crossing 100 cannot alter an existing warning.
		var second = (origin + Vector2(104, 0)).clamp(Vector2(40, 40), Vector2(920, 500))
		if second.distance_to(origin) < 80: second = origin - Vector2(104, 0)
		var extra = run.create_warning(second, "circle", pattern.radius, facing, pattern.angle, tick + pattern.windup_ticks)
		run.boss_hits.append({"warning": extra, "due": tick + pattern.windup_ticks, "damage": pattern.damage, "source": actor.actor_id})
	actor.ai_state = "warning"
	actor.deadline = tick + pattern.windup_ticks + pattern.recovery_ticks
	return Vector2.ZERO
