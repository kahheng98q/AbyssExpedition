extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
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
