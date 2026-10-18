extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	for outcome in ["victory", "defeat", "simultaneous", "abandonment"]:
		var f = Fixture.create(t)
		var run = f.run
		run.clock.tick = 32400
		run.spawns.simulate(run, 32400)
		t.check(run.spawns.boss_placed and run.spawns.reservations.size() == 1, "one safe warned boss entry")
		run.spawns.simulate(run, 32445)
		t.check(run.boss_actor != null, "boss after entrance warning")
		for pattern in f.catalog.boss.patterns: t.check(pattern.windup_ticks >= 45, "boss pattern full warning")
		var signals: Array = []
		run.run_finished.connect(func(summary): signals.append(summary))
		if outcome in ["victory", "simultaneous"]: run.queue_hit(run.boss_actor, 10000, Vector2.ZERO, 0, false, false)
		if outcome in ["defeat", "simultaneous"]: run.queue_hit(run.hero, 10000, Vector2.ZERO, 0, false, false)
		if outcome == "abandonment": run.finish("abandonment")
		else: run.simulation.advance(run, Vector2.ZERO)
		var expected = "defeat" if outcome == "simultaneous" else outcome
		t.check(run.summary.outcome == expected, "correct terminal precedence " + outcome)
		var frozen = run.clock.tick
		run.finish("victory")
		run.simulation.advance(run, Vector2.ONE)
		t.check(signals.size() == 1 and run.clock.tick == frozen, "one summary and frozen terminal time")
		t.check(run.choices.offer.is_empty() and run.spawns.reservations.is_empty(), "terminal cancels choices/spawns")
		Fixture.dispose(f)
	var f = Fixture.create(t)
	var run = f.run
	run.clock.tick = 72000
	run.simulation.advance(run, Vector2.ZERO)
	t.check(run.phase == "active", "no timed automatic outcome")
	Fixture.dispose(f)
	f = Fixture.create(t)
	run = f.run
	for point in [Vector2(480, 48), Vector2(912, 270), Vector2(480, 492), Vector2(48, 270), Vector2(48, 48), Vector2(912, 492)]:
		run.spawn_enemy(&"saltbound_thrall", point)
	run.spawns.simulate(run, 32400)
	t.check(run.spawns.boss_pending and not run.spawns.boss_placed, "crowded entrance retains one pending boss")
	run.enemies[0].position += Vector2(80, 80)
	run.spawns.simulate(run, 32401)
	t.check(run.spawns.boss_placed and run.spawns.reservations.size() == 1, "boss retries safe entrance without clearing existing enemies")
	Fixture.dispose(f)
