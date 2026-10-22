extends SceneTree

# Real time only. This harness never replaces now_usec, forces ticks or uses fixed FPS.
var failures: int = 0
var assertions: int = 0
var output: String
var host_mode: String
var kind: String
var speed: int = 1
var deadline: int
var report: Dictionary = {}
var errors = preload("res://tests/error_capture.gd").new()

func _initialize() -> void:
	ProfileStore.test_mode = true
	OS.add_logger(errors)
	deadline = Time.get_ticks_usec() + 150000000
	call_deferred("run_check")

func check(value: bool, message: String) -> void:
	assertions += 1
	if not value: failures += 1; printerr("FAIL: " + message)

func profile_bytes(writer) -> Dictionary:
	var result = {}
	for generation in writer.store.generations(): result[generation.path] = writer.store.read(generation.path)
	return result

func gameplay(app) -> Dictionary:
	if not is_instance_valid(app.run): return {}
	var run = app.run
	var result = {"tick": run.clock.tick, "phase": run.phase, "level": run.progression.level, "xp": run.progression.xp, "stacks": run.progression.stacks.duplicate(true), "party": [], "rng": {}}
	for member in run.party: result.party.append({"id": member.actor_id, "position": Vector2(member.position), "hp": member.health.current, "dead": member.health.dead, "activations": member.activations, "passive": member.passive_activations, "next_ready": member.next_ready})
	for label in SeedStreams.LABELS: result.rng[label] = str(run.rng.stream(label).state)
	return result

func open_page(app):
	if host_mode == "dev":
		app.debug_panel.open_promotion(false)
		return app.debug_panel.promotion_host.get_child(0)
	app.show_promotion("aren")
	return app.screen_host.get_child(0)

func close_page(page) -> void:
	page.cancel()
	await process_frame
	await process_frame

func save_report() -> void:
	report["assertions"] = assertions
	report["failures"] = failures
	report["status"] = "passed" if failures == 0 and report.get("completed", false) else "partial_or_failed"
	var file = FileAccess.open(output.path_join("realtime.json"), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "", true, true))
		file.close()

func finish(app) -> void:
	for error in errors.snapshot(): check(false, error)
	OS.remove_logger(errors)
	if is_instance_valid(app): app.free()
	paused = false
	report["engine_scale_after_cleanup"] = Engine.time_scale
	save_report()
	print("SWORD REALTIME %s %s %dx: assertions=%d failures=%d completed=%s" % [kind, host_mode, speed, assertions, failures, report.get("completed", false)])
	quit(0 if failures == 0 and report.get("completed", false) else 1)

