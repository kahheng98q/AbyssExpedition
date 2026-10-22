extends SceneTree

func _initialize() -> void:
	ProfileStore.test_mode = true
	call_deferred("capture")

func capture() -> void:
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var label_value = OS.get_cmdline_user_args()[0]
	var folder = "res://screenshots/guild-hub-20261022"
	DirAccess.make_dir_recursive_absolute(folder)
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/guild-capture-%d/" % Time.get_ticks_usec())
	root.add_child(app)
	current_scene = app
	for page in ["guild", "roster", "recruitment", "selection"]:
		app.call("show_" + page)
		await create_timer(0.4).timeout
		await RenderingServer.frame_post_draw
		var path = folder.path_join(label_value + "-" + page + ".png")
		if FileAccess.file_exists(path):
			printerr("Refusing to overwrite " + path)
			quit(2)
			return
		root.get_texture().get_image().save_png(path)
		print("CAPTURE ", path)
	app.writer.close()
	app.queue_free()
	await process_frame
	quit()
