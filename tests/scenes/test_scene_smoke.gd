extends RefCounted

func run(t) -> void:
	var catalog = ContentCatalog.new()
	t.root.add_child(catalog)
	t.check(catalog.load_all(), "all catalog content loads: " + str(catalog.errors))
	var shrine=load("res://scenes/world/visuals/coast_shrine.tscn").instantiate()
	t.root.add_child(shrine)
	t.check(shrine.is_complete() and shrine.tile_set.get_physics_layers_count()==0 and shrine.tile_set.get_navigation_layers_count()==0,"actual shrine complete; no collision/navigation")
	t.check(shrine.get_node("Ground").z_index==-30 and shrine.get_node("Props").z_index==-10 and shrine.get_node("Corruption").z_index==-20,"new subtree final depth")
	var prop_regions=[Rect2(0,0,64,96),Rect2(64,0,32,64),Rect2(96,0,32,64),Rect2(128,0,32,64),Rect2(160,0,32,64),Rect2(192,0,32,64)]
	for i in range(6):
		var prop=shrine.get_node("Props").get_child(i)
		t.check(prop.region_rect==prop_regions[i] and prop.texture.get_image().get_region(Rect2i(prop.region_rect)).get_used_rect().has_area(),"each of six actual authored prop cells is nonblank and independently cropped")
	var detail=shrine.get_node("Props").get_node_or_null("CorruptionDetail")
	t.check(detail!=null,"original corruption eye/branches belong to shrine prop detail")
	if detail!=null:
		shrine.set_corruption(0)
		t.check(detail.modulate.a==0,"clean shrine at corruption0")
		shrine.set_corruption(100)
		t.check(detail.modulate.a==1 and detail.z_index==0 and detail.get_parent().z_index==-10,"painted prop highlight at100 stays below actors; no light/shader")
	shrine.free()
	for absent in [false,true]:
		var field=catalog.scene("coast_field").instantiate()
		if absent:field.visual_scene=null
		t.root.add_child(field)
		var walls=field.get_children().filter(func(child):return child is StaticBody2D)
		t.check(walls.size()==4 and field.using_visual==not absent,"four walls in normal and missing-resource fallback")
		var expected=[Vector2(992,16),Vector2(992,16),Vector2(16,540),Vector2(16,540)]
		for i in range(4):t.check(walls[i].get_child(0).shape.size==expected[i],"unchanged wall geometry")
		field.free()
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
			t.check(node.actors.y_sort_enabled and node.actors.z_index==0 and node.pickups.z_index==5 and node.projectiles.z_index==10 and node.effects.z_index==10 and node.telegraphs.z_index==20,"existing hosts/actor sort and warning priority retained")
		await t.process_frame
		await t.physics_frame
		t.check(node.is_inside_tree(), "scene instantiated/frame stepped: " + key)
		node.free()
		await t.process_frame
	catalog.free()
	t.paused = false
