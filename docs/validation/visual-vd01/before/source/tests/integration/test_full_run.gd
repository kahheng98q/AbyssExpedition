extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func direction(run) -> Vector2:
	var origin = run.hero.position
	if run.boss_actor != null and not run.boss_actor.health.dead:
		var to_boss = origin.direction_to(run.boss_actor.position)
		var distance_to_boss = origin.distance_to(run.boss_actor.position)
		var ideal = 42.0 if run.hero.definition.base_profession.weapon.mode == "arc" else 100.0
		var command = to_boss if distance_to_boss > ideal + 5 else to_boss.orthogonal() * 0.7 + to_boss * clampf((distance_to_boss - ideal) / 8.0, -1, 1)
		for hit in run.boss_hits:
			var warning = hit.warning
			if warning.geometry == "circle" and origin.distance_to(warning.position) < warning.radius + 20:
				var escape = warning.position.direction_to(origin)
				if escape.is_zero_approx(): escape = to_boss.orthogonal()
				command = escape
			elif warning.geometry == "cone" and warning.contains(origin + command * 8):
				command = warning.direction.orthogonal()
		return command.limit_length(1)
	var desired = Vector2(480, 270)
	var nearest_gem = null
	var gem_distance = INF
	for gem in run.pickups.get_children():
		if gem.collected: continue
		var distance = origin.distance_squared_to(gem.position)
		if distance < gem_distance:
			gem_distance = distance
			nearest_gem = gem
	if nearest_gem != null: desired = nearest_gem.position
	var movement = origin.direction_to(desired)
	var closest = TargetingService.nearest(origin, 1000, run.enemies)
	if closest != null:
		var delta = closest.position - origin
		var distance = delta.length()
		var preferred = 38.0 if run.hero.definition.base_profession.weapon.mode == "arc" else 85.0
		if nearest_gem == null: movement = delta.normalized() * clampf((distance - preferred) / 25.0, -1, 1) + delta.normalized().orthogonal() * 0.5
		for actor in run.enemies:
			var offset = origin - actor.position
			var spacing = 43.0 if actor.is_boss else 35.0
			if offset.length() < spacing:
				movement += offset.normalized() * (spacing - offset.length()) / 5.0
	for warning in run.telegraphs.get_children():
		var endangered = origin.distance_to(warning.position) < warning.radius + 25 if warning.geometry == "circle" else load("res://scripts/combat/melee_arc.gd").contains(warning.position, warning.direction, warning.radius + 20, warning.angle + 30, origin)
		if warning.expires > run.clock.tick and endangered:
			if warning.geometry == "circle":
				var escape = warning.position.direction_to(origin)
				if escape.is_zero_approx(): escape = Vector2.RIGHT
				movement += escape * 4
			else:
				var dodge = warning.direction.orthogonal()
				if (origin + dodge * 50).distance_squared_to(Vector2(480, 270)) > (origin - dodge * 50).distance_squared_to(Vector2(480, 270)): dodge = -dodge
				movement += dodge * 4
	if origin.x < 32: movement.x += 2
	if origin.x > 928: movement.x -= 2
	if origin.y < 32: movement.y += 2
	if origin.y > 508: movement.y -= 2
	return movement.limit_length(1)

func choose_event(run) -> void:
	if run.choices.event_token < 0: return
	var kind = run.events.current.kind
	var order = [&"unbound_assault", &"blood_tithe", &"decline"] if kind == "forbidden_altar" else [&"might", &"heal", &"leave"]
	if kind == "mysterious_merchant" and run.hero.health.current < run.hero.health.maximum * 0.6: order = [&"heal", &"might", &"leave"]
	for id in order:
		if EventEffects.unavailable(run, id) == "":
			run.choices.resolve_event(run, run.events.current.id, id)
			return

func choose(run) -> void:
	var order = [&"ironhide", &"echo_strike", &"quick_hands", &"might", &"reach", &"ember_touch", &"frost_mark", &"vitality", &"force", &"swift_boots", &"magnet", &"battle_mend"]
	if run.hero.health.current / run.hero.health.maximum < 0.85:
		order.push_front(&"ironhide")
		order.push_front(&"vitality")
		order.push_front(&"battle_mend")
	for id_value in order:
		if run.choices.offer.has(id_value):
			run.choices.confirm(run, run.choices.offer_id, id_value)
			return

func run(t) -> void:
	for hero_id in [&"aren", &"lia", &"milo"]:
		var f = Fixture.create(t, hero_id, 101)
		var expedition = f.run
		var steps = 0
		await t.physics_frame
		while expedition.phase == "active" and steps < 45000:
			choose_event(expedition)
			if expedition.rescue.state == "offered": expedition.choices.resolve_rescue(expedition, false)
			if not expedition.choices.offer.is_empty(): choose(expedition)
			expedition.simulation.advance(expedition, direction(expedition))
			steps += 1
			if expedition.boss_actor != null and steps % 600 == 0:
				print("AUTOPLAY boss approach %s: tick=%d position=%s boss=%s distance=%.1f reach=%.1f HP=%.1f boss_HP=%.1f" % [hero_id, expedition.clock.tick, expedition.hero.position, expedition.boss_actor.position, expedition.hero.position.distance_to(expedition.boss_actor.position), expedition.hero.stats.reach, expedition.hero.health.current, expedition.boss_actor.health.current])
			await t.physics_frame
		print("AUTOPLAY %s: phase=%s outcome=%s ticks=%d kills=%d level=%d HP=%.1f boss_HP=%.1f" % [hero_id, expedition.phase, expedition.summary.get("outcome", "none"), expedition.clock.tick, expedition.kills, expedition.progression.level, expedition.hero.health.current, expedition.boss_actor.health.current if expedition.boss_actor != null else -1.0])
		t.check(expedition.phase == "results", "full run reaches an actual ending: " + hero_id)
		t.check(expedition.summary.get("outcome", "none") == "victory", "starter independently defeats boss: " + hero_id)
		t.check(expedition.clock.tick >= 32400 and expedition.clock.tick <= 39600, "automated victory within 9–11 active minutes")
		Fixture.dispose(f)
		await t.process_frame
