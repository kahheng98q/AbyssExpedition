extends SceneTree

# Controlled cross-version fixture, never a natural-human-input recording.
const Observer = preload("res://tests/fixtures/pacing_observer.gd")
var output: String
var build_hash: String
var fixture_hash: String
var presentation: bool = true
var preview_access: bool = false
var failures: Array = []
var capture_errors = preload("res://tests/error_capture.gd").new()

class FixtureWriter extends SaveCoordinator:
	# Freeze operation identity only; persistence, checksums, locks and writes stay real.
	func operation_id() -> String:
		return "sword-fixture-revision-%d" % revision()

func _initialize() -> void:
	ProfileStore.test_mode = true
	OS.add_logger(capture_errors)
	call_deferred("begin")

static func resource_state(value):
	if value is Resource:
		var result = {}
		for property in value.get_property_list():
			if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and property.usage & PROPERTY_USAGE_STORAGE:
				# New optional default is not an authored non-sword config change.
				if property.name == "sword_identity" and value.get(property.name) == &"": continue
				result[property.name] = resource_state(value.get(property.name))
		return result
	if value is Color: return [value.r, value.g, value.b, value.a]
	if value is Array: return value.map(func(item): return resource_state(item))
	return Observer.portable(value)

func begin() -> void:
	var args = OS.get_cmdline_user_args()
	var options = {}
	if args.size() % 2 != 0: quit(2); return
	for i in range(0, args.size(), 2):
		if args[i] not in ["--output", "--build-hash", "--fixture-hash", "--presentation", "--preview"] or options.has(args[i]): quit(2); return
		options[args[i]] = args[i+1]
	for key in ["--output", "--build-hash", "--fixture-hash"]:
		if not options.has(key): quit(2); return
	output = options["--output"]
	build_hash = options["--build-hash"]
	fixture_hash = options["--fixture-hash"]
	if options.get("--presentation", "enabled") not in ["enabled", "disabled"] or options.get("--preview", "no") not in ["yes", "no"]: quit(2); return
	presentation = options.get("--presentation", "enabled") == "enabled"
	preview_access = options.get("--preview", "no") == "yes"
	for seed_value in [101, 202, 303]:
		for hero in ["aren", "brann"]:
			for profession in ["swordsman", "swordmaster", "abyss_swordsman"]:
				for companion in [false, true]:
					await capture(hero, profession, companion, seed_value)
		for pair in [["lia", "archer"], ["lia", "sharpshooter"], ["lia", "star_hunter"], ["milo", "mage"], ["milo", "elemental_sage"], ["milo", "void_caster"]]:
			await capture(pair[0], pair[1], false, seed_value)
		for profession in ["swordmaster", "abyss_swordsman"]:
			await capture_lifecycle(profession, seed_value)
	if not capture_errors.snapshot().is_empty(): failures.append_array(capture_errors.snapshot())
	OS.remove_logger(capture_errors)
	print("SWORD CAPTURE complete failures=" + str(failures))
	quit(0 if failures.is_empty() else 1)

