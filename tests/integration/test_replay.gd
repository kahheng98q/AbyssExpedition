extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")
const SEEDS = [0, 1, 2, 42, 101, 202, 303, 8675309, 2147483646, 2147483647]

func capture(t, seed_value: int, cosmetics: bool, owned: bool = false) -> Dictionary:
	var payload = ProfileData.fresh()
	if owned: payload.owned.sera = OwnedHero.record("sera")
	var f = Fixture.create_party(t, payload, seed_value)
	var run = f.run
	for tick in range(0, 32400, 600):
		run.clock.tick = tick
		run.corruption.advance(tick)
		run.choices.present_rescue(run)
		if run.choices.event_token >= 0:
			var identity = run.events.current.id
			var free = &"leave" if run.events.current.kind == "mysterious_merchant" else &"decline"
			run.choices.resolve_event(run, identity, free)
		if run.rescue.state == "offered": run.choices.resolve_rescue(run, false)
		run.spawns.schedule_wave(run, tick)
		run.spawns.simulate(run, tick + 45)
		if tick % 3000 == 0:
			run.progression.collect_xp(10000 + tick, run.progression.level * 100)
			run.choices.present(run)
			var selected = run.choices.offer[floori(tick / 600.0) % 3]
			var token = run.pause.acquire("test_pause", "replay")
			for ignored in range(7 if cosmetics else 2):
				run.simulation.advance(run, Vector2.ONE)
				if cosmetics: randf()
			run.pause.release(token, "replay")
			run.choices.confirm(run, run.choices.offer_id, selected)
	var result = run.trace.snapshot()
	Fixture.dispose(f)
	return result

func run(t) -> void:
	var recorded = await capture_movement(t)
	t.check(not recorded.trace.get("inputs", []).is_empty(), "real simulation records tick-indexed movement")
	var replayed = await capture_movement(t, recorded.trace.get("inputs", []))
	t.check(recorded.trace == replayed.trace and recorded.position.is_equal_approx(replayed.position), "recorded movement replays real waves, occupancy, level/event choices and pauses")
	for owned in [false, true]:
		for seed_value in SEEDS:
			var a = capture(t, seed_value, false, owned)
			var b = capture(t, seed_value, true, owned)
			t.check(a == b and a.start.sera_owned == owned and a.start.game == "m4.0", "matching version/start/wave/position/offer/event/decision traces; pause/cosmetics isolated, seed " + str(seed_value))
			t.check(a.waves.size() == 54 and a.offers.size() == 11 and a.events.size() == 6, "full scheduled run randomness recorded")

func capture_movement(t, recorded = null) -> Dictionary:
	var f = Fixture.create(t, &"aren", 101)
	var run = f.run
	run.hero.health.invulnerable_until = 100000 # identical controlled starting condition
	var injected = false
	var pause_checked = false
	while run.clock.tick < 7400:
		if run.clock.tick == 30 and not injected:
			var gem = f.catalog.scene("xp_gem").instantiate()
			gem.position = run.hero.position
			gem.pickup_id = 1000000
			gem.value = 350
			run.pickups.add_child(gem)
			injected = true
		if not run.choices.offer.is_empty(): run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
		if run.choices.event_token >= 0:
			var free = &"leave" if run.events.current.kind == "mysterious_merchant" else &"decline"
			run.choices.resolve_event(run, run.events.current.id, free)
		var direction = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP][(run.clock.tick / 120) % 4]
		if recorded != null:
			direction = Vector2.ZERO
			for entry in recorded:
				if entry.tick > run.clock.tick: break
				direction = Vector2(entry.direction[0], entry.direction[1])
		if run.clock.tick == 120 and not pause_checked:
			var before = run.trace.snapshot()
			var token = run.pause.acquire("manual", "recorded-replay")
			for i in range(5): run.simulation.advance(run, -direction)
			t.check(run.trace.snapshot() == before, "paused input produces no movement records")
			run.pause.release(token, "recorded-replay")
			pause_checked = true
		run.simulation.advance(run, direction)
		await t.physics_frame
	var result = {"trace": run.trace.snapshot(), "position": run.hero.position}
	Fixture.dispose(f)
	await t.process_frame
	return result
