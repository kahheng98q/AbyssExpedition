extends SceneTree

# Controlled real-renderer comparison. No App or player profile is opened.
const Fixture = preload("res://tests/fixtures/run_fixture.gd")
var label: String = "after"
var errors = preload("res://tests/error_capture.gd").new()
var failures: int = 0

func _initialize() -> void:
	ProfileStore.test_mode = true
	OS.add_logger(errors)
	if not OS.get_cmdline_user_args().is_empty(): label = OS.get_cmdline_user_args()[0]
	if label == "before" and FileAccess.file_exists("res://screenshots/quality-20261018/before-aren-combat.png"):
		printerr("Historical before captures already exist; use a new iteration label.")
		quit(2)
		return
	call_deferred("run_capture")

func capture(name_value: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var path = "res://screenshots/quality-20261018/%s-%s.png" % [label, name_value]
	if root.get_texture().get_image().save_png(path) != OK: failures += 1
	print("CAPTURE ", path)

func run_capture() -> void:
	for action in ["move_right", "move_down", "move_left", "move_up"]:
		if not InputMap.has_action(action): InputMap.add_action(action)
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute("res://screenshots/quality-20261018")
	for hero_id in [&"aren", &"lia", &"milo"]:
		var f = Fixture.create(self, hero_id, 101)
		var run = f.run
		for i in range(18):
			var point = run.hero.position + Vector2.from_angle(i * TAU / 18.0) * (105 + (i % 3) * 34)
			run.spawn_enemy(StringName(ContentCatalog.ENEMIES[i % 5]), point)
		run.spawn_enemy(&"saltbound_thrall", run.hero.position + Vector2(32, 8))
		for i in range(5):
			await physics_frame
			run.simulation.advance(run, Vector2.ZERO)
		await capture(String(hero_id) + "-combat")
		# Drive the real InputMap, movement and automatic attacks for 12 active seconds.
		for i in range(720):
			await physics_frame
			var action = ["move_right", "move_down", "move_left", "move_up"][int(i / 180.0)]
			Input.action_press(action)
			run.simulation.advance(run, PlayerController.read_movement_actions())
			Input.action_release(action)
			if not run.choices.offer.is_empty():
				run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
			run.camera.position = run.hero.position.round()
		await capture(String(hero_id) + "-moving")
		print("QUALITY STATE %s tick=%d kills=%d hp=%.3f position=%s level=%d xp=%d" % [hero_id, run.clock.tick, run.kills, run.hero.health.current, run.hero.position, run.progression.level, run.progression.xp])
		Fixture.dispose(f)
		await process_frame
	var f = Fixture.create(self)
	var run = f.run
	run.clock.tick = 32445
	run.corruption.add(100)
	var boss = run.spawn_enemy(&"tidebound_hierophant", run.hero.position + Vector2(100, 30), -1, true)
	boss.deadline = 0
	BossController.decide(boss, run, run.clock.tick)
	run.state_changed.emit()
	await capture("boss-warning")
	Fixture.dispose(f)
	for error in errors.snapshot():
		printerr(error)
		failures += 1
	OS.remove_logger(errors)
	print("QUALITY CAPTURE failures=", failures)
	quit(0 if failures == 0 else 1)
