class_name CompanionController
extends RefCounted

static func formation(hero_position: Vector2, slot: int) -> Vector2:
	# Reflect the formation into the field, rather than collapsing slots at a wall.
	var x = 24 if hero_position.x < 32 else -24
	var y = -16 if slot == 0 else 16
	if hero_position.y < 24: y = 0 if slot == 0 else 16
	elif hero_position.y > 516: y = -16 if slot == 0 else 0
	return hero_position + Vector2(x, y)

static func safe_position(actor, run, point: Vector2) -> bool:
	if point.x < 8 or point.y < 8 or point.x > 952 or point.y > 532: return false
	for enemy in run.enemies:
		if not enemy.health.dead and point.distance_to(enemy.position) < (40 if enemy.is_boss else 25): return false
	var shape = CircleShape2D.new()
	shape.radius = 8
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, point)
	query.collision_mask = 1
	return actor.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

static func relocate(actor, run) -> bool:
	var desired = formation(run.hero.position, actor.companion_slot)
	for point in [desired, formation(run.hero.position, 1 - actor.companion_slot), run.hero.position + Vector2(24, -16), run.hero.position + Vector2(24, 16), run.hero.position + Vector2(0, -32), run.hero.position + Vector2(0, 32)]:
		if not safe_position(actor, run, point): continue
		var overlaps = false
		for member in run.party:
			if member != actor and not member.health.dead and point.distance_to(member.position) < 16: overlaps = true
		if overlaps: continue
		actor.position = point
		actor.blocked_ticks = 0
		return true
	return false

static func simulate(actor, run) -> void:
	if OS.has_feature("debug") and not actor.debug_ai_enabled: return
	if actor.health.dead: return
	if actor.position.distance_to(run.hero.position) > 128 or actor.blocked_ticks >= 120:
		if not relocate(actor, run): return
	var desired = formation(run.hero.position, actor.companion_slot)
	var before = actor.position
	var distance = actor.position.distance_to(desired)
	var speed = maxf(actor.stats.speed, run.hero.stats.speed)
	actor.velocity = actor.position.direction_to(desired) * minf(speed, distance * 60.0) + actor.knockback
	actor.move_and_slide()
	actor.position = actor.position.clamp(Vector2(8, 8), Vector2(952, 532))
	actor.knockback = actor.knockback.move_toward(Vector2.ZERO, 9)
	if distance > 4 and actor.position.distance_to(before) < 0.1: actor.blocked_ticks += 1
	else: actor.blocked_ticks = 0
