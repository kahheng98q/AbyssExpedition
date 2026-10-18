extends RefCounted

func run(t) -> void:
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/m1-loop-%d-%d/" % [OS.get_process_id(), Time.get_ticks_usec()])
	t.root.add_child(app)
	await t.process_frame
	t.check(app.screen_host.get_child_count() == 1 and app.run == null, "current App boots isolated combat-loop regression; retained M1 export establishes M1-only scope")
	for id_value in [&"aren", &"lia", &"milo"]:
		app.mount_run(RunStartSnapshot.new(0, id_value))
		app.run.set_physics_process(false)
		t.check(app.expedition_host.get_child_count() == 1, "one owned expedition")
		app.show_results({"outcome": "victory"}, app.generation - 1)
		t.check(app.run != null, "stale run generation cannot route a result")
		t.check(app.run.hero.definition.id == id_value and app.run.hero.health.current == app.catalog.characters[id_value].base_profession.starting_stats.max_health, "fresh selected starter")
		app.run.simulation.advance(app.run, Vector2.ZERO)
		t.check(app.run.spawns.reservations.size() == 4, "tick zero wave")
		app.run.finish("abandonment")
		await t.process_frame
		await t.process_frame
		t.check(app.run == null and app.expedition_host.get_child_count() == 0, "terminal frees expedition")
		t.check(app.screen_host.get_child(0).summary.outcome == "abandonment", "usable result routed once")
		app.mount_run(RunStartSnapshot.new(app.last_snapshot.seed_value, app.last_snapshot.hero_id))
		app.run.set_physics_process(false)
		t.check(app.run.clock.tick == 0 and app.run.progression.level == 1 and app.run.progression.stacks.is_empty(), "retry resets time XP health upgrades")
		app.show_selection()
		t.check(app.run == null and app.modal_host.get_child_count() == 0, "selection cleanup")
	app.show_menu()
	app.free()
	t.paused = false
	await t.process_frame
