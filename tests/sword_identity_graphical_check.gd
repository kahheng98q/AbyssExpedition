extends SceneTree

var failures: int = 0
var assertions: int = 0
var captures: String
var errors = preload("res://tests/error_capture.gd").new()
var capture_records: Array = []

func _initialize() -> void:
	ProfileStore.test_mode = true
	OS.add_logger(errors)
	call_deferred("run_check")

func check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition: failures += 1; printerr("FAIL: " + message)

func capture(name_value: String, grayscale: bool = false) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var image = root.get_texture().get_image()
	capture_records.append({"file": name_value + ".png", "window": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y], "image": [image.get_width(), image.get_height()], "kind": "real logical viewport; controlled fixture"})
	check(image.save_png(captures.path_join(name_value + ".png")) == OK, "saved " + name_value)
	if grayscale:
		image.convert(Image.FORMAT_L8)
		check(image.save_png(captures.path_join(name_value + "-gray.png")) == OK, "saved real grayscale derivative " + name_value)

func prepare(app, hero: String, profession: String, companions: bool = false):
	app.leave_run()
	var profile = ProfileData.fresh()
	profile.owned[hero] = OwnedHero.record(hero, 1400, profession if profession != "swordsman" else "")
	profile.active = hero
	if companions:
		profile.owned.brann = OwnedHero.record("brann", 1400, "abyss_swordsman")
		profile.owned.lia = OwnedHero.record("lia", 1400)
		profile.companions = ["brann", "lia"]
	check(app.writer.mutate(profile, app.writer.revision(), app.writer.operation_id()), "isolated graphical profile")
	app.mount_saved_run(101)
	app.set_window_focused(true)
	var run = app.run
	run.set_physics_process(false)
	run.progression.level = 15
	run.choices.promotion_deferred = true
	if profession != "swordsman": check(PromotionService.apply(run, hero, profession), "live fixture branch")
	if companions: check(PromotionService.apply(run, "brann", "abyss_swordsman"), "live fixture companion branch")
	run.combat_audio.set_enabled(false)
	run.clock.tick = 240
	var target = run.spawn_enemy(&"shellbound_husk", run.hero.position + Vector2(24, 0))
	target.health = ActorHealth.new(100000)
	return run

func pose(run, state: String) -> void:
	for effect in run.effects.get_children(): effect.free()
	run.followups.clear()
	run.damage.requests.clear()
	run.hero.health.dead = false
	run.hero.health.hurt_until = -1
	run.hero.health.current = run.hero.health.maximum - 10
	run.hero.velocity = Vector2.RIGHT * 20 if state == "move" else Vector2.ZERO
	run.hero.attack_until = -1
	run.clock.tick = 240
	if state in ["attack", "fifth", "hurt", "death", "echo"]:
		run.progression.stacks[&"echo_strike"] = 1
		run.hero.next_ready = 0
		run.hero.activations = 4 if state == "fifth" else 3
		check(AttackExecutor.try_activate(run.hero, run, 240), "real attack for " + state)
		run.damage.resolve_tick_hits(run, 240)
		if state == "hurt": run.hero.health.hurt_until = 248
		if state == "death":
			run.hero.health.current = 0
			run.hero.health.dead = true
		if state == "echo":
			run.clock.tick = run.followups[0].due
			run.create_arc(run.followups[0], run.clock.tick)
		for arc in run.effects.get_children():
			var center: Vector2 = arc.position - run.camera.position + Vector2(320, 180)
			check(center.x - arc.reach >= 0 and center.x + arc.reach <= 640 and center.y - arc.reach >= 0 and center.y + arc.reach <= 360, "complete real arc fits logical viewport")
	run.state_changed.emit()

