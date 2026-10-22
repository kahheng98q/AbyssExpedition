extends RefCounted

const Observer = preload("res://tests/fixtures/pacing_observer.gd")

func bytes(writer) -> Dictionary:
	var result = {}
	for record in writer.store.generations(): result[record.path] = writer.store.read(record.path)
	return result

func install_clock(page) -> Array:
	var clock = [0]
	for visual in page.branch_previews.values():
		visual.set("now_usec", func(): return clock[0])
		visual.call("_on_window_focus_entered")
		visual.call("_process", 0.0)
	return clock

func advance(page, clock: Array, microseconds: int) -> void:
	clock[0] += microseconds
	for visual in page.branch_previews.values(): visual.call("_process", 0.0)

func create_app(t):
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/promotion-preview-%d/" % Time.get_ticks_usec())
	t.root.add_child(app)
	var profile = ProfileData.fresh()
	profile.owned.aren = OwnedHero.record("aren", 1400)

	t.check(app.writer.mutate(profile, app.writer.revision(), "preview-fixture"), "isolated promotion profile")
	app.mount_saved_run(101)
	app.run.set_physics_process(false)
	return app

func run(t) -> void:
	var available = FileAccess.file_exists("res://scripts/ui/promotion_preview.gd")
	t.check(available, "promotion uses independent clock-driven sword example sessions")
	if not available: return
	var app = create_app(t)
	var normal = app.writer
	var saved = bytes(normal)
	var payload = normal.payload.duplicate(true)
	var revision = normal.revision()
	var observer = Observer.new()
	observer.run = app.run
	var gameplay = observer.final_state()
	var resource_values = {}
	for id in app.catalog.professions: resource_values[id] = preload("res://tests/fixtures/sword_identity_session.gd").resource_state(app.catalog.professions[id])
	var audio_count: int = app.run.combat_audio.allocator.accepted
	var root_connections = t.root.focus_entered.get_connections().size()
	app.show_promotion("aren")
	var page = app.screen_host.get_child(0)
	t.check(page.branch_previews.size() == 2, "exactly two independent sword sessions")
	for visual in page.branch_previews.values():
		t.check(visual.get("now_usec") == Time.get_ticks_usec, "production default clock is actual monotonic microseconds")
		t.check(visual.get("configuration").is_read_only() and visual.get("sample_max_hp") == 250 and visual.get("sample_hp") == 240, "read-only base configuration and explicitly wounded sample")
		t.check(visual.get("focused") == t.root.has_focus(), "initial focus is read from owning Window")
		t.check(visual.process_mode == Node.PROCESS_MODE_ALWAYS and visual.mouse_filter == Control.MOUSE_FILTER_IGNORE, "paused host can render without consuming page inputs")
	var clock = install_clock(page)
	advance(page, clock, 4500000)
	var dual = page.branch_previews[&"swordmaster"]
	var spectral = page.branch_previews[&"abyss_swordsman"]
	t.check(dual.get("activation_count") == 5 and dual.get("arcs").size() == 3, "fifth sample has two blades plus full spin")
	t.check(spectral.get("sample_hp") == 240 and spectral.get("heal_record").is_empty(), "fifth activation is distinct from next-tick example hit")
	advance(page, clock, 16700)
	t.check(spectral.get("sample_hp") == 245 and spectral.get("heal_record").actual_heal == 5.0, "next tick shows clipped sample amount, independent of permanent stats")
	advance(page, clock, 1483300)
	t.check(dual.get("cycle_count") == 1 and spectral.get("cycle_count") == 1 and spectral.get("sample_hp") == 240 and spectral.get("arcs").is_empty() and spectral.get("heal_record").is_empty(), "six-second cycle resets owned example state")
	for ignored in range(9): advance(page, clock, 6000000)
	t.check(dual.get("cycle_count") == 10 and spectral.get("cycle_count") == 10, "injected same production state machine completes ten full cycles")
	var prior_scale = Engine.time_scale
	for speed in [1, 2, 4]:
		Engine.time_scale = speed
		t.paused = true
		var before: int = spectral.get("cycle_count")
		advance(page, clock, 6000000)
		t.check(spectral.get("cycle_count") == before + 1 and t.paused and app.run.clock.tick == 0, "six-second local clock ignores time scale and never unpauses game " + str(speed))
		t.paused = false
	Engine.time_scale = prior_scale
	for visual in page.branch_previews.values(): visual.call("_on_window_focus_exited")
	var tick: int = spectral.get("tick")
	advance(page, clock, 60000000)
	t.check(spectral.get("tick") == tick, "focus loss discards elapsed time")
	for visual in page.branch_previews.values(): visual.call("_on_window_focus_entered")
	advance(page, clock, 500000)
	t.check(spectral.get("tick") == 30, "focus recovery resumes without catch-up attacks")
	page.hide()
	advance(page, clock, 60000000)
	t.check(spectral.get("tick") == 30, "hidden page does not advance examples")
	page.show()
	advance(page, clock, 500000)
	t.check(spectral.get("tick") <= 60, "show never backfills hidden time")
	t.check(bytes(normal) == saved and normal.payload == payload and normal.revision() == revision, "ten cycles preserve exact committed profile bytes/revision/balances")
	t.check(observer.final_state() == gameplay and app.run.combat_audio.allocator.accepted == audio_count, "examples preserve all real HP/counters/RNG/later state and are silent")
	for id in app.catalog.professions: t.check(preload("res://tests/fixtures/sword_identity_session.gd").resource_state(app.catalog.professions[id]) == resource_values[id], "viewing cannot mutate shared profession/VisualSet configuration " + String(id))
	for ignored in range(10):
		app.show_promotion("aren")
		var closing = app.screen_host.get_child(0)
		var ref = weakref(closing.branch_previews[&"swordmaster"])
		closing.call("cancel")
		await t.process_frame
		t.check(ref.get_ref() == null, "cancel/parent clear destroys session and callbacks")
	t.check(bytes(normal) == saved and normal.revision() == revision and t.root.focus_entered.get_connections().size() == root_connections, "ten page opens preserve save bytes and bounded window subscriptions")
	app.free()
	t.paused = false
	await t.process_frame

