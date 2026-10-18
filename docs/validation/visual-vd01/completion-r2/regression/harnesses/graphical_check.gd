extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func capture(name_value: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var image = root.get_texture().get_image()
	var error = image.save_png("C:/Users/kahhe/Desktop/Project/new-game-project/docs/validation/visual-vd01/completion-r2/regression/captures/" + name_value + ".png")
	if error != OK: failures += 1

func run() -> void:
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/m1-regression-graphical-%d/" % Time.get_ticks_usec())
	root.add_child(app)
	current_scene = app
	await capture("graphical-menu")
	app.show_selection()
	await capture("graphical-selection")
	var index = 0
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(1371, 813)]:
		DisplayServer.window_set_size(dimensions)
		await process_frame
		print("GRAPHICAL window=%s actual=%s viewport=%s" % [dimensions, DisplayServer.window_get_size(), root.size])
		var hero_id = StringName(ContentCatalog.CHARACTERS[index])
		app.mount_run(RunStartSnapshot.new(0 if index == 0 else 2147483647, hero_id))
		var expedition = app.run
		expedition.set_physics_process(false)
		expedition.hero.health.current = 73
		expedition.clock.tick = 28800
		for i in range(5):
			var actor = expedition.spawn_enemy(StringName(ContentCatalog.ENEMIES[i]), expedition.hero.position + Vector2(-120 + i * 60, 65))
			actor.health.current = actor.health.maximum * 0.6
		expedition.create_warning(expedition.hero.position + Vector2(90, 20), "circle", 32, Vector2.RIGHT, 70, 28875)
		AttackExecutor.try_activate(expedition.hero, expedition, expedition.clock.tick)
		expedition.state_changed.emit()
		await capture("graphical-combat-" + str(index))
		expedition.progression.collect_xp(999, 650)
		expedition.choices.present(expedition)
		await process_frame
		await capture("graphical-choice-" + str(index))
		while not expedition.choices.offer.is_empty(): expedition.choices.confirm(expedition, expedition.choices.offer_id, expedition.choices.offer[0])
		await process_frame
		expedition.toggle_manual_pause()
		app.refresh_modal()
		await capture("graphical-pause-" + str(index))
		expedition.toggle_manual_pause()
		app.refresh_modal()
		expedition.clock.tick = 32400
		var boss = expedition.spawn_enemy(&"tidebound_hierophant", expedition.hero.position + Vector2(-60, 0), -1, true)
		boss.deadline = 32400
		BossController.decide(boss, expedition, 32400)
		expedition.state_changed.emit()
		await capture("graphical-boss-cone-" + str(index))
		boss.ai_state = "recovery"
		boss.deadline = 32400
		BossController.decide(boss, expedition, 32400)
		await capture("graphical-boss-circle-" + str(index))
		expedition.finish("victory")
		await process_frame
		await capture("graphical-results-" + str(index))
		index += 1
	print("GRAPHICAL: 3 sizes / 3 starters / menu selection combat choice pause boss patterns results; failures=%d" % failures)
	app.free()
	paused = false
	quit(0 if failures == 0 else 1)
