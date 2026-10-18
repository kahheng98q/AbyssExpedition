class_name TargetingService
extends RefCounted

static func nearest(origin: Vector2, reach: float, actors: Array):
	var best = null
	var distance = reach * reach
	for actor in actors:
		if not is_instance_valid(actor) or actor.health.dead: continue
		var candidate = origin.distance_squared_to(actor.position)
		if candidate > reach * reach: continue
		if best == null or candidate < distance or (is_equal_approx(candidate, distance) and actor.actor_id < best.actor_id):
			best = actor
			distance = candidate
	return best