func run_check() -> void:
	var args = OS.get_cmdline_user_args()
	if args.size() != 2 or args[0] != "--captures" or DisplayServer.get_name() == "headless": quit(2); return
	captures = args[1]
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/sword-graphics-%d/" % Time.get_ticks_usec())
	root.add_child(app)
	var panel = app.debug_panel
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(1371, 813)]:
		DisplayServer.window_set_size(dimensions)
		for hero in ["aren", "brann"]:
			for profession in ["swordsman", "swordmaster", "abyss_swordsman"]:
				var run = prepare(app, hero, profession)
				for state in ["idle", "move", "attack", "fifth", "hurt", "death", "echo"]:
					pose(run, state)
					await capture("%s-%s-%s-%d" % [hero, profession, state, dimensions.x], hero == "aren" and profession != "swordsman" and state in ["attack", "fifth"])
				check(app.debug_panel == panel, "App retains one protected DEV")
				pose(run, "fifth")
				var before = run.clock.tick
				var token = run.pause.acquire("manual", "sword-graphics")
				for ignored in range(3): run.simulation.advance(run, Vector2.RIGHT); await process_frame
				check(run.clock.tick == before, "pause freezes sword lifetime")
				run.pause.release(token, "sword-graphics")
				app.leave_run()
				check(app.run == null, "restart removes old sword run")
	# Dense controlled scenes are real screenshots, not human readability answers.
	for index in range(10):
		var run = prepare(app, "aren", "swordmaster" if index % 2 == 0 else "abyss_swordsman", true)
		run.corruption.add(100)
		for i in range(36): run.spawn_enemy(&"saltbound_thrall", run.hero.position + Vector2.from_angle(i * 0.71) * (65 + i % 5 * 15))
		var boss = run.spawn_enemy(&"tidebound_hierophant", run.hero.position + Vector2(90, -70), -1, true)
		boss.health = ActorHealth.new(100000)
		run.create_warning(run.hero.position + Vector2(30 + index, 28), "circle", 25, Vector2.RIGHT, 360, 300)
		run.create_warning(run.hero.position + Vector2(-70, -30), "circle", 35, Vector2.RIGHT, 360, 300)
		pose(run, "fifth")
		for member in run.party.slice(1):
			member.next_ready = 0
			member.activations = 4
			AttackExecutor.try_activate(member, run, 240)
		await capture("dense-%02d" % index)
	for companion in [false, true]:
		for missing in [10.0, 1.25, 0.001, 0.0]:
			var run = prepare(app, "aren", "abyss_swordsman", companion)
			var source = run.party[1] if companion else run.hero
			var feedback = run.get_node("CombatWorld/CombatFeedback")
			var target = run.spawn_enemy(&"shellbound_husk", source.position + Vector2(20, 0))
			target.health = ActorHealth.new(100000)
			source.health.current = source.health.maximum - missing
			source.activations = 4
			source.next_ready = 0
			check(AttackExecutor.try_activate(source, run, run.clock.tick), "real source fifth for healing")
			run.damage.resolve_tick_hits(run, run.clock.tick)
			check(feedback.heal_records.size() == (1 if missing > 0 else 0), "only positive actual healing creates a visible record")
			run.state_changed.emit()
			var label_value = "heal-%s-%.3f" % ["companion" if companion else "hero", missing]
			await capture(label_value)
			if missing > 0:
				var amount: float = feedback.heal_records[source.actor_id].actual_heal
				check(absf(feedback.format_heal(amount).substr(1).to_float() - amount) <= 0.050001, "actual displayed healing precision")
				source.position += Vector2(10, 16)
				await capture(label_value + "-follow")
				var token = run.pause.acquire("manual", "heal-graphics")
				for ignored in range(3): run.simulation.advance(run, Vector2.RIGHT); await process_frame
				check(feedback.heal_records.size() == 1, "paused healing is retained without aging")
				run.pause.release(token, "heal-graphics")
				run.progression.collect_xp(900000, run.progression.level * 100)
				run.choices.present(run)
				await process_frame
				check(run.choices.pause_token >= 0 and feedback.heal_records.size() == 1, "real upgrade UI freezes existing healing")
				await capture(label_value + "-upgrade")
				while not run.choices.offer.is_empty(): run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
				await process_frame
				run.clock.tick = 7200
				source.health.current = source.health.maximum - 10
				source.activations = 9
				source.next_ready = 0
				AttackExecutor.try_activate(source, run, 7200)
				run.damage.resolve_tick_hits(run, 7200)
				run.choices.present_rescue(run)
				await process_frame
				check(run.choices.event_token >= 0 and feedback.heal_records.size() == 1, "real event UI freezes current healing")
				await capture(label_value + "-event")
				if run.choices.event_token >= 0:
					var free = &"leave" if run.events.current.kind == "mysterious_merchant" else &"decline"
					run.choices.resolve_event(run, run.events.current.id, free)
				run.clock.tick += 36
				feedback.call("_process", 0.0)
				check(feedback.heal_records.is_empty(), "healing clears at active expiry")
				run.finish("abandonment")
				check(feedback.heal_records.is_empty(), "result transition clears old healing")
				await process_frame
				app.mount_saved_run(101)
				app.run.set_physics_process(false)
				check(app.run.get_node("CombatWorld/CombatFeedback").heal_records.is_empty(), "new run owns no old healing records")
				await capture(label_value + "-restart")
	app.leave_run()
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(1371, 813)]:
		DisplayServer.window_set_size(dimensions)
		var profile = ProfileData.fresh()
		profile.owned.aren = OwnedHero.record("aren", 1400)

		check(app.writer.mutate(profile, app.writer.revision(), app.writer.operation_id()), "preview layout isolated eligibility")
		app.show_promotion("aren")
		var page = app.screen_host.get_child(0)
		var clock = [0]
		for visual in page.branch_previews.values():
			visual.now_usec = func(): return clock[0]
			visual.call("_on_window_focus_entered")
			visual.call("_process", 0.0)
		clock[0] = 4516700
		for visual in page.branch_previews.values(): visual.call("_process", 0.0)
		await process_frame
		check(page.panel.size.x <= 640 and page.panel.size.y <= 360, "promotion panel fits logical viewport")
		for visual in page.branch_previews.values():
			var radius: float = maxf(visual.configuration.reach, visual.configuration.spin_radius)
			var center = Vector2(floorf(visual.size.x * 0.5), 70)
			check(Rect2(Vector2.ZERO, visual.size).encloses(Rect2(center - Vector2.ONE * radius, Vector2.ONE * radius * 2)), "complete long/spin example fits bounded canvas")
		await capture("promotion-normal-" + str(dimensions.x))
		if OS.has_feature("debug"):
			check(panel.open_panel(), "original DEV opens over normal preview")
			var frozen_tick: int = page.branch_previews[&"swordmaster"].tick
			clock[0] += 6000000
			for visual in page.branch_previews.values(): visual.call("_process", 0.0)
			check(page.branch_previews[&"swordmaster"].tick == frozen_tick, "ordinary canvas freezes when covered")
			panel.service.writer.state = "save-blocked"
			check(not panel.close_panel() and page.branch_previews[&"swordmaster"].host_occluded, "rejected DEV close does not resume ordinary canvas")
			panel.service.writer.state = "ready"
			panel.open_promotion(false)
			var debug_page = panel.promotion_host.get_child(0)
			var debug_clock = [0]
			for visual in debug_page.branch_previews.values():
				visual.now_usec = func(): return debug_clock[0]
				visual.call("_on_window_focus_entered")
				visual.call("_process", 0.0)
			debug_clock[0] = 4516700
			for visual in debug_page.branch_previews.values(): visual.call("_process", 0.0)
			await capture("promotion-dev-" + str(dimensions.x))
			check(debug_page.panel.size.x <= 640 and debug_page.panel.size.y <= 360 and paused, "DEV canvas respects panel bounds and paused tree")
			panel.clear_promotion()
			check(panel.close_panel(), "DEV original close succeeds")
			check(panel.service.execute("end_sandbox").ok, "isolated preview restores original normal menu")
			await process_frame
	var manifest = FileAccess.open(captures.path_join("captures.json"), FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"assertions": assertions, "failures": failures, "records": capture_records, "preview_clock": "injected for layout only; real playback uses separate harness"}, "", true, true))
	manifest.close()
	app.free()
	paused = false
	var deadline = Time.get_ticks_msec() + 250
	while Time.get_ticks_msec() < deadline: await process_frame
	for error in errors.snapshot(): check(false, error)
	OS.remove_logger(errors)
	print("SWORD GRAPHICAL: %d assertions; %d failures; controlled screenshots only" % [assertions, failures])
	quit(0 if failures == 0 else 1)
