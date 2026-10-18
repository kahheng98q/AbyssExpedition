extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	for level_xp in [0, 2900]:
		var p = ProfileData.fresh()
		p.companions = ["lia", "milo"]
		for id in p.owned: p.owned[id] = OwnedHero.record(id, level_xp)
		var f = Fixture.create_party(t, p)
		var run = f.run
		var companion = run.party[1]
		var victim = run.spawn_enemy(&"saltbound_thrall", companion.position + Vector2(60, 0))
		AttackExecutor.try_activate(companion, run, 0)
		t.check(is_equal_approx(run.projectiles.get_child(0).damage, companion.stats.damage * 0.5), "companion outgoing damage halves after permanent modifiers")
		for member in run.party: member.health.current *= 0.5
		UpgradeEffects.apply(f.catalog.upgrades[&"might"], run.hero, run.progression)
		t.check(run.progression.stacks[&"might"] == 1 and is_equal_approx(companion.stats.damage, companion.starting_stats.damage * 1.1), "shared upgrade applied once and derived from permanent starting value")
		UpgradeEffects.apply(f.catalog.upgrades[&"battle_mend"], run.hero, run.progression)
		t.check(is_equal_approx(companion.health.current, companion.health.maximum * 0.7), "companion healing has full benefit")
		run.queue_hit(companion, 10000, Vector2.ZERO, 0, false, false)
		run.damage.resolve_tick_hits(run, 50)
		t.check(companion.health.dead and not run.enemies.has(companion) and run.deaths.is_empty() and run.phase == "active", "companion downing grants no kill/gem and does not end run")
		var damage_before = companion.stats.damage
		UpgradeEffects.apply(f.catalog.upgrades[&"might"], run.hero, run.progression)
		t.check(companion.stats.damage == damage_before and companion.health.current == 0, "downed character gets no upgrades or healing")
		run.queue_hit(run.hero, 10000, Vector2.ZERO, 0, false, false)
		run.clock.tick = 100
		run.simulation.advance(run, Vector2.ZERO)
		t.check(run.phase == "results" and run.summary.outcome == "defeat" and run.summary.participants == ["aren", "lia", "milo"], "active death ends expedition; downed participant remains in settlement")
		var next = PermanentProgression.settle(p, {"outcome": "victory", "ticks": 3600, "hero": "aren", "participants": run.summary.participants})
		t.check(next.owned.lia.total_xp == mini(2900, level_xp + 120), "downed selected companion receives equal earned XP")
		Fixture.dispose(f)
		f = Fixture.create_party(t, p)
		t.check(not f.run.party[1].health.dead and f.run.party[1].health.current == f.run.party[1].health.maximum and f.run.party[1].activations == 0, "next run restores health/counters")
		Fixture.dispose(f)
	# Same seeded wave composition, enemy stats and boss stats across party strength.
	var traces = []
	for powerful in [false, true]:
		var p = ProfileData.fresh()
		if powerful:
			p.companions = ["lia", "milo"]
			p.owned.aren = OwnedHero.record("aren", 2900, "swordmaster")
			p.owned.lia = OwnedHero.record("lia", 2900, "star_hunter")
			p.owned.milo = OwnedHero.record("milo", 2900, "void_caster")
		var f = Fixture.create_party(t, p, 202)
		for tick in range(0, 32400, 600): f.run.spawns.schedule_wave(f.run, tick)
		traces.append(f.run.trace.waves)
		var enemy = f.run.spawn_enemy(&"saltbound_thrall", Vector2(48, 48))
		var boss = f.run.spawn_enemy(&"tidebound_hierophant", Vector2(48, 48), -1, true)
		t.check(enemy.stats.max_health == 35 and boss.stats.max_health == 1200, "enemy/boss strength invariant across party progression")
		Fixture.dispose(f)
	t.check(traces[0] == traces[1], "fixed wave counts/composition unchanged by party size/strength")
	var p = ProfileData.fresh()
	p.companions = ["lia", "milo"]
	var f = Fixture.create_party(t, p)
	var gem = f.catalog.scene("xp_gem").instantiate()
	gem.position = f.run.party[1].position
	gem.value = 10
	gem.pickup_id = 7000
	f.run.pickups.add_child(gem)
	f.run.simulation.advance(f.run, Vector2.ZERO)
	t.check(not gem.collected and f.run.progression.xp == 0, "only active hero collects companion-adjacent XP")
	f.run.hero.position = gem.position
	f.run.simulation.advance(f.run, Vector2.ZERO)
	t.check(gem.collected and f.run.progression.xp == 10, "active collection advances one shared XP pool")
	var companion = f.run.party[1]
	f.run.clock.tick = 20
	f.run.queue_hit(companion, 10, Vector2.ZERO, 0, false, false)
	f.run.damage.resolve_tick_hits(f.run, 20)
	var health = companion.health.current
	f.run.clock.tick = 64
	f.run.queue_hit(companion, 10, Vector2.ZERO, 0, false, false)
	f.run.damage.resolve_tick_hits(f.run, 64)
	t.check(companion.health.current == health and companion.health.invulnerable_until == 65, "companion receives separate 45-active-tick immunity")
	f.run.clock.tick = 65
	f.run.queue_hit(companion, 10, Vector2.ZERO, 0, false, false)
	f.run.damage.resolve_tick_hits(f.run, 65)
	t.check(companion.health.current == health - 10, "companion immunity ends on exact deadline")
	Fixture.dispose(f)
	# Exercise the same boundary through the actual coordinator, not just a manual resolver.
	f = Fixture.create_party(t, p)
	companion = f.run.party[1]
	f.run.queue_hit(companion, 10, Vector2.ZERO, 0, false, false)
	f.run.simulation.advance(f.run, Vector2.ZERO)
	health = companion.health.current
	while f.run.clock.tick < 45:
		f.run.queue_hit(companion, 10, Vector2.ZERO, 0, false, false)
		f.run.simulation.advance(f.run, Vector2.ZERO)
	t.check(companion.health.current == health and companion.health.invulnerable_until == 45, "real active ticks preserve full companion immunity")
	f.run.queue_hit(companion, 10, Vector2.ZERO, 0, false, false)
	f.run.simulation.advance(f.run, Vector2.ZERO)
	t.check(companion.health.current == health - 10 and f.run.clock.tick == 46, "real tick 45 accepts exactly one hit")
	Fixture.dispose(f)
