extends SceneTree

const Observer = preload("res://tests/fixtures/pacing_observer.gd")
var app
var observer
var audio_enabled: bool = false
var fixture_mode: String = "Integrated"
var mode: String = ""
var hero: StringName
var seed_value: int
var output: String = ""
var input_path: String = ""
var frozen: Dictionary = {}
var movement_index: int = 0
var decision_index: int = 0
var replay_pause_index: int = 0
var replay_event_index: int = 0
var replay_owned_tokens: Dictionary = {}
var direction: Vector2 = Vector2.ZERO
var done: bool = false
var deadline: int
var terminal_report: Dictionary = {}
var metadata: Dictionary = {}
var error_capture = preload("res://tests/error_capture.gd").new()

class LegacyEdgeSpawns extends SpawnDirector:
	func opening_candidate(rng: RandomNumberGenerator, _field: FieldDefinition, _index: int) -> Vector2:
		return edge_candidate(rng)

class Driver extends Node:
	var session
	func _physics_process(_delta: float) -> void: session.step()

func _initialize() -> void:
	OS.add_logger(error_capture)
	call_deferred("begin")

func begin() -> void:
	var args = OS.get_cmdline_user_args()
	var accepted = ["--mode", "--hero", "--seed", "--output", "--input", "--fixture", "--audio"]
	var options = {}
	if args.size() % 2 != 0: quit(2); return
	for i in range(0, args.size(), 2):
		if not args[i] in accepted or options.has(args[i]): quit(2); return
		options[args[i]] = args[i+1]
	if not options.has("--mode") or not options.has("--hero") or not options.has("--seed") or not options.has("--output"): quit(2); return
	if options.get("--audio", "disabled") not in ["enabled", "disabled"]: quit(2); return
	audio_enabled = options.get("--audio", "disabled") == "enabled"
	fixture_mode = options.get("--fixture", "Integrated")
	if fixture_mode not in ["Integrated", "US1", "US2"]: quit(2); return
	mode = options["--mode"]
	hero = StringName(options["--hero"])
	if mode not in ["Record", "Replay"] or hero not in [&"aren", &"lia", &"milo"] or not SeedStreams.valid_seed(options["--seed"]): quit(2); return
	seed_value = int(options["--seed"])
	output = options["--output"]
	if FileAccess.file_exists(output): quit(2); return
	if mode == "Replay":
		ProfileStore.test_mode = true
		input_path = options.get("--input", "")
		if not FileAccess.file_exists(input_path): quit(2); return
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(input_path))
		if not parsed is Dictionary or not parsed.has("trace") or not parsed.has("metadata"): quit(2); return
		frozen = parsed
	else:
		# Real movement input, normal save boundary, separate process APPDATA.
		ProfileStore.test_mode = false
		if DisplayServer.get_name() == "headless": quit(2); return
	app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/pacing-%s-%d/" % [hero, seed_value] if mode == "Replay" else "user://profiles/acceptance/")
	root.add_child(app)
	if app.writer.state != "ready": quit(1); return
	app.mount_run(RunStartSnapshot.new(seed_value, hero))
	if not is_instance_valid(app.run): quit(1); return
	app.run.set_physics_process(false)
	app.run.combat_audio.set_enabled(audio_enabled)
	if fixture_mode == "US1":
		app.catalog.waves = app.catalog.waves.duplicate(true)
		for segment in app.catalog.waves.opening_segments:
			segment.slots = ["saltbound_thrall", "saltbound_thrall", "saltbound_thrall", "saltbound_thrall"]
	elif fixture_mode == "US2":
		app.run.spawns = LegacyEdgeSpawns.new()
		app.run.spawns.initialize_opening(app.run.hero.position)
	observer = Observer.new()
	observer.bind(app)
	app.run.run_finished.connect(func(_summary): terminal_report = observer.report())
	metadata = {"session_id": "%s-%d" % [hero, seed_value], "hero": String(hero), "seed": seed_value, "engine": Engine.get_version_info().string, "simulation": ReplayTrace.SIMULATION_VERSION, "catalog": app.catalog.digest, "build_hash": OS.get_environment("ABYSS_PACING_BUILD_HASH"), "fixture_hash": OS.get_environment("ABYSS_PACING_FIXTURE_HASH"), "party": app.run.snapshot.members, "corruption": 0, "driver": AudioServer.get_driver_name(), "device": AudioServer.output_device, "sample_rate": AudioServer.get_mix_rate(), "mode": mode, "audio_enabled": audio_enabled, "fixture_mode": fixture_mode}
	if mode == "Replay":
		var mismatch = Observer.metadata_error(frozen.metadata, metadata)
		if mismatch != "": fail(mismatch); return
		# StringName and integral JSON float values compare through canonical JSON.
		if frozen.trace.start != JSON.parse_string(JSON.stringify(app.run.trace.metadata,"",false,true)): fail("trace start mismatch"); return
	deadline = Time.get_ticks_msec() + (180000 if mode == "Replay" else 900000)
	var driver = Driver.new()
	driver.session = self
	driver.process_mode = Node.PROCESS_MODE_ALWAYS
	root.add_child(driver)
	print("PACING %s %s seed=%d; move normally; first legal choices/free event are selected after UI guard" % [mode, hero, seed_value])

func fail(reason: String) -> void:
	printerr("PACING REJECT: " + reason)
	quit(2)

