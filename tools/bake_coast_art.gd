extends SceneTree
# Authoring utility: rasterize this project's own static 2D drawing commands.
func _initialize() -> void:
	call_deferred("bake")
func bake() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/world")
	var viewport = SubViewport.new()
	viewport.size = Vector2i(960, 540)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	var field = load("res://scenes/world/coast_field.tscn").instantiate()
	# Added after the first bake so future bakes always use the editable source.
	if "use_baked_art" in field: field.use_baked_art = false
	viewport.add_child(field)
	for corruption_value in [0, 100]:
		field.set_corruption(corruption_value)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var result = viewport.get_texture().get_image().save_png("res://assets/world/coast-%d.png" % corruption_value)
		print("BAKE coast=", corruption_value, " save=", result)
		if result != OK: quit(1); return
	viewport.free()
	quit()
