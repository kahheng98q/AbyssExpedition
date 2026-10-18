extends SceneTree

var failures: int = 0
var error_capture = preload("res://tests/error_capture.gd").new()

func _initialize() -> void:
	OS.add_logger(error_capture)
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func capture(app, name_value: String) -> void:
	await process_frame
	await process_frame
	for host in [app.modal_host, app.screen_host]:
		if host.get_child_count() == 0: continue
		var screen = host.get_child(0)
		if screen.get("panel") != null:
			check(screen.panel.size.x <= 640 and screen.panel.size.y <= 360, "panel fits viewport: " + name_value + str(screen.panel.size))
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("res://screenshots/m4-" + name_value + ".png") == OK, "capture " + name_value)

func force_event(app, kind: String) -> void:
	app.run.events.current = {"id": 99, "tick": app.run.clock.tick, "kind": kind}
	app.run.choices.event_token = app.run.pause.acquire("event", "event-choice")
	app.show_event(app.generation)

func choose(app, id: StringName) -> void:
	var screen = app.modal_host.get_child(0)
	screen.armed_at = 0
	screen.release_required = false
	screen.resolve(id)
	await process_frame
	await process_frame

func run() -> void:
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(1371, 813)]:
		DisplayServer.window_set_size(dimensions)
		var location = "user://tests/m4-graphical-%d-%d/" % [dimensions.x, Time.get_ticks_usec()]
		var app = load("res://scenes/app/app.tscn").instantiate()
		app.writer = SaveCoordinator.new(location)
		root.add_child(app)
		current_scene = app
		await capture(app, "guild-" + str(dimensions.x))
		app.mount_run(RunStartSnapshot.new(101, &"aren"))
		app.run.set_physics_process(false)
		for threshold in [0, 25, 50, 75, 100]:
			app.run.corruption.add(threshold - app.run.corruption.value)
			for i in range(5): app.run.spawn_enemy(StringName(ContentCatalog.ENEMIES[i]), app.run.hero.position + Vector2(-120 + i * 60, 65))
			app.run.state_changed.emit()
			await capture(app, "corruption-%d-%d" % [threshold, dimensions.x])
		var info = InputEventKey.new()
		info.keycode = KEY_C
		info.pressed = true
		app._unhandled_key_input(info)
		await capture(app, "thresholds-" + str(dimensions.x))
		var summary_screen = app.modal_host.get_child(0)
		var escape = InputEventKey.new()
		escape.keycode = KEY_ESCAPE
		escape.pressed = true
		summary_screen.armed_at = Time.get_ticks_msec() + 180
		summary_screen._unhandled_key_input(escape)
		check(app.run.pause.is_blocked(), "early Escape cannot leak summary pause")
		summary_screen.armed_at = 0
		summary_screen._unhandled_key_input(escape)
		check(not app.run.pause.is_blocked(), "Escape closes summary and releases owned token")
		force_event(app, "forbidden_altar")
		await capture(app, "altar-cap-disabled-" + str(dimensions.x))
		var screen = app.modal_host.get_child(0)
		screen.armed_at = 0
		screen.release_required = true
		screen.resolve(&"decline")
		check(not app.run.events.current.is_empty(), "held confirmation cannot choose next modal")
		await choose(app, &"decline")
		check(app.run.corruption.value == 100, "decline preserves cap")
		app.run.corruption.value = 0
		app.run.hero.health.current = 50
		force_event(app, "forbidden_altar")
		await capture(app, "altar-health-disabled-" + str(dimensions.x))
		await choose(app, &"unbound_assault")
		check(app.run.corruption.value == 35, "graphical assault applies exact cost")
		app.run.hero.health.current = 200
		force_event(app, "forbidden_altar")
		await capture(app, "altar-enabled-" + str(dimensions.x))
		await choose(app, &"blood_tithe")
		check(app.run.hero.health.current == 150 and app.run.corruption.value == 60, "graphical tithe applies HP and corruption together")
		force_event(app, "mysterious_merchant")
		await capture(app, "merchant-disabled-" + str(dimensions.x))
		await choose(app, &"leave")
		app.run.coins = 50
		force_event(app, "mysterious_merchant")
		await capture(app, "merchant-funded-" + str(dimensions.x))
		await choose(app, &"heal")
		check(app.run.coins == 30 and app.run.hero.health.current == 212.5, "graphical merchant healing")
		force_event(app, "mysterious_merchant")
		await choose(app, &"might")
		check(app.run.coins == 0, "graphical merchant Might")
		app.run.clock.tick = 14400
		app.run.simulation.stage = 3
		app.run.simulation.advance(app.run, Vector2.ZERO)
		await capture(app, "rescue-" + str(dimensions.x))
		app.run.choices.resolve_rescue(app.run, true)
		for i in range(1800): app.run.rescue.advance(app.run.hero.position, true)
		await process_frame
		app.run.clock.tick = 32445
		app.run.corruption.add(100 - app.run.corruption.value)
		var boss = app.run.spawn_enemy(&"tidebound_hierophant", Vector2(600, 270), -1, true)
		boss.deadline = 0
		BossController.decide(boss, app.run, 32445)
		app.run.state_changed.emit()
		await capture(app, "boss-cone-" + str(dimensions.x))
		boss.ai_state = "recovery"
		boss.deadline = 0
		BossController.decide(boss, app.run, 32445)
		await capture(app, "boss-double-eruption-" + str(dimensions.x))
		check(app.run.boss_hits.size() == 3, "cone plus two committed eruption warnings")
		app.run.queue_hit(boss, 100000, Vector2.ZERO, 0, false, false)
		app.run.simulation.stage = 1
		app.run.simulation.advance(app.run, Vector2.ZERO)
		await process_frame
		await capture(app, "chapter-saved-" + str(dimensions.x))
		check(app.writer.payload.chapters.coast and app.writer.payload.owned.has("sera"), "boss defeat persists chapter and rescue")
		app.show_guild()
		await capture(app, "guild-completed-" + str(dimensions.x))
		app.mount_run(RunStartSnapshot.new(101, &"aren"))
		app.run.set_physics_process(false)
		check(app.run.corruption.value == 0 and app.run.coins == 0 and app.run.hero.contract_bonuses.is_empty() and app.run.boss_actor == null, "repeat chapter resets all temporary state and requires another boss")
		app.free()
		paused = false
		await process_frame
		var writer = SaveCoordinator.new(location)
		check(writer.open() and writer.payload.chapters.coast, "graphical close/reopen keeps chapter")
		writer.close()
		print("GRAPHICAL M4 window=%s thresholds/contracts/rescue/boss/chapter/retry/reopen" % dimensions)
	for error in error_capture.snapshot(): check(false, "M4 runtime: " + error)
	OS.remove_logger(error_capture)
	print("GRAPHICAL M4: failures=%d" % failures)
	quit(0 if failures == 0 else 1)
