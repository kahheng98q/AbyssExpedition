extends SceneTree

class ErrorCapture:
	extends Logger
	
	var mutex: Mutex = Mutex.new()
	var errors: Array[String] = []
	
	func _log_error(_function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		if error_type == Logger.ERROR_TYPE_WARNING: return
		mutex.lock()
		errors.append("%s:%d %s %s" % [file, line, code, rationale])
		mutex.unlock()
	
	func snapshot() -> Array[String]:
		mutex.lock()
		var result = errors.duplicate()
		mutex.unlock()
		return result
	

var failures: int = 0
var error_capture = ErrorCapture.new()

func _initialize() -> void:
	OS.add_logger(error_capture)
	call_deferred("run")

func capture(name_value: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	if root.get_texture().get_image().save_png("C:/Users/kahhe/Desktop/Project/new-game-project/screenshots/quality-20261018/release-m2-" + name_value + ".png") != OK: failures += 1

func layout(screen, name_value: String) -> void:
	await process_frame
	if screen.panel.size.y > 360 or screen.panel.size.x > 640:
		printerr("FAIL: panel exceeds logical viewport: " + name_value + " " + str(screen.panel.size))
		failures += 1

func run() -> void:
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/m2-graphical-%d/" % Time.get_ticks_usec())
	root.add_child(app)
	current_scene = app
	var p = ProfileData.fresh()
	p.promotion_items = 3
	p.companions = ["lia", "milo"]
	for id in p.owned: p.owned[id] = OwnedHero.record(id, 1400)
	if not app.writer.mutate(p, app.writer.revision(), "graphical-fixture"): failures += 1
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(1371, 813)]:
		DisplayServer.window_set_size(dimensions)
		app.show_selection()
		await layout(app.screen_host.get_child(0), "selection")
		await capture("selection-" + str(dimensions.x))
		app.show_roster()
		await layout(app.screen_host.get_child(0), "roster")
		await capture("roster-" + str(dimensions.x))
		for id in ["aren", "lia", "milo"]:
			app.show_promotion(id)
			await layout(app.screen_host.get_child(0), "promotion-" + id)
			await capture("promotion-" + id + "-" + str(dimensions.x))
		app.leave_run()
		app.clear_host(app.screen_host)
		for branch in ProfileData.BRANCHES:
			var profile = p.duplicate(true)
			var id = "aren" if ProfileData.BRANCHES[branch] == "swordsman" else ("lia" if ProfileData.BRANCHES[branch] == "archer" else "milo")
			profile.active = id
			profile.companions = ProfileData.STARTERS.filter(func(other): return other != id)
			profile.owned[id] = OwnedHero.record(id, 1400, branch)
			if not app.writer.mutate(profile, app.writer.revision(), app.writer.operation_id(), {"kind": "graphical-fixture"}): failures += 1
			app.show_roster()
			await layout(app.screen_host.get_child(0), "promoted-roster-" + branch)
			await capture("promoted-roster-" + branch + "-" + str(dimensions.x))
			app.clear_host(app.screen_host)
			var expedition = app.catalog.scene("expedition").instantiate()
			app.expedition_host.add_child(expedition)
			expedition.set_physics_process(false)
			expedition.start(app.catalog, RosterService.snapshot(profile, 101))
			expedition.clock.tick = 240
			var enemy = expedition.spawn_enemy(&"saltbound_thrall", expedition.hero.position + Vector2(30, 0))
			enemy.health = ActorHealth.new(1000)
			expedition.hero.activations = 4
			expedition.hero.passive_activations = 4
			AttackExecutor.try_activate(expedition.hero, expedition, 240)
			if expedition.projectiles.get_child_count() > 0:
				var shot = expedition.projectiles.get_child(0)
				shot.position = enemy.position - Vector2(1, 0)
				shot.simulate(241)
			expedition.state_changed.emit()
			await capture(branch + "-" + str(dimensions.x))
			expedition.party[1].health.dead = true
			expedition.state_changed.emit()
			await capture(branch + "-downed-" + str(dimensions.x))
			expedition.free()
		app.show_roster()
		var capped = p.duplicate(true)
		capped.owned.aren = OwnedHero.record("aren", 2850)
		capped.owned.lia = OwnedHero.record("lia", 2900)
		if not app.writer.mutate(capped, app.writer.revision(), app.writer.operation_id()): failures += 1
		app.mount_run(RunStartSnapshot.new(101, &"aren"))
		app.run.set_physics_process(false)
		app.run.clock.tick = 3600
		app.run.finish("victory")
		await process_frame
		await layout(app.screen_host.get_child(0), "three-member cap result")
		await capture("cap-results-" + str(dimensions.x))
		print("GRAPHICAL M2 window=%s actual=%s roster / 3 visual previews / 6 branch combat / followers / downing / actual XP caps" % [dimensions, DisplayServer.window_get_size()])
	app.free()
	await process_frame
	paused = false
	for error in error_capture.snapshot():
		printerr("FAIL: graphical runtime error " + error)
		failures += 1
	OS.remove_logger(error_capture)
	print("GRAPHICAL M2: failures=%d" % failures)
	quit(0 if failures == 0 else 1)
