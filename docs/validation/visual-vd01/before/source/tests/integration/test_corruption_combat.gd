extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	# Corruption may introduce mothers before their baseline eight-minute phase.
	for phase_tick in [600, 7800, 15000, 22200, 29400]:
		for threshold in [49, 50, 75, 100]:
			var content = ContentCatalog.new()
			t.root.add_child(content)
			t.check(content.load_all(), "early corruption catalog")
			var c = CorruptionService.new()
			c.add(threshold)
			var base_rng = RandomNumberGenerator.new()
			var altered_rng = RandomNumberGenerator.new()
			base_rng.seed = 101
			altered_rng.seed = 101
			var transferred = 0
			var actual = 0
			for i in range(100):
				var plain = content.waves.composition(phase_tick, base_rng, {"count": c.modifiers().count})
				var changed = content.waves.composition(phase_tick, altered_rng, c.modifiers())
				t.check(plain.size() == changed.size(), "corruption weight transfer preserves scheduled count")
				for j in plain.size():
					if plain[j] != changed[j]:
						t.check(plain[j] == &"saltbound_thrall" and changed[j] == &"reef_broodmother", "only Thrall mass transfers to mothers")
						transferred += 1
					if changed[j] == &"reef_broodmother": actual += 1
			t.check(transferred > 0 if threshold >= 50 else transferred == 0, "mother transfer threshold in every phase: %d/%d" % [phase_tick, threshold])
			if phase_tick < 28800: t.check(actual > 0 if threshold >= 50 else actual == 0, "early mothers follow corruption only")
			content.free()
	var f = Fixture.create(t)
	var r = f.run
	var old = r.spawn_enemy(&"saltbound_thrall", Vector2(48, 48))
	var damage = old.stats.damage
	r.corruption.add(75)
	var fresh = r.spawn_enemy(&"saltbound_thrall", Vector2(80, 48))
	t.check(is_equal_approx(fresh.stats.damage, damage * 1.15) and old.stats.damage == damage and fresh.corrupted, "only future enemies become corrupted variants")
	r.deaths = [old]
	r.drop_rewards()
	var gem = r.pickups.get_child(0)
	t.check(gem.value == 13 and gem.coins == 1, "death snapshots corruption XP and one coin")
	r.corruption.add(25)
	t.check(gem.value == 13, "old gems never change")
	for threshold in [0, 25, 100]:
		var c = CorruptionService.new()
		c.add(threshold)
		var ids = r.catalog.waves.composition(28800, RandomNumberGenerator.new(), c.modifiers())
		t.check(ids.size() == ceili(12 * c.modifiers().count), "wave count rounded once at " + str(threshold))
	var first = RandomNumberGenerator.new()
	var second = RandomNumberGenerator.new()
	first.seed = 101
	second.seed = 101
	var normal = {"saltbound_thrall": 0, "reef_broodmother": 0}
	var altered = normal.duplicate()
	for i in range(1000):
		for id in r.catalog.waves.composition(29400, first):
			if normal.has(String(id)): normal[String(id)] += 1
		for id in r.catalog.waves.composition(29400, second, {"brood": true}):
			if altered.has(String(id)): altered[String(id)] += 1
	t.check(normal.saltbound_thrall - altered.saltbound_thrall == altered.reef_broodmother - normal.reef_broodmother and altered.reef_broodmother > normal.reef_broodmother, "weight swap preserves all other enemy shares")
	var boss = r.spawn_enemy(&"tidebound_hierophant", Vector2(480, 48), -1, true)
	boss.activations = 1
	boss.deadline = 0
	BossController.decide(boss, r, 0)
	t.check(r.boss_hits.size() == 2, "cap adds second eruption circle")
	for hit in r.boss_hits:
		t.check(hit.due >= 45 and hit.warning.geometry == "circle", "every added danger has full warning")
	var point = r.boss_hits[0].warning.position
	r.hero.position += Vector2(40, 0)
	t.check(r.boss_hits[0].warning.position == point, "warning geometry remains committed")
	r.spawns.reservations.clear()
	r.spawns.schedule_wave(r, 0)
	var snapshot = r.spawns.reservations[0].modifiers.duplicate(true)
	t.check(snapshot.damage == 1.15, "wave reservations retain corruption snapshot")
	Fixture.dispose(f)
	f = Fixture.create(t)
	r = f.run
	r.corruption.add(20)
	r.clock.tick = 3600
	r.simulation.stage = 2
	r.simulation.advance(r, Vector2.ZERO)
	t.check(r.corruption.value == 25 and r.trace.waves[0].ids.size() == 5, "minute corruption increment precedes coincident wave snapshot")
	var token = r.pause.acquire("manual", "test")
	for i in range(120): r.simulation.advance(r, Vector2.ZERO)
	t.check(r.corruption.value == 25 and r.clock.tick == 3601, "pause cannot advance corruption or active minutes")
	r.pause.release(token, "test")
	Fixture.dispose(f)
	f = Fixture.create(t)
	r = f.run
	r.corruption.add(74)
	r.spawns.reserve(r, &"saltbound_thrall", Vector2(48, 48), 0)
	r.corruption.add(1)
	r.spawns.simulate(r, 45)
	t.check(not r.enemies[0].corrupted and r.enemies[0].stats.damage == r.catalog.enemies[&"saltbound_thrall"].stats.damage, "threshold during spawn warning never rewrites wave snapshot")
	var child = r.spawn_enemy(&"broodling", Vector2(60, 60), r.enemies[0].actor_id)
	t.check(child.corrupted, "later broodlings receive then-current corruption damage")
	for i in range(97): r.spawn_enemy(&"saltbound_thrall", Vector2(48, 48))
	r.spawns.schedule_wave(r, 28800)
	t.check(r.enemies.size() + r.spawns.reservations.size() == 100, "corruption bonus respects crowded total cap")
	Fixture.dispose(f)
	f = Fixture.create(t)
	r = f.run
	r.corruption.add(99)
	boss = r.spawn_enemy(&"tidebound_hierophant", Vector2(480, 48), -1, true)
	boss.activations = 1
	boss.deadline = 0
	BossController.decide(boss, r, 0)
	point = r.boss_hits[0].warning.position
	r.corruption.add(1)
	t.check(r.boss_hits.size() == 1 and r.boss_hits[0].warning.position == point and r.phase == "active", "reaching cap never adds unannounced danger or ends run")
	Fixture.dispose(f)
