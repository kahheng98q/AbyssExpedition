extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	var immunity_fixture = Fixture.create(t)
	var immunity_run = immunity_fixture.run
	immunity_run.hero.health.invulnerable_until = 45
	immunity_run.clock.tick = 44
	var probe_started = Time.get_ticks_usec()
	for i in range(10000): immunity_run.queue_hit(immunity_run.hero, 5, Vector2.ZERO, 0, false, false)
	print("INVULNERABILITY QUEUE PROBE: attempts=10000 retained_ids=%d elapsed_us=%d" % [immunity_run.damage.consumed.size(), Time.get_ticks_usec() - probe_started])
	t.check(immunity_run.damage.requests.is_empty() and immunity_run.damage.consumed.is_empty(), "immune hero hits allocate no pending requests or deduplication records")
	immunity_run.damage.resolve_tick_hits(immunity_run, 44)
	immunity_run.clock.tick = 45
	immunity_run.queue_hit(immunity_run.hero, 5, Vector2.ZERO, 0, false, false)
	immunity_run.damage.resolve_tick_hits(immunity_run, 45)
	t.check(immunity_run.hero.health.current == 245 and immunity_run.hero.health.invulnerable_until == 90, "fast rejection preserves exact immunity expiry and first eligible damage")
	Fixture.dispose(immunity_fixture)
	t.check(is_equal_approx(DamageService.amount(20, 5, 0.5), 7.5), "flat defense before resistance")
	t.check(DamageService.amount(2, 9) == 1, "minimum eligible damage")
	t.check(DamageService.amount(20, 0) == 20, "baseline damage")
	t.check(PlayerController.movement(1, 1, 1, 1) == Vector2.ZERO, "opposing inputs cancel")
	t.check(is_equal_approx(PlayerController.movement(0, 1, 0, 1).length(), 1), "diagonal normalized")
	t.check(PlayerController.movement(0, 0, 0, 0) == Vector2.ZERO, "release immediate")
	var health = ActorHealth.new(100)
	t.check(health.receive(8, 0, true), "first hit accepted")
	t.check(not health.receive(8, 44, true) and health.invulnerable_until == 45, "ignored hit does not extend immunity")
	t.check(health.receive(8, 45, true), "immunity ends on active tick 45")
	health.heal(1000)
	t.check(health.current == 100, "healing clamps")
	health.receive(1000, 90, true)
	health.heal(1000)
	t.check(health.dead and health.current == 0, "healing cannot revive")
	t.check(AttackExecutor.cooldown(1.1) == 55 and AttackExecutor.cooldown(100) == 1, "frequency ceil and lower bound")
	var f = Fixture.create(t)
	var run = f.run
	t.check(not AttackExecutor.try_activate(run.hero, run, 0), "no target preserves readiness")
	t.check(run.hero.next_ready == 0 and run.hero.activations == 0, "no target preserves counter")
	var first = run.spawn_enemy(&"saltbound_thrall", run.hero.position + Vector2(30, 0))
	var second = run.spawn_enemy(&"saltbound_thrall", run.hero.position + Vector2(30, 0))
	first.health = ActorHealth.new(100)
	second.health = ActorHealth.new(100)
	t.check(TargetingService.nearest(run.hero.position, 48, run.enemies) == first, "target ties use spawn order")
	t.check(AttackExecutor.try_activate(run.hero, run, 0), "ready arc fires")
	t.check(run.damage.requests.size() == 2, "arc hits distinct victims once")
	run.damage.resolve_tick_hits(run, 0)
	t.check(first.health.current == 64 and second.health.current == 64, "arc damage snapshot")
	var invalid = {"id": 900, "generation": -1, "target": first.actor_id, "damage": 90, "direction": Vector2.ZERO}
	run.damage.enqueue_hit(invalid)
	t.check(run.damage.requests.is_empty(), "stale generation rejected")
	invalid.generation = 1
	run.damage.enqueue_hit(invalid)
	run.damage.enqueue_hit(invalid)
	t.check(run.damage.requests.size() == 1, "duplicate queued hit rejected")
	run.damage.resolve_tick_hits(run, 1)
	run.damage.enqueue_hit(invalid)
	t.check(run.damage.requests.is_empty(), "late duplicate rejected")
	t.check(TargetingService.nearest(run.hero.position, 48, run.enemies) == second, "dead actor removed immediately")
	Fixture.dispose(f)
	for id_value in [&"lia", &"milo"]:
		f = Fixture.create(t, id_value)
		run = f.run
		first = run.spawn_enemy(&"saltbound_thrall", run.hero.position + Vector2(50, 0))
		AttackExecutor.try_activate(run.hero, run, 0)
		var shot = run.projectiles.get_child(0)
		t.check(shot.homing == (id_value == &"milo"), "distinct projectile modes")
		first.position += Vector2(0, 40)
		var before = shot.direction
		shot.simulate(1)
		t.check(shot.direction != before if shot.homing else shot.direction == before, "homing steers; straight keeps direction")
		if shot.homing:
			first.health.dead = true
			second = run.spawn_enemy(&"saltbound_thrall", shot.position + Vector2(50, 0))
			shot.simulate(2)
			t.check(shot.target_id == second.actor_id and shot.expires == 180, "homing reacquires without lifetime refresh")
			second.health.dead = true
			shot.simulate(3)
			t.check(shot.is_queued_for_deletion(), "homing expires without valid target")
		else:
			shot.simulate(180)
			t.check(shot.is_queued_for_deletion(), "straight finite lifetime")
		Fixture.dispose(f)
	f = Fixture.create(t)
	run = f.run
	UpgradeEffects.apply(f.catalog.upgrades[&"echo_strike"], run.hero, run.progression)
	UpgradeEffects.apply(f.catalog.upgrades[&"echo_strike"], run.hero, run.progression)
	run.spawn_enemy(&"shellbound_husk", run.hero.position + Vector2(30, 0))
	AttackExecutor.try_activate(run.hero, run, 0)
	t.check(run.hero.activations == 1 and run.followups.size() == 2, "melee Echo follow-ups count as one activation")
	t.check(run.followups[0].damage == 18 and run.followups[0].due == 6 and run.followups[1].due == 12, "Echo half-damage arc snapshots and active delays")
	Fixture.dispose(f)
