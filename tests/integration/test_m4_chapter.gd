extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func force_event(r, kind: String) -> int:
	r.events.current = {"id": 77, "tick": r.clock.tick, "kind": kind}
	r.choices.event_token = r.pause.acquire("event", "event-choice")
	return 77

func run(t) -> void:
	var p = ProfileData.fresh()
	p.companions = ["lia", "milo"]
	var f = Fixture.create_party(t, p)
	var r = f.run
	force_event(r, "mysterious_merchant")
	r.coins = 19
	var hp = r.hero.health.current
	t.check(not r.choices.resolve_event(r, 77, &"heal") and r.coins == 19 and r.hero.health.current == hp, "merchant rejects insufficient coins atomically")
	r.coins = 20
	r.hero.health.current = 1
	t.check(r.choices.resolve_event(r, 77, &"heal") and r.coins == 0 and is_equal_approx(r.hero.health.current, 1 + hp * 0.25), "merchant exact heal cost and active-only benefit")
	t.check(not r.choices.resolve_event(r, 77, &"heal"), "repeated event cannot spend twice")
	force_event(r, "mysterious_merchant")
	r.coins = 30
	t.check(r.choices.resolve_event(r, 77, &"might") and r.coins == 0 and r.progression.stacks[&"might"] == 1, "merchant Might uses shared upgrade service")
	force_event(r, "forbidden_altar")
	r.hero.health.current = r.hero.health.maximum * 0.2
	var damage = r.hero.stats.damage
	t.check(not r.choices.resolve_event(r, 77, &"blood_tithe") and r.corruption.value == 0 and r.hero.stats.damage == damage, "Blood Tithe must leave at least one health")
	r.hero.health.current += 1
	r.party[2].health.dead = true
	var downed = r.party[2].stats.damage
	t.check(r.choices.resolve_event(r, 77, &"blood_tithe") and is_equal_approx(r.hero.health.current, 1) and r.corruption.value == 25, "Blood Tithe exact health and corruption costs")
	t.check(is_equal_approx(r.hero.stats.damage, r.hero.starting_stats.damage * 1.4) and r.party[2].stats.damage == downed, "contract and Might add against baseline; downed party excluded")
	UpgradeEffects.apply(r.catalog.upgrades[&"might"], r.hero, r.progression)
	t.check(is_equal_approx(r.hero.stats.damage, r.hero.starting_stats.damage * 1.5), "later level upgrades preserve contract buff")
	force_event(r, "forbidden_altar")
	r.corruption.add(41)
	t.check(not r.choices.resolve_event(r, 77, &"unbound_assault") and r.corruption.value == 66, "full headroom required; no partial benefit")
	t.check(r.choices.resolve_event(r, 77, &"decline") and r.corruption.value == 66, "decline changes no state")
	force_event(r, "forbidden_altar")
	r.corruption.value = 65
	var frequency = r.hero.starting_stats.frequency
	t.check(r.choices.resolve_event(r, 77, &"unbound_assault") and r.corruption.value == 100 and is_equal_approx(r.hero.stats.frequency, frequency * 1.4), "assault at exact headroom boundary")
	Fixture.dispose(f)
	# Real tick arbitration: level > event, no time advance between, manual pause survives.
	f = Fixture.create(t)
	r = f.run
	r.clock.tick = 7200
	r.simulation.stage = 3
	r.progression.collect_xp(444, 100)
	r.simulation.advance(r, Vector2.ZERO)
	t.check(not r.choices.offer.is_empty() and r.events.current.is_empty(), "earned level precedes event")
	r.choices.confirm(r, r.choices.offer_id, r.choices.offer[0])
	r.simulation.advance(r, Vector2.ZERO)
	t.check(r.choices.event_token >= 0 and r.clock.tick == 7200, "event pauses suspended tick")
	var token = r.pause.acquire("manual", "test")
	for i in range(120): r.simulation.advance(r, Vector2.ONE)
	t.check(r.clock.tick == 7200, "event/manual pause freezes complete simulation")
	var id = r.events.current.id
	var free = &"leave" if r.events.current.kind == "mysterious_merchant" else &"decline"
	t.check(r.choices.resolve_event(r, id, free) and r.pause.is_blocked(), "event releases only its own token")
	r.pause.release(token, "test")
	r.simulation.advance(r, Vector2.ZERO)
	t.check(r.clock.tick == 7201, "suspended tick resumes exactly once")
	force_event(r, "forbidden_altar")
	r.finish("defeat")
	t.check(r.events.current.is_empty() and r.choices.event_token < 0 and not r.choices.resolve_event(r, 77, &"blood_tithe"), "terminal cancels event and stale commands")
	Fixture.dispose(f)
	f = Fixture.create(t)
	r = f.run
	r.clock.tick = 32400
	r.simulation.stage = 4
	force_event(r, "forbidden_altar")
	r.simulation.advance(r, Vector2.ZERO)
	t.check(not r.spawns.boss_placed and r.clock.tick == 32400, "pending event blocks boss entry without advancing time")
	r.choices.resolve_event(r, 77, &"decline")
	r.simulation.advance(r, Vector2.ZERO)
	t.check(r.spawns.boss_placed and r.clock.tick == 32401 and r.trace.waves.is_empty(), "boss enters after event; no normal wave backlog")
	Fixture.dispose(f)
	# Actual app settlement, saved chapter and repeat entry.
	# Owned opportunities are independent; three successes settle three repeat tickets.
	p = ProfileData.fresh()
	p.owned.sera = OwnedHero.record("sera")
	f = Fixture.create_party(t, p)
	r = f.run
	for tick in [7200, 14400, 21600]:
		r.clock.tick = tick
		r.events.current = {"id": tick, "tick": tick, "kind": "lost_adventurer"}
		r.choices.present_rescue(r)
		t.check(r.rescue.state == "offered" and r.choices.resolve_rescue(r, true), "distinct owned rescue accepted")
		for i in range(1800): r.rescue.advance(r.hero.position, true)
		t.check(r.rescue.state == "succeeded", "each owned opportunity independently succeeds")
	var repeated = RunSummary.freeze(r, "victory")
	t.check(repeated.rescue.repeat_successes == 3 and PermanentProgression.preview("victory", 21600, repeated.rescue).tickets == 6, "all three owned rescue rewards join one settlement")
	t.check(PermanentProgression.preview("abandonment", 21600, repeated.rescue).tickets == 0, "abandonment drops all repeat rewards")
	Fixture.dispose(f)
	var app = load("res://scenes/app/app.tscn").instantiate()
	var location = "user://tests/m4-chapter-%d/" % Time.get_ticks_usec()
	app.writer = SaveCoordinator.new(location)
	t.root.add_child(app)
	app.mount_run(RunStartSnapshot.new(101, &"aren"))
	app.run.set_physics_process(false)
	app.run.clock.tick = 33000
	app.run.finish("victory")
	await t.process_frame
	t.check(app.writer.payload.get("chapters", {}).get("coast", false), "boss victory durably marks coastal chapter")
	var revision = app.writer.revision()
	app.show_results({"outcome": "victory"}, app.generation)
	t.check(app.writer.revision() == revision, "results reentry never settles twice")
	app.free()
	await t.process_frame
	var writer = SaveCoordinator.new(location)
	t.check(writer.open() and writer.payload.get("chapters", {}).get("coast", false), "chapter survives close/reopen")
	writer.close()
