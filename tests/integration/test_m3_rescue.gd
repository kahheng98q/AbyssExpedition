extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")
const Fault = preload("res://tests/fixtures/fault_file_store.gd")

func run(t) -> void:
	var legacy = ProfileValidator.decode(FileAccess.get_file_as_string("res://tests/fixtures/profiles/v1.json"))
	var original = legacy.payload.duplicate(true)
	var converted = ProfileMigrations.v1_to_v2(legacy.payload, "12345")
	t.check(legacy.payload == original and converted.owned == original.owned, "pure migration preserves source and every starter record")
	t.check(converted.tickets == 0 and converted.tokens == 0 and converted.history == [] and converted.owned.size() == 3, "migration grants no tickets, tokens or recruits")
	t.check(ProfileValidator.payload_error(converted, 2) == "", "migrated schema validates")
	var golden = ProfileValidator.decode(FileAccess.get_file_as_string("res://tests/fixtures/profiles/v2.json"))
	var normalized_envelope = ProfileData.envelope(converted, 1, "golden-v2")
	normalized_envelope.schema_version = 2
	normalized_envelope.game_version = "m3.0"
	normalized_envelope.content_version = "m3.0"
	var normalized = ProfileValidator.decode(JSON.stringify(normalized_envelope))
	t.check(golden.error == "" and golden.payload == normalized.payload, "golden v2 migration fixture matches all fields")
	for failure in [false, true]:
		var location = "user://tests/m3-migrate-%d-%s/" % [Time.get_ticks_usec(), failure]
		DirAccess.make_dir_recursive_absolute(location)
		var file = FileAccess.open(location.path_join("profile-1.json"), FileAccess.WRITE)
		file.store_string(FileAccess.get_file_as_string("res://tests/fixtures/profiles/v1.json"))
		file.close()
		var fault = Fault.new()
		fault.remaining = 1 if failure else 0
		fault.stage = "rename"
		var writer = SaveCoordinator.new(location, fault)
		var opened = writer.open()
		if failure:
			t.check(not opened and writer.state == "save-blocked" and writer.envelope.schema_version == 1, "failed migration blocks play with legacy committed state intact")
			var bytes = writer.pending_bytes
			t.check(writer.retry() and writer.envelope.schema_version == 4 and writer.pending_bytes == "", "migration retry commits original candidate")
			t.check(JSON.parse_string(bytes).payload_json == writer.envelope.payload_json, "migration retry never reinitializes RNG")
		else: t.check(opened and writer.envelope.schema_version == 4, "loader publishes schema v4 at a higher revision")
		t.check(FileAccess.get_file_as_string(location.path_join("profile-1.json")) == FileAccess.get_file_as_string("res://tests/fixtures/profiles/v1.json"), "migration preserves original generation bytes")
		var saved = writer.payload.duplicate(true)
		writer.close()
		writer = SaveCoordinator.new(location)
		t.check(writer.open() and writer.payload == saved and writer.revision() == 2, "reopen keeps migrated RNG and revision")
		writer.close()
	for seed_value in [0, 42, 2147483647]:
		var f = Fixture.create_party(t, ProfileData.fresh(), seed_value)
		var run = f.run
		run.clock.tick = 14400
		run.progression.collect_xp(9999, 100)
		run.simulation.stage = 3
		run.simulation.advance(run, Vector2.ZERO)
		t.check(not run.choices.offer.is_empty() and run.rescue.state == "pending", "level choices precede rescue for seed " + str(seed_value))
		run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
		run.simulation.advance(run, Vector2.ZERO)
		t.check(run.rescue.state == "offered" and run.pause.is_blocked(), "guaranteed minute-four rescue for seed " + str(seed_value))
		var before = run.clock.tick
		for i in range(120): run.simulation.advance(run, Vector2.ONE)
		t.check(run.clock.tick == before and run.rescue.elapsed == 0, "offer pauses movement and active clock")
		var manual = run.pause.acquire("manual", "test")
		t.check(run.choices.resolve_rescue(run, true) and run.pause.is_blocked(), "accept releases only rescue token")
		t.check(not run.choices.resolve_rescue(run, true), "repeated rescue confirmation ignored")
		run.pause.release(manual, "test")
		t.check(run.rescue.center == run.hero.position and run.rescue_zone != null, "accepted zone centered on active hero")
		for i in range(1800): run.rescue.advance(run.hero.position, true)
		t.check(run.rescue.state == "succeeded" and run.party.size() == 1, "success earns a pending recruit without adding party member")
		var summary = RunSummary.freeze(run, "defeat")
		var settled = PermanentProgression.settle(ProfileData.fresh(), summary)
		t.check(settled.owned.has("sera") and settled.owned.sera == {"character_id": "sera"} and settled.tickets == 0, "rescue retained through later defeat; level-one Sera")
		var abandoned = PermanentProgression.settle(ProfileData.fresh(), RunSummary.freeze(run, "abandonment"))
		t.check(abandoned.owned.size() == 3 and abandoned.tickets == 0, "abandon drops rescue reward")
		Fixture.dispose(f)
	var p = ProfileData.fresh()
	var timed = Fixture.create_party(t, p, 101)
	var defending = timed.run
	defending.hero.health = ActorHealth.new(1000000)
	defending.hero.resistant = true # Controlled survivability; scheduled combat remains active.
	defending.clock.tick = 14400
	defending.simulation.stage = 3
	defending.simulation.advance(defending, Vector2.ZERO)
	defending.choices.resolve_rescue(defending, true)
	defending.simulation.advance(defending, Vector2.ZERO) # Finish suspended offer tick.
	var token = defending.pause.acquire("manual", "test")
	for i in range(120): defending.simulation.advance(defending, Vector2.ZERO)
	t.check(defending.rescue.elapsed == 0 and defending.clock.tick == 14401, "manual pause freezes defending timer and active clock")
	defending.pause.release(token, "test")
	for i in range(1800):
		while not defending.choices.offer.is_empty(): defending.choices.confirm(defending, defending.choices.offer_id, defending.choices.offer[0])
		defending.simulation.advance(defending, Vector2.ZERO)
		# A choice can suspend this tick after the defense timer stage.
		while not defending.choices.offer.is_empty(): defending.choices.confirm(defending, defending.choices.offer_id, defending.choices.offer[0])
		if defending.simulation.stage != 0: defending.simulation.advance(defending, Vector2.ZERO)
	t.check(defending.rescue.state == "succeeded" and defending.rescue.elapsed == 1800 and defending.clock.tick == 16201, "real coordinator counts 1800 defense ticks exactly once across level choices")
	t.check(not defending.trace.waves.is_empty(), "rescue retains scheduled normal waves")
	Fixture.dispose(timed)
	p.owned.sera = OwnedHero.record("sera", 700)
	var repeated = PermanentProgression.settle(p, {"outcome": "victory", "ticks": 18000, "hero": "aren", "rescue": {"state": "succeeded", "owned_at_start": true}})
	t.check(repeated.tickets == 4 and repeated.owned.sera == {"character_id": "sera"} and repeated.tokens == 0, "owned rescue adds one ticket, never duplicate hero or token")
	p.active = "sera"
	var f = Fixture.create_party(t, p)
	t.check(f.run.snapshot.sera_owned and f.run.hero.definition.id == &"sera", "Sera selectable in the next expedition")
	Fixture.dispose(f)
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/m3-guild-%d/" % Time.get_ticks_usec())
	t.root.add_child(app)
	t.check(app.screen_host.get_child(0).has_signal("recruitment_requested"), "guild is persistent entry hub")
	app.show_selection()
	t.check(app.screen_host.get_child(0).hero_buttons.size() == 3, "fresh selection shows only guaranteed owned starters")
	app.screen_host.get_child(0).select_hero(&"brann")
	t.check(app.screen_host.get_child(0).selected == &"aren", "locked hero cannot be selected")
	app.show_guild()
	app.show_roster()
	app.mount_run(RunStartSnapshot.new(303, &"aren"))
	app.run.set_physics_process(false)
	app.run.rescue.state = "succeeded"
	app.run.clock.tick = 18000
	var location = app.writer.store.root
	var summary = RunSummary.freeze(app.run, "defeat")
	app.show_results(summary, app.generation)
	var revision = app.writer.revision()
	app.show_results(summary, app.generation)
	t.check(app.writer.payload.owned.has("sera") and app.writer.payload.tickets == 1 and app.writer.revision() == revision, "actual app rescue settlement grants once on defeat")
	app.free()
	await t.process_frame
	var writer = SaveCoordinator.new(location)
	t.check(writer.open() and writer.payload.owned.sera == {"character_id": "sera"} and writer.payload.tickets == 1, "earned Sera and ticket survive actual app quit/reopen")
	writer.close()