func step() -> void:
	if done: return
	if Time.get_ticks_msec() > deadline:
		finish("watchdog")
		return
	var run = app.run
	if not is_instance_valid(run): finish("unexpected_route"); return
	if run.phase != "active" or run.clock.tick >= 7260:
		finish("")
		return
	if mode == "Replay": apply_recorded_pauses(run)
	# Resolve only after a real modal has mounted, preserving 180ms input guard.
	if app.modal_host.get_child_count() > 0:
		var modal = app.modal_host.get_child(0)
		if Time.get_ticks_msec() >= modal.armed_at:
			if not run.choices.offer.is_empty():
				var selected = run.choices.offer[0]
				if mode == "Replay":
					if decision_index >= frozen.trace.decisions.size(): fail("missing frozen decision"); return
					var entry = frozen.trace.decisions[decision_index]
					if entry.tick != run.clock.tick or entry.offer != run.choices.offer_id: fail("decision divergence"); return
					selected = StringName(entry.upgrade)
					decision_index += 1
				if not run.choices.confirm(run, run.choices.offer_id, selected): fail("illegal choice"); return
			elif run.choices.event_token >= 0:
				var free = &"leave" if run.events.current.kind == "mysterious_merchant" else &"decline"
				if mode == "Replay":
					var recorded_events = frozen.trace.events.filter(func(entry): return entry.has("choice"))
					if replay_event_index >= recorded_events.size(): fail("missing frozen event choice"); return
					var entry = recorded_events[replay_event_index]
					if entry.tick != run.clock.tick or entry.id != run.events.current.id: fail("event decision divergence"); return
					free = StringName(entry.choice)
					replay_event_index += 1
				if not run.choices.resolve_event(run, run.events.current.id, free): fail("frozen/free event rejected"); return
	if Engine.time_scale != 1.0 or run.hero.health.debug_invincible or run.hero.health.debug_god_mode or app.writer.store.root.contains("developer") or (mode=="Record" and app.debug_panel.overlay.visible):
		finish("developer_intervention"); return
	if run.pause.is_blocked(): return
	direction = PlayerController.read_movement_actions()
	if mode == "Replay":
		while movement_index < frozen.trace.inputs.size() and frozen.trace.inputs[movement_index].tick <= run.clock.tick:
			var entry = frozen.trace.inputs[movement_index]
			direction = Vector2(entry.direction[0], entry.direction[1])
			movement_index += 1
		if movement_index > 0:
			var entry = frozen.trace.inputs[movement_index-1]
			direction = Vector2(entry.direction[0], entry.direction[1])
		else: direction = Vector2.ZERO
	run.simulation.advance(run, direction)
	run.camera.position = run.hero.position.round()

func apply_recorded_pauses(run) -> void:
	if replay_pause_index >= frozen.pauses.size(): return
	var entry = frozen.pauses[replay_pause_index]
	if entry.tick != run.clock.tick or entry.stage != run.simulation.stage: return
	var expected = {}
	for identity in entry.tokens:
		var token = entry.tokens[identity]
		if token.reason not in ["level","event","rescue"]: expected[str(identity)] = token
	for identity in replay_owned_tokens.keys():
		if not expected.has(identity):
			var owned = replay_owned_tokens[identity]
			run.pause.release(owned.id,owned.owner)
			replay_owned_tokens.erase(identity)
	for identity in expected:
		if not replay_owned_tokens.has(identity):
			var token = expected[identity]
			replay_owned_tokens[identity] = {"id":run.pause.acquire(token.reason,token.owner),"owner":token.owner}
	replay_pause_index += 1

func finish(reason: String) -> void:
	if done: return
	done = true
	var result = observer.complete_report(terminal_report)
	result["metadata"] = metadata
	if is_instance_valid(app.run):
		result["audio_diagnostics"] = {"accepted":app.run.combat_audio.allocator.accepted,"dropped":app.run.combat_audio.allocator.dropped,"stolen":app.run.combat_audio.allocator.stolen,"active":app.run.combat_audio.allocator.active_count()}
	if reason != "": result.failures.append(reason)
	if not error_capture.snapshot().is_empty(): result.failures.append("engine_errors")
	for choice in result.trace.decisions:
		var shown = result.trace.offers.filter(func(offer): return offer.id == choice.offer)
		if shown.is_empty() or choice.upgrade != shown[0].options[0]: result.failures.append("choice_protocol_not_first_legal")
	if fixture_mode != "US1":
		for pair in [["rush",2700],["shot",4500]]:
			if result.first[pair[0]] < 0: result.failures.append(pair[0]+"_missing")
			elif result.first[pair[0]] >= pair[1]: result.failures.append(pair[0]+"_late")
	if mode == "Replay":
		if replay_pause_index != frozen.pauses.size(): result.failures.append("unconsumed_pause_actions")
		var differences = Observer.differences(frozen.trace, JSON.parse_string(JSON.stringify(result.trace,"",false,true)), "trace")
		differences.append_array(Observer.differences(frozen.final, JSON.parse_string(JSON.stringify(result.final,"",false,true)), "final"))
		result["gameplay_differences"] = differences
		result["gameplay_equal"] = differences.is_empty()
		if not result.gameplay_equal: result.failures.append("gameplay_divergence")
	var file = FileAccess.open(output, FileAccess.WRITE)
	if file == null: quit(1); return
	file.store_string(JSON.stringify(result, "\t", false, true))
	file.close()
	print("PACING saved " + output + " failures=" + str(result.failures))
	app.leave_run()
	app.free()
	paused = false
	OS.remove_logger(error_capture)
	quit(0 if result.failures.is_empty() else 1)
