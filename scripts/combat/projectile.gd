extends Node2D

var run
var direction: Vector2 = Vector2.RIGHT
var speed: float = 240.0
var damage: float = 20.0
var reach: float = 160.0
var target_id: int = -1
var expires: int = 0
var homing: bool = false
var hostile: bool = false
var burn: bool = false
var frost: bool = false
var knockback: float = 80.0
var profession: ProfessionDefinition
var hit_limit: int = 1
var hit_ids: Array[int] = []
var bounces: int = 0
var element: String = ""

func simulate(tick: int) -> void:
	if tick >= expires:
		queue_free()
		return
	if homing:
		var target = run.actor_by_id(target_id)
		if target == null or target.health.dead or position.distance_to(target.position) > reach:
			target = TargetingService.nearest(position, reach, run.enemies.filter(func(actor): return not hit_ids.has(actor.actor_id)))
		if target == null:
			queue_free()
			return
		target_id = target.actor_id
		direction = position.direction_to(target.position)
	var end = position + direction * speed / 60.0
	var candidates = run.party if hostile else run.enemies
	# Swept segment avoids tunnelling; first victim along the shot, spawn order on ties.
	var victim = null
	var best = INF
	for actor in candidates:
		if actor.health.dead or hit_ids.has(actor.actor_id): continue
		var closest = Geometry2D.get_closest_point_to_segment(actor.position, position, end)
		if closest.distance_to(actor.position) <= (24 if actor.is_boss else 9):
			var distance = position.distance_squared_to(closest)
			if distance < best or (is_equal_approx(distance, best) and victim != null and actor.actor_id < victim.actor_id):
				victim = actor
				best = distance
	var origin = position
	position = end
	if victim != null:
		run.queue_hit(victim, damage, direction, knockback, burn, frost)
		hit_ids.append(victim.actor_id)
		MageBranchAttacks.impact(self, victim, tick)
		if bounces > 0:
			bounces -= 1
			var remaining = run.enemies.filter(func(actor): return not hit_ids.has(actor.actor_id))
			var second = TargetingService.nearest(victim.position, reach, remaining)
			if second == null: queue_free()
			else:
				position = victim.position
				target_id = second.actor_id
				direction = position.direction_to(second.position)
				homing = true
				hit_limit = 2
		elif hit_ids.size() >= hit_limit: queue_free()
		elif hit_limit > 1 and not homing:
			# Pierce every intersected actor in this sweep, including at high speed.
			var intersections = []
			for actor in candidates:
				if actor.health.dead or hit_ids.has(actor.actor_id): continue
				var point = Geometry2D.get_closest_point_to_segment(actor.position, origin, end)
				if point.distance_to(actor.position) <= (24 if actor.is_boss else 9):
					intersections.append({"actor": actor, "distance": origin.distance_squared_to(point)})
			intersections.sort_custom(func(a, b): return a.distance < b.distance if not is_equal_approx(a.distance, b.distance) else a.actor.actor_id < b.actor.actor_id)
			for hit in intersections:
				if hit_ids.size() >= hit_limit: break
				run.queue_hit(hit.actor, damage, direction, knockback, burn, frost)
				hit_ids.append(hit.actor.actor_id)
			if hit_ids.size() >= hit_limit: queue_free()
	queue_redraw()

func _draw() -> void:
	var color = Color(1, 0.4, 0.3) if hostile else (Color(0.8, 0.6, 1) if homing else Color(0.83, 1, 0.6))
	if profession != null and profession.is_promotion:
		color = profession.visual_set.palette
		if element == "frost": color = Color(0.4, 0.85, 1)
	if homing:
		for i in range(4, 0, -1):
			draw_circle((-direction * i * 4).round(), 3 - i * 0.4, Color(color, 0.5 - i * 0.08))
		draw_colored_polygon(PackedVector2Array([Vector2(0, -6), Vector2(4, 0), Vector2(0, 6), Vector2(-4, 0)]), color)
		draw_line(Vector2(-2, 0), Vector2(2, 0), Color("fff6df"), 2)
	else:
		draw_line(-direction * 21, -direction * 7, Color(color, 0.22), 2)
		draw_line(-direction * 12, direction * 5, Color("09141d"), 4)
		draw_line(-direction * 7, direction * 5, color, 2)
		draw_line(direction * 5, -direction.rotated(0.6) * 2, color)
		draw_line(direction * 5, -direction.rotated(-0.6) * 2, color)