func debug_hosts(t) -> void:
	var available = FileAccess.file_exists("res://scripts/ui/promotion_preview.gd")
	t.check(available, "DEV promotion shares independent sword preview component")
	if not available: return
	var app = create_app(t)
	var normal = app.writer
	var normal_saved = bytes(normal)
	app.show_promotion("aren")
	var page = app.screen_host.get_child(0)
	var clock = install_clock(page)
	var panel = app.debug_panel
	t.check(panel.open_panel(), "DEV establishes original isolated sandbox before preview baseline")
	var service = panel.service
	var sandbox = service.writer.payload.duplicate(true)
	var revision = service.writer.revision()
	advance(page, clock, 6000000)
	t.check(page.branch_previews[&"swordmaster"].get("tick") == 0, "ordinary page freezes under real DEV overlay")
	service.writer.state = "save-blocked"
	t.check(not panel.close_panel() and panel.overlay.visible, "original save protection rejects closing")
	advance(page, clock, 6000000)
	t.check(page.branch_previews[&"swordmaster"].get("tick") == 0, "rejected close leaves ordinary demo frozen")
	service.writer.state = "ready"
	panel.open_promotion(false)
	var debug_page = panel.promotion_host.get_child(0)
	var debug_clock = install_clock(debug_page)
	var game_tick: int = app.run.clock.tick
	for speed in [1, 2, 4]:
		t.check(service.execute("speed", {"speed": speed}).ok, "existing DEV speed action retained")
		for ignored in range(10): advance(debug_page, debug_clock, 6000000)
	t.check(debug_page.branch_previews[&"swordmaster"].get("cycle_count") == 30 and t.paused and app.run.clock.tick == game_tick, "DEV examples play while actual game remains paused at every speed")
	t.check(service.writer.payload == sandbox and service.writer.revision() == revision and bytes(normal) == normal_saved, "preview leaves established sandbox and original normal writer bytes unchanged")
	panel.clear_promotion()
	await t.process_frame
	t.check(panel.promotion_host.get_child_count() == 0, "DEV parent clear removes both examples")
	service.speed.reset()
	t.check(panel.close_panel(), "DEV closes with original service")
	advance(page, clock, 500000)
	t.check(page.branch_previews[&"swordmaster"].get("tick") <= 30 and app.debug_panel == panel, "normal example resumes without backlog and App keeps one DEV")
	app.free()
	t.paused = false
	await t.process_frame