func capture(hero: String, profession: String, companion: bool, seed_value: int) -> void:
	var id = "%s-%s-%s-%d" % [hero, profession, "companion" if companion else "hero", seed_value]
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/sword-%s-%d/" % [id, Time.get_ticks_usec()])
	root.add_child(app)
	var profile = ProfileData.fresh()
	# Freeze the entire independent profile, including the non-gameplay draw stream.
	# Never whitelist a differing starting profile or edit the normal player save.
	profile.draw_rng = DrawRng.initial("314159")
	profile.owned[hero] = OwnedHero.record(hero, 1400, profession if profession != ProfileData.BASES[hero] else "")
	profile.active = "lia" if companion else hero
	profile.companions = [hero] if companion else []
	if companion: profile.owned.lia = OwnedHero.record("lia", 1400)
	if not app.writer.mutate(profile, app.writer.revision(), "sword-capture"): failures.append(id + ": profile failure"); app.free(); return
	var before = app.writer.payload.duplicate(true)
	var revision = app.writer.revision()
	if preview_access:
		app.show_promotion(hero)
		var page = app.screen_host.get_child(0)
		for visual in page.branch_previews.values():
			if visual.get_property_list().any(func(item): return item.name == "now_usec"):
				var microseconds = [0]
				visual.set("now_usec", func(): return microseconds[0])
				visual.set("focused", true)
				visual.call("_process", 0.0)
				microseconds[0] = 60000000
				visual.call("_process", 0.0)
		app.show_roster()
	if before != app.writer.payload or revision != app.writer.revision(): failures.append(id + ": preview wrote profile")
	# Profile was committed above with an explicit fixture operation identity.
	# Start the real App run without adding a wall-clock selection receipt.
	app.mount_saved_run(seed_value)
	var run = app.run
	run.set_physics_process(false)
	run.set_meta("sword_presentation_disabled", not presentation)
	run.combat_audio.set_enabled(false)
	var subject = run.party[1] if companion else run.hero
	# A fixed, recorded controlled starting encounter, identical across versions.
	for member in run.party: member.health.current = member.health.maximum - 10.0
	var victim = run.spawn_enemy(&"shellbound_husk", subject.position + Vector2(24, 0))
	victim.health = ActorHealth.new(1000000)
	var rear = run.spawn_enemy(&"shellbound_husk", subject.position + Vector2(-24, 0))
	rear.health = ActorHealth.new(1000000)
	run.progression.stacks[&"echo_strike"] = 1
	var observer = Observer.new()
	observer.bind(app)
	var states: Array = []
	var facts: Array = []
	run.attack_committed.connect(func(fact): facts.append({"attack": Observer.portable(fact)}))
	run.damage_accepted.connect(func(fact): facts.append({"damage": Observer.portable(fact)}))
	var presentation_facts: Array = []
	if run.has_signal("branch_heal_applied"):
		run.connect("branch_heal_applied", func(fact): presentation_facts.append(Observer.portable(fact)))
	var inputs: Array = []
	var profiles = {}
	for key in app.catalog.professions: profiles[String(key)] = resource_state(app.catalog.professions[key])
	for tick in range(360):
		if run.phase != "active": failures.append(id + ": early end"); break
		if not run.choices.offer.is_empty(): run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
		var direction = Vector2.ZERO
		inputs.append({"tick": tick, "direction": [direction.x, direction.y]})
		run.simulation.advance(run, direction)
		states.append(observer.final_state())
		await physics_frame
	var record = {"metadata": {"session_id": id, "hero": hero, "profession": profession, "companion": companion, "seed": seed_value, "engine": Engine.get_version_info().string, "simulation": ReplayTrace.SIMULATION_VERSION, "build_hash": build_hash, "fixture_hash": fixture_hash, "catalog": app.catalog.digest, "party": run.snapshot.members, "protocol": "sword-controlled-v1"}, "initial_profile": before, "starting_profile_hash": JSON.stringify(before, "", true, true).sha256_text(), "profile_after": app.writer.payload.duplicate(true), "inputs": inputs, "states": states, "facts": facts, "final": observer.final_state(), "trace": run.trace.snapshot(), "professions": profiles, "presentation": {"enabled": presentation, "preview_access": preview_access, "branch_heals": presentation_facts}}
	var file = FileAccess.open(output.path_join(id + ".json"), FileAccess.WRITE)
	if file == null: failures.append(id + ": output failure")
	else:
		file.store_string(JSON.stringify(record, "", true, true))
		file.close()
	print("SWORD SAMPLE " + id + " ticks=" + str(states.size()))
	app.leave_run()
	app.free()
	paused = false
	await process_frame

