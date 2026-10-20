extends RefCounted

func run(t) -> void:
	var fault = preload("res://tests/fixtures/fault_file_store.gd").new()
	fault.remaining = 0
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/m2-app-%d/" % Time.get_ticks_usec(), fault)
	t.root.add_child(app)
	t.check(app.writer.state == "ready", "profile loads before menu")
	var p = app.writer.payload.duplicate(true)
	p.companions = ["lia", "milo"]
	t.check(app.writer.mutate(p, app.writer.revision(), "party-fixture"), "party persisted")
	app.show_selection()
	var selection = app.screen_host.get_child(0)
	t.check(selection.selected == &"aren" and selection.saved_seed == 101, "selection restores saved active hero and seed")
	app.show_roster()
	t.check(app.screen_host.get_child(0).companions == ["lia", "milo"], "roster restores saved companions")
	app.mount_run(RunStartSnapshot.new(303, &"aren"))
	app.run.set_physics_process(false)
	t.check(app.run.party.size() == 3 and app.writer.payload.seed == 303, "launch waits for saved party/seed")
	# Focus owns only its own pause token; menu/start/restart are covered here.
	if app.has_method("set_window_focused"):
		app.set_window_focused(false)
		var focus_id = app.focus_token
		app.set_window_focused(false)
		var other_id = app.run.pause.acquire("manual", "focus-test")
		t.check(focus_id > 0 and app.focus_token == focus_id and app.run.pause.tokens.size() == 2, "repeated focus loss acquires once")
		app.set_window_focused(true)
		t.check(app.focus_token == -1 and app.run.pause.tokens.has(other_id), "focus gain only releases its own token")
		app.run.pause.release(other_id, "focus-test")
	else: t.check(false, "App exposes focus ownership transition")
	app.run.clock.tick = 3600
	fault.stage = "readback"
	fault.remaining = 1
	var summary = RunSummary.freeze(app.run, "victory")
	app.show_results(summary, app.generation)
	t.check(app.run == null and app.writer.state == "save-blocked", "failed terminal settlement freezes continuation")
	var bytes = app.writer.pending_bytes
	app.show_results(summary, app.generation)
	t.check(app.writer.pending_bytes == bytes, "duplicate results preserve original frozen action")
	t.check(app.writer.retry(), "same frozen settlement Retry succeeds")
	app.save_continuation.call()
	t.check(app.writer.payload.owned.aren.total_xp == 120 and app.writer.payload.owned.lia.total_xp == 120 and app.writer.payload.promotion_items == 1, "actual app settlement rewards all participants exactly once")
	var revision = app.writer.revision()
	app.show_results(summary, app.generation)
	t.check(app.writer.revision() == revision, "results re-entry does not resettle")
	app.mount_run(RunStartSnapshot.new(303, &"aren"))
	app.run.set_physics_process(false)
	t.check(app.run.hero.stats.max_health == 255 and app.run.snapshot.members[0].level == 2, "Retry retains progression and snapshots changed stats")
	var immutable = app.run.snapshot.members
	immutable[0].level = 30
	t.check(app.run.snapshot.members[0].level == 2, "start snapshot cannot be mutated by its consumer")
	app.run.clock.tick = 3600
	app.run.finish("victory")
	app.settle_before_close()
	await t.process_frame
	t.check(app.writer.payload.owned.aren.total_xp == 240 and app.writer.payload.promotion_items == 2, "finished run settles once even when close precedes deferred results routing")
	var capped = app.writer.payload.duplicate(true)
	capped.owned.aren = OwnedHero.record("aren", 2850)
	capped.owned.lia = OwnedHero.record("lia", 2900)
	t.check(app.writer.mutate(capped, app.writer.revision(), app.writer.operation_id()), "cap UI fixture saved")
	app.mount_run(RunStartSnapshot.new(303, &"aren"))
	app.run.set_physics_process(false)
	app.run.clock.tick = 3600
	app.run.finish("victory")
	await t.process_frame
	var result_screen = app.screen_host.get_child(0)
	var result_text = ""
	for item in result_screen.column.get_children():
		if item is Label: result_text += item.text + "\n"
	t.check(result_text.contains("Aren: +50 XP") and result_text.contains("Lia: +0 XP") and result_text.contains("CAP"), "results show actual XP and cap per participant")
	t.check(app.writer.payload.owned.aren.total_xp == 2900 and app.writer.payload.owned.lia.total_xp == 2900, "cap UI does not change capped settlement")
	app.mount_run(RunStartSnapshot.new(303, &"aren"))
	app.run.set_physics_process(false)
	for i in range(20000):
		app.run.trace.record_movement(i, Vector2(0.1234567890123456 if i % 2 else -0.1234567890123456, 0.9876543210123456))
	app.run.clock.tick = 3600
	app.run.finish("victory")
	await t.process_frame
	t.check(app.writer.state == "ready", "large diagnostic input trace cannot exceed the durable profile size limit")
	if app.writer.state == "ready":
		t.check(not app.writer.payload.receipt.result.summary.has("trace"), "diagnostic replay trace is not serialized into permanent settlement receipts")
	var all_capped = app.writer.payload.duplicate(true)
	for id in all_capped.owned: all_capped.owned[id] = OwnedHero.record(id, 2900)
	t.check(app.writer.mutate(all_capped, app.writer.revision(), app.writer.operation_id()), "unchanged-level rescue replay fixture")
	app.mount_run(RunStartSnapshot.new(303, &"aren"))
	app.run.set_physics_process(false)
	app.run.rescue.state = "succeeded"
	app.run.clock.tick = 0
	app.run.finish("defeat")
	await t.process_frame
	t.check(app.writer.payload.owned.has("sera") and app.screen_host.get_child(0).summary.starting_changed, "first rescue discloses changed event replay conditions even when every participant is capped")
	if app.has_method("set_window_focused"):
		app.set_window_focused(false)
		app.leave_run()
		t.check(app.focus_token == -1, "leave clears stale focus token")
		app.mount_run(RunStartSnapshot.new(303, &"aren"))
		app.run.set_physics_process(false)
		t.check(app.focus_token > 0 and app.run.pause.is_blocked(), "start while unfocused blocks before first tick")
		app.mount_run(RunStartSnapshot.new(303, &"aren"))
		app.run.set_physics_process(false)
		t.check(app.focus_token > 0 and app.run.clock.tick == 0 and app.run.pause.tokens.size() == 1, "restart owns exactly one new focus token")
		app.set_window_focused(true)
	app.leave_run()
	app.free()
	await t.process_frame
	t.paused = false
