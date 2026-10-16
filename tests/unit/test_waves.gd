extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	var f = Fixture.create(t)
	var run = f.run
	var schedule = f.catalog.waves
	var expected = [4, 6, 8, 10, 12]
	var introductions = [&"saltbound_thrall", &"skittering_brinejaw", &"lantern_cantor", &"shellbound_husk", &"reef_broodmother"]
	var stream = SeedStreams.new(101)
	for i in range(5):
		var composition = schedule.composition(i * 7200, stream.stream("wave_types"))
		t.check(composition.size() == expected[i], "exact phase wave count")
		t.check(composition.has(introductions[i]), "forced introduction")
	t.check(schedule.composition(32400, stream.stream("wave_types")).is_empty(), "normal spawn stops at boss boundary")
	var total = 0
	for tick in range(0, 32400, 600): total += schedule.composition(tick, stream.stream("wave_types")).size()
	t.check(total == 408, "54 waves with exact scheduled pressure")
	run.spawns.schedule_wave(run, 0)
	t.check(run.spawns.reservations.size() == 4, "initial wave warns four slots")
	for slot in run.spawns.reservations:
		t.check(slot.due == 45 and slot.point.distance_to(run.hero.position) >= 96, "45-tick safe warning")
	run.spawns.simulate(run, 44)
	t.check(run.enemies.is_empty(), "no enemy before warning completes")
	run.hero.position = run.spawns.reservations[0].point
	run.spawns.simulate(run, 45)
	t.check(run.enemies.size() <= 3, "activation revalidates player safety")
	for record in run.trace.spawns: t.check(record.attempts <= 16, "candidate retries bounded")
	for i in range(100 - run.enemies.size()): run.spawn_enemy(&"saltbound_thrall", Vector2(100, 100))
	run.spawns.schedule_wave(run, 600)
	t.check(run.spawns.reservations.is_empty(), "cap includes reservations without backlog")
	Fixture.dispose(f)
	f = Fixture.create(t)
	run = f.run
	var mother = run.spawn_enemy(&"reef_broodmother", Vector2(100, 100))
	for i in range(5): run.spawns.summon(run, mother, 0)
	t.check(run.spawns.reservations.size() == 3, "mother reserves at most three children")
	mother.health.dead = true
	run.spawns.simulate(run, 10)
	t.check(run.spawns.reservations.is_empty(), "mother death cancels warned children")
	mother.health.dead = false
	run.spawns.summon(run, mother, 32400)
	t.check(run.spawns.reservations.is_empty(), "no broodlings at boss boundary")
	for i in range(500):
		var gem = f.catalog.scene("xp_gem").instantiate()
		gem.pickup_id = 10000 + i
		run.pickups.add_child(gem)
	run.clock.tick = 100000
	run.cleanup_effects(100000)
	var stored = 0
	for gem in run.pickups.get_children(): stored += gem.value
	t.check(run.pickups.get_child_count() == 500 and stored == 5000, "long no-pickup state preserves every XP reward without expiration")
	Fixture.dispose(f)