func run_check() -> void:
	var options = {}
	var args = OS.get_cmdline_user_args()
	if args.size() % 2 != 0: quit(2); return
	for i in range(0, args.size(), 2):
		if args[i] not in ["--host", "--speed", "--kind", "--output"] or options.has(args[i]): quit(2); return
		options[args[i]] = args[i+1]
	host_mode = options.get("--host", "")
	kind = options.get("--kind", "")
	output = options.get("--output", "")
	if host_mode not in ["normal", "dev"] or kind not in ["source", "debug", "release"] or options.get("--speed", "") not in ["1", "2", "4"] or output == "": quit(2); return
	speed = int(options["--speed"])
	if DisplayServer.get_name() == "headless" or (kind == "release" and (OS.has_feature("debug") or host_mode != "normal" or speed != 1)) or (kind != "release" and not OS.has_feature("debug")): quit(2); return
	if "--fixed-fps" in OS.get_cmdline_args(): quit(2); return
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	root.grab_focus()
	var app = load("res://scenes/app/app.tscn").instantiate()
	var storage = "user://tests/preview-realtime-%s/" % output.sha256_text().substr(0, 24)
	if DirAccess.dir_exists_absolute(storage): printerr("FAIL: realtime profile already exists"); quit(2); return
	app.writer = SaveCoordinator.new(storage)
	root.add_child(app)
	var profile = ProfileData.fresh()
	profile.owned.aren = OwnedHero.record("aren", 1400)

	check(app.writer.mutate(profile, app.writer.revision(), "realtime-eligibility"), "independent level15 profile prepared")
	var normal = app.writer
	var normal_saved = profile_bytes(normal)
	if host_mode == "dev":
		app.mount_saved_run(101)
		check(app.debug_panel.open_panel(), "real DEV service establishes isolated session and pause")
		check(app.debug_panel.service.execute("speed", {"speed": speed}).ok, "existing DEV speed selected")
	else:
		check(speed == 1, "ordinary release/menu uses normal speed")
	var owner = app.writer
	var saved = profile_bytes(owner)
	var payload = owner.payload.duplicate(true)
	var revision = owner.revision()
	var page = open_page(app)
	await process_frame
	await process_frame
	check(DisplayServer.window_get_size() == Vector2i(1920, 1080), "actual 1920x1080 window")
	for visual in page.branch_previews.values(): check(visual.now_usec == Time.get_ticks_usec, "unmodified production monotonic clock")
	# Actual native focus transfer, not an injected focus flag.
	var embedded = root.gui_embed_subwindows
	root.gui_embed_subwindows = false
	var probe = Window.new()
	probe.title = "Abyss preview focus check"
	probe.size = Vector2i(96, 64)
	probe.position = root.position + Vector2i(20, 20)
	root.add_child(probe)
	probe.show()
	probe.grab_focus()
	var focus_deadline = Time.get_ticks_usec() + 2000000
	while root.has_focus() and Time.get_ticks_usec() < focus_deadline: await process_frame
	var frozen: Array = []
	for visual in page.branch_previews.values(): frozen.append(visual.total_ticks)
	var wait_until = Time.get_ticks_usec() + 250000
	while Time.get_ticks_usec() < wait_until: await process_frame
	var index = 0
	for visual in page.branch_previews.values():
		check(not visual.focused and visual.total_ticks == frozen[index], "real focus loss freezes sample")
		index += 1
	probe.hide()
	probe.queue_free()
	root.gui_embed_subwindows = embedded
	root.grab_focus()
	await process_frame
	await process_frame
	check(root.has_focus(), "real focus returns to owning Window")
	await close_page(page)
	page = open_page(app) # fresh sessions for ten uninterrupted full real cycles
	await process_frame
	var real_game = gameplay(app)
	var audio_count: int = app.run.combat_audio.allocator.accepted if is_instance_valid(app.run) else 0
	report = {"kind": kind, "host": host_mode, "speed": speed, "engine": Engine.get_version_info().string, "debug_build": OS.has_feature("debug"), "window": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y], "clock": "Time.get_ticks_usec; never injected", "engine_scale_observed": Engine.time_scale, "internal_wall_deadline_seconds": 150, "external_wall_deadline_seconds": 180, "cycles": {}, "opens": 0, "unfocused_frames": 0, "completed": false, "human_acceptance": false}
	save_report()
	if failures > 0: finish(app); return
	var started = Time.get_ticks_usec()
	var screenshot_saved = false
	var prior_cycles = -1
	while true:
		if Time.get_ticks_usec() >= deadline:
			check(false, "internal150 wall deadline reached; partial cycles retained")
			finish(app)
			return
		var complete = true
		for visual in page.branch_previews.values():
			complete = complete and visual.cycle_count >= 10
			if visual.cycle_count == 0 and visual.total_ticks == 1: check(visual.now_usec == Time.get_ticks_usec, "clock stays production")
		if not root.has_focus(): report.unfocused_frames += 1
		var spectral = page.branch_previews[&"abyss_swordsman"]
		if not screenshot_saved and not spectral.heal_record.is_empty() and spectral.tick < 280:
			await RenderingServer.frame_post_draw
			check(root.get_texture().get_image().save_png(output.path_join("preview.png")) == OK, "real fifth-effect frame saved")
			screenshot_saved = true
		var current_cycles: int = page.branch_previews[&"swordmaster"].cycle_count
		if current_cycles != prior_cycles:
			prior_cycles = current_cycles
			for key in page.branch_previews: report.cycles[String(key)] = page.branch_previews[key].cycle_playback_usec.duplicate()
			report["wall_seconds"] = (Time.get_ticks_usec() - started) / 1000000.0
			save_report()
		if complete: break
		await process_frame
	for key in page.branch_previews:
		var visual = page.branch_previews[key]
		check(visual.cycle_playback_usec.size() >= 10 and visual.cycle_count >= 10, "ten full real cycles " + String(key))
		var prior = 0
		var durations: Array = []
		for ending in visual.cycle_playback_usec.slice(0, 10):
			var duration: int = ending - prior
			check(duration >= 5900000 and duration <= 8000000, "real effective cycle is six seconds and no more than eight")
			durations.append(duration)
			prior = ending
		report.cycles[String(key)] = {"end_active_usec": visual.cycle_playback_usec.duplicate(), "duration_usec": durations, "count": visual.cycle_count}
	check(Time.get_ticks_usec() - started >= 59000000, "ten cycles were not fixed-FPS accelerated")
	check(profile_bytes(owner) == saved and owner.payload == payload and owner.revision() == revision and profile_bytes(normal) == normal_saved, "real viewing leaves established sandbox/normal profile bytes unchanged")
	check(gameplay(app) == real_game, "real preview never advances game HP/counts/RNG")
	if is_instance_valid(app.run): check(app.run.combat_audio.allocator.accepted == audio_count, "no real combat audio facts from examples")
	await close_page(page)
	for opening in range(10):
		var transient = open_page(app)
		var reference = weakref(transient.branch_previews[&"swordmaster"])
		await process_frame
		await close_page(transient)
		check(reference.get_ref() == null, "real page clear frees example callbacks")
		report.opens = opening + 1
	check(profile_bytes(owner) == saved and owner.revision() == revision and profile_bytes(normal) == normal_saved, "ten real opens/cancels preserve all save bytes")
	report["completed"] = true
	report["wall_seconds"] = (Time.get_ticks_usec() - started) / 1000000.0
	var drain = Time.get_ticks_usec() + 250000
	while Time.get_ticks_usec() < drain: await process_frame
	finish(app)
