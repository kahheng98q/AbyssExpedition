extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	check_pacing_boundaries(t)
	var coordinator = PauseCoordinator.new()
	t.check(coordinator.has_signal("changed") and coordinator.has_method("snapshot"), "pause provides read-only change snapshots")
	if coordinator.has_signal("changed") and coordinator.has_method("snapshot"):
		var notifications: Array = []
		coordinator.connect("changed", func(state): notifications.append(state))
		var token = coordinator.acquire("manual", "owner")
		var state = coordinator.call("snapshot")
		t.check(state.is_read_only() and state[token].is_read_only(), "snapshot and nested entries read-only")
		t.check(not coordinator.release(token, "other") and notifications.size() == 1, "invalid release never notifies")
		t.check(coordinator.release(token, "owner") and notifications.size() == 2, "successful release notifies once")
		coordinator.cancel_all()
		t.check(notifications.size() == 2, "empty cancel is not a change")
		coordinator.acquire("level", "choice")
		coordinator.cancel_all()
		t.check(notifications.size() == 4 and notifications[-1].is_empty(), "actual cancel publishes empty snapshot")
	var f = Fixture.create(t, &"milo")
	var run = f.run
	var enemy = run.spawn_enemy(&"saltbound_thrall", run.hero.position + Vector2(80, 0))
	AttackExecutor.try_activate(run.hero, run, 0)
	run.hero.health.receive(5, 0, true)
	enemy.statuses.apply({"damage": 20.0, "burn": true, "frost": true}, 0)
	run.spawns.schedule_wave(run, 0)
	var frozen = [run.clock.tick, run.hero.position, run.hero.health.current, run.hero.next_ready, run.hero.health.invulnerable_until, enemy.position, enemy.statuses.next_burn, run.projectiles.get_child(0).position, run.spawns.reservations.size()]
	run.progression.collect_xp(900, 650)
	run.choices.present(run)
	var offer = run.choices.offer.duplicate()
	var identity = run.choices.offer_id
	t.check(run.pause.is_blocked() and offer.size() == 3, "level acquires pause and stable offer")
	run.toggle_manual_pause()
	for i in range(120): run.simulation.advance(run, Vector2.ONE)
	run.queue_hit(run.hero, 1000, Vector2.ZERO, 0, false, false)
	t.check(run.damage.requests.is_empty(), "paused callback cannot enqueue damage")
	t.check(frozen == [run.clock.tick, run.hero.position, run.hero.health.current, run.hero.next_ready, run.hero.health.invulnerable_until, enemy.position, enemy.statuses.next_burn, run.projectiles.get_child(0).position, run.spawns.reservations.size()], "all gameplay state freezes")
	run.choices.present(run)
	t.check(run.choices.offer == offer, "re-entry never resamples")
	t.check(not run.choices.confirm(run, identity, &"unknown"), "unoffered choice rejected")
	t.check(run.choices.confirm(run, identity, offer[0]), "one valid choice applied")
	t.check(not run.choices.confirm(run, identity, offer[0]), "old offer cannot be confirmed again")
	t.check(run.clock.tick == frozen[0] and run.progression.pending == 2, "no tick between queued levels")
	while run.progression.pending > 0:
		run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
	t.check(run.pause.is_blocked() and run.manual_token >= 0, "choice release preserves manual pause")
	run.toggle_manual_pause()
	run.simulation.advance(run, Vector2.ZERO)
	t.check(run.clock.tick == 1, "resume advances once without catch-up")
	Fixture.dispose(f)
	# Real mid-stage suspension: XP collection is not repeated on resume.
	f = Fixture.create(t)
	run = f.run
	var gem = f.catalog.scene("xp_gem").instantiate()
	gem.position = run.hero.position
	gem.value = 650
	gem.pickup_id = 700
	run.pickups.add_child(gem)
	run.simulation.advance(run, Vector2.ZERO)
	t.check(run.simulation.stage == 3 and run.clock.tick == 0, "stage suspended after XP before scheduling")
	while run.progression.pending > 0: run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
	run.simulation.advance(run, Vector2.ZERO)
	t.check(run.progression.level == 4 and run.progression.xp == 50 and run.clock.tick == 1, "resume suspended stage without duplicate pickup or tick")
	Fixture.dispose(f)

func check_pacing_boundaries(t) -> void:
	for boundary in [1800, 3600, 5400, 6600, 7200]:
		for offset in [-1, 0, 1]:
			var f = Fixture.create(t)
			var run = f.run
			run.clock.tick = boundary + offset
			run.simulation.stage = 2
			var old_enemy = run.spawn_enemy(&"lantern_cantor", Vector2(48, 48))
			run.progression.collect_xp(999999, 300)
			run.simulation.advance(run, Vector2.ZERO)
			t.check(run.simulation.stage == 3 and run.pause.is_blocked(), "boundary level suspends exact stage")
			var tokens = []
			for reason in ["manual", "focus", "debug", "event"]: tokens.append(run.pause.acquire(reason, "boundary-" + reason))
			var state = [run.clock.tick, run.simulation.stage, run.trace.waves.size(), run.spawns.reservations.size()]
			for i in 3: run.simulation.advance(run, Vector2.RIGHT)
			t.check(state == [run.clock.tick, run.simulation.stage, run.trace.waves.size(), run.spawns.reservations.size()], "all boundary tokens freeze stage/warnings/waves")
			while not run.choices.offer.is_empty(): run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
			for index in tokens.size():
				run.pause.release(tokens[index], "boundary-" + ["manual", "focus", "debug", "event"][index])
				if index < tokens.size()-1:
					run.simulation.advance(run, Vector2.ZERO)
					t.check(run.clock.tick == state[0], "partial token release cannot resume")
			run.simulation.advance(run, Vector2.ZERO)
			if boundary == 7200 and offset == 0:
				t.check(run.corruption.value == 10 and run.choices.event_token > 0 and run.trace.waves.is_empty(), "120s corruption then levels then event before wave")
				var identity = run.events.current.id
				run.choices.resolve_event(run, identity, &"leave" if run.events.current.kind == "mysterious_merchant" else &"decline")
				run.simulation.advance(run, Vector2.ZERO)
				t.check(run.trace.waves.size() == 1 and run.trace.waves[0].ids.size() == 6, "120s resolves into one six-slot original phase wave")
			t.check(run.clock.tick == boundary + offset + 1 and run.enemies.has(old_enemy), "resume exactly one tick; no cleanup of living prior enemies")
			Fixture.dispose(f)
