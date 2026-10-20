extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	var f = Fixture.create(t)
	var run = f.run
	var schedule = f.catalog.waves
	var expected_segments = [["saltbound_thrall", "saltbound_thrall", "saltbound_thrall", "saltbound_thrall"], ["saltbound_thrall", "saltbound_thrall", "saltbound_thrall", "skittering_brinejaw"], ["saltbound_thrall", "saltbound_thrall", "saltbound_thrall", "lantern_cantor"], ["saltbound_thrall", "saltbound_thrall", "saltbound_thrall", "saltbound_thrall"], ["saltbound_thrall", "saltbound_thrall", "skittering_brinejaw", "lantern_cantor"]]
	var totals = {"saltbound_thrall": 0, "skittering_brinejaw": 0, "lantern_cantor": 0}
	var opening_rng = SeedStreams.new(101).stream("wave_types")
	for tick in range(0, 7200, 600):
		var segment_index = 0 if tick < 1800 else (1 if tick < 3600 else (2 if tick < 5400 else (3 if tick < 6600 else 4)))
		var planned = schedule.composition(tick, opening_rng)
		t.check(planned.map(func(id): return String(id)) == expected_segments[segment_index], "exact fixed opening slots at tick " + str(tick))
		for id in planned:
			if totals.has(String(id)): totals[String(id)] += 1
	t.check(totals == {"saltbound_thrall": 40, "skittering_brinejaw": 4, "lantern_cantor": 4}, "12 waves /48 base slots /40T4B4C")
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
	var has_opening = run.spawns.has_method("initialize_opening")
	t.check(has_opening, "opening origin initialized by RunManager before tick0")
	if has_opening:
		t.check(run.spawns.opening_origin == Vector2(480, 270), "initial center captured before movement")
		var reference = SeedStreams.new(101).stream("spawn_positions")
		for slot_index in 4:
			var angle = (slot_index % 4 + reference.randf()) * PI / 2.0
			var radius = reference.randf_range(128.0, 160.0)
			var point = Vector2(480, 270) + Vector2.from_angle(angle) * radius
			t.check(run.spawns.reservations[slot_index].point.is_equal_approx(point), "quadrant candidate uses exactly angle+radius RNG draws")
		t.check(run.rng.stream("spawn_positions").state == reference.state, "four safe opening slots consume exactly eight draws")
	for slot in run.spawns.reservations:
		t.check(slot.point.distance_to(Vector2(480, 270)) >= 128 and slot.point.distance_to(Vector2(480, 270)) <= 160, "opening radius within 128–160")
		t.check(slot.due == 45 and slot.point.distance_to(run.hero.position) >= 96, "45-tick safe warning")
	run.spawns.simulate(run, 44)
	t.check(run.enemies.is_empty(), "no enemy before warning completes")
	run.hero.position = run.spawns.reservations[0].point
	run.spawns.simulate(run, 45)
	t.check(run.enemies.size() <= 3, "activation revalidates player safety")
	for record in run.trace.spawns: t.check(record.attempts <= 16, "candidate retries bounded")
	if has_opening:
		t.check(run.trace.spawns.any(func(record): return record.result == "canceled" and record.get("reason", "") == "unsafe_at_activation"), "unsafe activation has terminal trace")
	for i in range(100 - run.enemies.size()): run.spawn_enemy(&"saltbound_thrall", Vector2(100, 100))
	run.spawns.schedule_wave(run, 600)
	t.check(run.spawns.reservations.is_empty(), "cap includes reservations without backlog")
	Fixture.dispose(f)
	# Moved tick0 position never becomes the opening center; blocked slots are lost.
	f = Fixture.create(t)
	run = f.run
	if has_opening:
		run.hero.position += Vector2(20, 0)
		run.spawns.schedule_wave(run, 0)
		for slot in run.spawns.reservations:
			t.check(slot.point.distance_to(Vector2(480, 270)) <= 160.001, "opening origin does not track tick0 movement")
		var ids = run.spawns.reservations.map(func(slot): return slot.reservation_id)
		run.finish("abandonment")
		for identity in ids:
			t.check(run.trace.spawns.filter(func(record): return record.reservation_id == identity and record.result == "canceled" and record.reason == "run_end").size() == 1, "run end terminates each warning once")
		var final_trace = run.trace.snapshot()
		run.spawns.schedule_wave(run, 600)
		t.check(run.trace.snapshot() == final_trace, "terminal generation refuses later schedule appends")
	Fixture.dispose(f)
	f = Fixture.create(t)
	run = f.run
	if has_opening:
		# A live party member covers the entire opening annulus; do not relocate.
		run.hero.position = Vector2(480, 270)
		# Actual member separation stays96: force out-of-bounds initial center instead.
		run.spawns.opening_origin = Vector2(-1000, -1000)
		run.spawns.schedule_wave(run, 0)
		t.check(run.spawns.reservations.is_empty(), "16 unsafe candidates permanently skip without edge fallback")
		t.check(run.trace.spawns.filter(func(record): return record.result == "unsafe" and record.attempts == 16).size() == 4, "all bounded unsafe attempts recorded")
		run.spawns.simulate(run, 45)
		t.check(run.enemies.is_empty(), "unsafe opening never backfills")
	Fixture.dispose(f)
	f = Fixture.create(t)
	run = f.run
	if has_opening:
		for i in 99: run.spawn_enemy(&"saltbound_thrall", Vector2(100, 100))
		run.spawns.schedule_wave(run, 0)
		t.check(run.spawns.reservations.size() == 1, "99 enemies plus one warning exhaust100 cap")
		run.spawns.simulate(run, 45)
		t.check(run.enemies.size() == 100, "last warning activates without exceeding cap")
		run.spawns.schedule_wave(run, 600)
		t.check(run.spawns.reservations.is_empty(), "100 enemies reject further wave with no backlog")
	Fixture.dispose(f)
	f = Fixture.create(t)
	run = f.run
	# Boundary opening and full-party occupancy use the same current-member safety.
	if has_opening:
		run.spawns = SpawnDirector.new()
		run.hero.position = Vector2(8, 8)
		run.spawns.initialize_opening(run.hero.position)
		run.spawns.schedule_wave(run, 0)
		t.check(run.spawns.reservations.size() > 0 and run.spawns.reservations.size() < 4, "boundary opening keeps only safe quadrants")
		for slot in run.spawns.reservations: t.check(SpawnDirector.safe(run, slot.point), "boundary candidate within walkable rectangle")
		run.spawns.terminate(run)
	Fixture.dispose(f)
	var payload = ProfileData.fresh()
	payload.companions = ["lia", "milo"]
	f = Fixture.create_party(t, payload)
	run = f.run
	if has_opening:
		run.party[1].position = Vector2(600, 300)
		run.party[2].position = Vector2(380, 360)
		run.spawns.schedule_wave(run, 0)
		for slot in run.spawns.reservations:
			for member in run.party: t.check(slot.point.distance_to(member.position) >= 96, "opening checks every living party member")
		run.spawns.terminate(run)
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
