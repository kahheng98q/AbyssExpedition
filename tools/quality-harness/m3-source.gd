extends SceneTree

var failures: int = 0
var error_capture = preload("res://tests/error_capture.gd").new()

class OnceFault:
	extends RefCounted
	var remaining: int = 1
	func fail(stage: String) -> bool:
		if stage != "readback" or remaining <= 0: return false
		remaining -= 1
		return true

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
	var host = app.modal_host if app.modal_host.get_child_count() > 0 else app.screen_host
	if host.get_child_count() > 0:
		var screen = host.get_child(0)
		if screen.get("panel") != null:
			check(screen.panel.size.x <= 640 and screen.panel.size.y <= 360, "M3 panel fits viewport: " + name_value + " " + str(screen.panel.size))
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("C:/Users/kahhe/Desktop/Project/new-game-project/screenshots/quality-20261018/source-m3-" + name_value + ".png") == OK, "capture " + name_value)

func press(app, prefix: String) -> void:
	var screen = app.screen_host.get_child(0)
	screen.armed_at = 0
	for child in screen.column.get_children():
		if child is Button and child.text.begins_with(prefix):
			check(not child.disabled, "button enabled: " + prefix)
			child.pressed.emit()
			await process_frame
			await process_frame
			return
	check(false, "button missing: " + prefix)

func run() -> void:
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(1371, 813)]:
		DisplayServer.window_set_size(dimensions)
		var location = "user://tests/m3-graphical-%d-%d/" % [dimensions.x, Time.get_ticks_usec()]
		var app = load("res://scenes/app/app.tscn").instantiate()
		app.writer = SaveCoordinator.new(location)
		root.add_child(app)
		current_scene = app
		await capture(app, "guild-fresh-" + str(dimensions.x))
		app.show_recruitment()
		await capture(app, "odds-empty-" + str(dimensions.x))
		app.show_selection()
		app.mount_run(RunStartSnapshot.new(101, &"aren"))
		app.run.set_physics_process(false)
		app.run.clock.tick = 14400
		app.run.simulation.stage = 3
		app.run.simulation.advance(app.run, Vector2.ZERO)
		await capture(app, "rescue-offer-" + str(dimensions.x))
		check(app.run.pause.is_blocked(), "rescue offer freezes world")
		app.run.choices.resolve_rescue(app.run, true)
		app.run.rescue.elapsed = 900
		app.run.state_changed.emit()
		await capture(app, "rescue-zone-" + str(dimensions.x))
		for i in range(900): app.run.rescue.advance(app.run.hero.position, true)
		app.run.clock.tick = 18000
		app.run.state_changed.emit()
		await capture(app, "rescue-success-" + str(dimensions.x))
		app.run.finish("defeat")
		await process_frame
		await capture(app, "rescue-settled-" + str(dimensions.x))
		check(app.writer.payload.owned.has("sera") and app.writer.payload.tickets == 1, "defeat persists earned rescue and five-minute ticket")
		var funded = app.writer.payload.duplicate(true)
		funded.tickets = 21
		funded.tokens = 5
		funded.draw_rng = DrawRng.initial("20261015")
		check(app.writer.mutate(funded, app.writer.revision(), app.writer.operation_id()), "controlled recruitment fixture")
		app.show_recruitment()
		await press(app, "Recruit Brann")
		await capture(app, "exchange-confirm-" + str(dimensions.x))
		var revision = app.writer.revision()
		await press(app, "Cancel")
		check(app.writer.revision() == revision and app.writer.payload.tokens == 5, "cancel exchange spends nothing")
		await press(app, "Recruit Brann")
		await press(app, "Confirm")
		check(app.writer.payload.owned.has("brann") and app.writer.payload.tokens == 0, "UI exchange commits five tokens and ownership")
		await press(app, "Single pull")
		await press(app, "Confirm")
		await capture(app, "single-reveal-" + str(dimensions.x))
		await press(app, "Continue")
		await press(app, "Ten pull")
		await capture(app, "ten-confirm-" + str(dimensions.x))
		await press(app, "Confirm")
		await capture(app, "ten-reveal-" + str(dimensions.x))
		var receipt = RecruitmentHistory.awaiting(app.writer.payload)
		check(receipt.results.size() == 10 and app.writer.payload.tickets == 10, "ten ordered UI outcomes and exact cost")
		var screen = app.screen_host.get_child(0)
		var scroll = screen.column.get_parent()
		scroll.scroll_vertical = 10000
		await capture(app, "ten-reveal-bottom-" + str(dimensions.x))
		app.writer.close()
		app.writer = SaveCoordinator.new(location)
		check(app.writer.open(), "graphical reopen")
		app.show_guild()
		check(RecruitmentHistory.awaiting(app.writer.payload) == receipt, "graphical reopen preserves original results")
		await capture(app, "reopened-reveal-" + str(dimensions.x))
		await press(app, "Continue")
		await press(app, "View saved history")
		await capture(app, "history-" + str(dimensions.x))
		app.show_guild()
		await capture(app, "guild-collected-" + str(dimensions.x))
		app.writer.store.fault = OnceFault.new()
		app.show_recruitment()
		await press(app, "Single pull")
		await press(app, "Confirm")
		check(app.writer.state == "save-blocked" and app.writer.payload.tickets == 10, "failed UI draw keeps prior balance and blocks reveal")
		await capture(app, "draw-save-blocked-" + str(dimensions.x))
		await press(app, "Retry pending action")
		check(app.writer.state == "ready" and app.writer.payload.tickets == 9, "UI Retry commits same pending draw once")
		await capture(app, "draw-retry-reveal-" + str(dimensions.x))
		await press(app, "Continue")
		app.show_roster()
		await capture(app, "roster-six-" + str(dimensions.x))
		app.show_selection()
		await capture(app, "selection-six-" + str(dimensions.x))
		print("GRAPHICAL M3 window=%s actual=%s guild / rescue / settlement / single+ten / cancel+exchange / reopen / history / collection" % [dimensions, DisplayServer.window_get_size()])
		app.free()
		await process_frame
		paused = false
	for error in error_capture.snapshot(): check(false, "M3 graphical runtime: " + error)
	OS.remove_logger(error_capture)
	print("GRAPHICAL M3: failures=%d" % failures)
	quit(0 if failures == 0 else 1)
