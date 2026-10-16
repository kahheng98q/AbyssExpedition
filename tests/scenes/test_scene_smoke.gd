extends RefCounted

func run(t) -> void:
	var catalog = ContentCatalog.new()
	t.root.add_child(catalog)
	t.check(catalog.load_all(), "all catalog content loads: " + str(catalog.errors))
	for path in preload("res://tests/script_manifest.gd").PATHS:
		var script = load(path)
		t.check(script != null and script.can_instantiate(), "registered script parses: " + path)
	for key in ContentCatalog.SCENES:
		var node = catalog.scene(key).instantiate()
		if key in ["character_selection", "roster", "promotion", "guild"]: node.catalog = catalog
		if key == "app": node.writer = SaveCoordinator.new("user://tests/scene-app-%d/" % Time.get_ticks_usec())
		if key == "run_results": node.summary = {"outcome": "victory", "hero_name": "Aren", "seed": 101, "time": "10:00", "level": 8, "kills": 200}
		if key == "level_up":
			# Covered with a bound Expedition in UI tests.
			node.free()
			continue
		t.root.add_child(node)
		if key == "promotion":
			t.check(node.get("branch_previews") is Dictionary and node.get("branch_previews").size() == 2, "promotion exposes two actual branch visual previews")
		if key == "expedition":
			node.set_physics_process(false)
			node.start(catalog, RunStartSnapshot.new(2147483647, &"milo"))
			t.check(node.actors.get_child_count() == 1 and node.hero.has_node("Body") and node.hero.has_node("Presentation"), "hero wiring and ownership")
		await t.process_frame
		await t.physics_frame
		t.check(node.is_inside_tree(), "scene instantiated/frame stepped: " + key)
		node.free()
		await t.process_frame
	catalog.free()
	t.paused = false
