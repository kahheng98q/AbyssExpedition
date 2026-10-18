extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var catalog = ContentCatalog.new()
	root.add_child(catalog)
	var valid = catalog.load_all()
	for row in [["hero",&"aren",&"swordsman"],["enemy",&"saltbound_thrall",&""],["enemy",&"skittering_brinejaw",&""]]:
		if catalog.actor_visuals==null or catalog.actor_visuals.resolve(row[0],row[1],row[2])==null:
			catalog.errors.append("expected production sprite mapping missing: "+str(row[1]));valid=false
	for path in ["res://data/themes/expedition_theme.tres","res://data/visuals/coast_shrine_tileset.tres","res://scenes/world/visuals/coast_shrine.tscn"]:
		if load(path)==null:catalog.errors.append("missing native visual: "+path);valid=false
	for path in preload("res://tests/script_manifest.gd").PATHS:
		var script = load(path)
		if script == null or not script.can_instantiate():
			catalog.errors.append("invalid script " + path)
			valid = false
	var invalid = StatBlock.new()
	if catalog.characters.size() != 6 or ProfileData.fresh().owned.size() != 3 or catalog.pool.hero_at(0) != "brann" or catalog.pool.hero_at(1) != "nyra":
		catalog.errors.append("M3 roster/initial ownership/pool interval mismatch")
		valid = false
	var bad_entry = GachaEntry.new()
	bad_entry.character_id = &"sera"
	if bad_entry.validate() == "":
		catalog.errors.append("story hero accepted into draw pool")
		valid = false
	invalid.max_health = NAN
	if invalid.validate().is_empty():
		catalog.errors.append("nonfinite fixture accepted")
		valid = false
	var effect = EffectDefinition.new()
	effect.kind = &"unregistered_capability"
	if effect.validate().is_empty():
		catalog.errors.append("unknown capability fixture accepted")
		valid = false
	for error in catalog.errors: printerr(error)
	print("CONTENT: %d root Resources; %d scenes; %d scripts; valid=%s; digest=%s" % [catalog.resources.size(), catalog.packed.size(), preload("res://tests/script_manifest.gd").PATHS.size(), valid, catalog.digest])
	catalog.free()
	quit(0 if valid else 1)
