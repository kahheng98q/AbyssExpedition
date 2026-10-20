extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func capture(name_value: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var image = root.get_texture().get_image()
	var capture_path = "res://screenshots/" + name_value + ".png"
	var args = OS.get_cmdline_user_args()
	if args.has("--captures"):
		capture_path = args[args.find("--captures") + 1].path_join(name_value + ".png")
	var error = image.save_png(capture_path)
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
		app.mount_run(RunStartSnapshot.new([101,202,303][index], hero_id))
		var expedition = app.run
		expedition.set_physics_process(false)
		app.set_window_focused(true) # Controlled graphical fixture; physical focus separately manual.
		expedition.spawns.schedule_wave(expedition, 0)
		await process_frame
		await RenderingServer.frame_post_draw
		if expedition.spawns.reservations.size() != 4: failures += 1
		for slot in expedition.spawns.reservations:
			if not slot.warning.get_parent() is CanvasLayer or slot.warning.get_parent().layer <= expedition.get_node("HUD").layer: failures += 1
			var screen_point = slot.warning.get_global_transform_with_canvas().origin
			if not Rect2(13, 13, 614, 334).has_point(screen_point): failures += 1
		var opening_image=root.get_texture().get_image()
		for slot in expedition.spawns.reservations:
			var point=Vector2i(slot.warning.get_global_transform_with_canvas().origin.round())
			var orange=false
			for dx in range(-2,3):
				for dy in range(-2,3):
					var pixel=point+Vector2i(dx,dy)
					if not Rect2i(Vector2i.ZERO,opening_image.get_size()).has_point(pixel): continue
					var color=opening_image.get_pixelv(pixel)
					if color.r>0.85 and color.g>0.6 and color.b<0.5: orange=true
			if not orange:
				failures+=1
				printerr("FAIL: opening warning cross occluded at "+str(point))
		await capture("graphical-opening-" + str(index))
		expedition.spawns.simulate(expedition, 45)
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
	# Let the native mixer retire stopped playbacks before process shutdown.
	var mixer_cleanup_deadline = Time.get_ticks_msec()+250
	while Time.get_ticks_msec()<mixer_cleanup_deadline: await process_frame
	paused = false
	quit(0 if failures == 0 else 1)
