extends RefCounted

static func create(tree, hero_id: StringName = &"aren", seed_value: int = 101) -> Dictionary:
	var catalog = ContentCatalog.new()
	tree.root.add_child(catalog)
	assert(catalog.load_all(), "catalog invalid")
	var run = catalog.scene("expedition").instantiate()
	tree.root.add_child(run)
	run.set_physics_process(false)
	run.start(catalog, RunStartSnapshot.new(seed_value, hero_id))
	return {"catalog": catalog, "run": run}

static func dispose(fixture: Dictionary) -> void:
	fixture.run.phase = "disposed"
	fixture.run.free()
	fixture.catalog.free()

static func create_party(tree, payload: Dictionary, seed_value: int = 101) -> Dictionary:
	var catalog = ContentCatalog.new()
	tree.root.add_child(catalog)
	assert(catalog.load_all(), "catalog invalid")
	var run = catalog.scene("expedition").instantiate()
	tree.root.add_child(run)
	run.set_physics_process(false)
	run.start(catalog, RosterService.snapshot(payload, seed_value))
	return {"catalog": catalog, "run": run}