func capture_lifecycle(profession: String, seed_value: int) -> void:
	var id = "lifecycle-aren-%s-%d" % [profession, seed_value]
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = FixtureWriter.new("user://tests/sword-%s-%d/" % [id, Time.get_ticks_usec()])
	root.add_child(app)
	var profile = ProfileData.fresh()
	profile.draw_rng = DrawRng.initial("314159")
	profile.owned.aren = OwnedHero.record("aren", 1400, profession)
	if not app.writer.mutate(profile, app.writer.revision(), "sword-lifecycle-fixture"):
		failures.append(id + ": profile failure"); app.free(); return
	var before = app.writer.payload.duplicate(true)
	var revision = app.writer.revision()
	if preview_access:
		app.show_promotion("aren")
		var page = app.screen_host.get_child(0)
		for visual in page.branch_previews.values():
			if visual.get_property_list().any(func(item): return item.name == "now_usec"):
				var microseconds = [0]
				visual.set("now_usec", func(): return microseconds[0])
				visual.call("_on_window_focus_entered")
				visual.call("_process", 0.0)
				microseconds[0] = 60000000
				visual.call("_process", 0.0)
		app.show_roster()
	if before != app.writer.payload or revision != app.writer.revision(): failures.append(id + ": preview changed profile")
	app.mount_saved_run(seed_value)
	var run = app.run
	run.set_physics_process(false)
	run.set_meta("sword_presentation_disabled", not presentation)
	run.combat_audio.set_enabled(false)
	# Explicit controlled initial condition, not elapsed natural play or a replay.
	# The real scheduler reaches tick7200 and consumes its normal event RNG stream.
	run.clock.tick = 7190
	run.hero.health.current -= 10
	var gem = run.catalog.scene("xp_gem").instantiate()
	gem.position = run.hero.position
	gem.pickup_id = 1000000
	gem.value = 100
	run.pickups.add_child(gem)
	var target = run.spawn_enemy(&"shellbound_husk", run.hero.position + Vector2(24, 0))
	target.health = ActorHealth.new(1000000)
	var observer = Observer.new()
	observer.bind(app)
	var profiles = {}
	for key in app.catalog.professions: profiles[String(key)] = resource_state(app.catalog.professions[key])
	var states: Array = []
	var facts: Array = []
	var inputs: Array = [{"tick": 7190, "kind": "controlled_initial_state", "xp_pickup": 100, "pickup_id": 1000000, "target_id": target.actor_id}]
	run.attack_committed.connect(func(fact): facts.append({"attack": Observer.portable(fact)}))
	run.damage_accepted.connect(func(fact): facts.append({"damage": Observer.portable(fact)}))
	var terminal = {}
	run.run_finished.connect(func(summary):
		terminal["final"] = observer.final_state()
		terminal["trace"] = run.trace.snapshot()
		var snapshot = summary.duplicate(true)
		snapshot.erase("trace") # Stored exactly once as the full top-level trace.
		terminal["summary"] = snapshot)
	var attempts = 0
	while run.phase == "active" and run.clock.tick < 7550 and attempts < 500:
		attempts += 1
		if not run.choices.offer.is_empty():
			if not run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0]): failures.append(id + ": upgrade rejected")
		if run.choices.event_token >= 0:
			var choice: StringName = &"leave" if run.events.current.kind == "mysterious_merchant" else &"decline"
			if not run.choices.resolve_event(run, run.events.current.id, choice): failures.append(id + ": event rejected")
		inputs.append({"tick": run.clock.tick, "direction": [0.0, 0.0]})
		run.simulation.advance(run, Vector2.ZERO)
		states.append(observer.final_state())
		await physics_frame
	if run.phase != "active" or run.clock.tick != 7550:
		failures.append(id + ": early end"); app.free(); paused = false; return
	# An external lethal request exercises accepted damage -> defeat -> App save.
	inputs.append({"tick": 7550, "kind": "queued_lethal_damage", "amount": 1000000})
	run.hero.health.invulnerable_until = -1
	run.queue_hit(run.hero, 1000000, Vector2.ZERO, 0, false, false)
	run.simulation.advance(run, Vector2.ZERO)
	if terminal.is_empty(): failures.append(id + ": no terminal signal"); app.free(); paused = false; return
	var metadata = {"session_id": id, "hero": "aren", "profession": profession, "companion": false, "seed": seed_value, "engine": Engine.get_version_info().string, "simulation": ReplayTrace.SIMULATION_VERSION, "build_hash": build_hash, "fixture_hash": fixture_hash, "catalog": app.catalog.digest, "party": run.snapshot.members, "protocol": "sword-lifecycle-v1"}
	await process_frame
	await process_frame
	var round_trip = {}
	for generation in app.writer.store.generations():
		var decoded = ProfileValidator.decode(app.writer.store.read(generation.path))
		if decoded.get("envelope", {}).get("revision", -1) == app.writer.revision(): round_trip = decoded.payload
	var settlements = app.writer.receipts.values().filter(func(result): return result.get("kind") == "settlement").size()
	var record = {"metadata": metadata, "fixture": {"start_tick": 7190, "end_tick": 7550, "xp_pickup": 100, "termination": "queued_lethal_damage"}, "initial_profile": before, "profile_after": app.writer.payload.duplicate(true), "inputs": inputs, "states": states, "facts": facts, "final": terminal.final, "trace": terminal.trace, "summary": terminal.summary, "save": {"before_revision": revision, "revision": app.writer.revision(), "settlement_count": settlements, "state": app.writer.state, "round_trip_payload": round_trip}, "professions": profiles, "presentation": {"enabled": presentation, "preview_access": preview_access}}
	if app.writer.revision() != revision + 1 or settlements != 1 or round_trip != app.writer.payload: failures.append(id + ": settlement/roundtrip failed")
	var file = FileAccess.open(output.path_join(id + ".json"), FileAccess.WRITE)
	if file == null: failures.append(id + ": output failure")
	else: file.store_string(JSON.stringify(record, "", true, true)); file.close()
	print("SWORD LIFECYCLE " + id + " offers=" + str(terminal.trace.offers.size()) + " decisions=" + str(terminal.trace.decisions.size()) + " events=" + str(terminal.trace.events.size()) + " settlements=" + str(settlements))
	app.free()
	paused = false
	await process_frame
