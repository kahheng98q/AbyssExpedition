extends SceneTree
class PreviewClock extends RefCounted:
	var clock = RunClock.new()
func _initialize() -> void:
	call_deferred("bake")
func bake() -> void:
	var catalog = ContentCatalog.new()
	root.add_child(catalog)
	if not catalog.load_all(): quit(1); return
	var viewport = SubViewport.new()
	viewport.size = Vector2i(512, 560)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	for row in range(7):
		for col in range(8):
			var actor = catalog.scene("boss" if row == 6 else "enemy").instantiate()
			var source = PreviewClock.new()
			source.clock.tick = 18 if col % 2 else 0
			actor.setup(catalog.boss if row == 6 else catalog.enemies[StringName(ContentCatalog.ENEMIES[row])], row, source, false, row == 6)
			actor.position = Vector2(col * 64 + 32, row * 80 + 40)
			actor.corrupted = col >= 4
			actor.health.hurt_until = 100 if col % 4 >= 2 else -1
			var presentation = actor.get_node("Presentation")
			if "use_baked_enemies" in presentation: presentation.use_baked_enemies = false
			viewport.add_child(actor)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://assets/actors")
	var result = viewport.get_texture().get_image().save_png("res://assets/actors/enemy-atlas.png")
	print("BAKE 7 enemy silhouettes x 8 variants: ", result)
	viewport.free()
	catalog.free()
	quit(0 if result == OK else 1)
