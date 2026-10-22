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

# Offline human-test material only; production simulation and drawings are reused.
# Frame sequences encode 60 real simulation ticks at 60 fps, not human observations.
func run_check() -> void:
	var args = OS.get_cmdline_user_args()
	if args.size() != 2 or args[0] != "--captures" or DisplayServer.get_name() == "headless": quit(2); return
	captures = args[1]
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/sword-stimuli-%d/" % Time.get_ticks_usec())
	root.add_child(app)
	var clips: Array = []
	var number = 0
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(1371, 813)]:
		DisplayServer.window_set_size(dimensions)
		for profession in ["swordsman", "swordmaster", "abyss_swordsman"]:
			for attack in ["attack", "fifth"]:
				var id = "C%02d" % number
				number += 1
				var directory = captures.path_join(id)
				DirAccess.make_dir_recursive_absolute(directory)
				var run = prepare(app, "aren", profession)
				# Keep the opening target alive; do not add upgrades or companions.
				run.progression.stacks.clear()
				for enemy in run.enemies: enemy.health = ActorHealth.new(100000)
				run.hero.activations = 4 if attack == "fifth" else 3
				run.hero.next_ready = 0
				check(AttackExecutor.try_activate(run.hero, run, run.clock.tick), "actual isolated attack")
				run.damage.resolve_tick_hits(run, run.clock.tick)
				# This stimulus isolates one activation; later automatic firings are outside the clip.
				run.hero.next_ready = 1000000
				var feedback = run.get_node("CombatWorld/CombatFeedback")
				var frames: Array = []
				for frame in range(60):
					feedback.show()
					await process_frame
					await RenderingServer.frame_post_draw
					var raw = root.get_texture().get_image()
					var raw_name = "%s/raw-%02d.png" % [id, frame]
					check(raw.save_png(captures.path_join(raw_name)) == OK, "raw frame saved")
					# Same tick, uniformly hide the entire feedback layer for BOTH branches.
					# This removes all damage/heal numerals and impact particles, never weapon arcs.
					feedback.hide()
					await process_frame
					await RenderingServer.frame_post_draw
					var clean = root.get_texture().get_image().get_region(Rect2i(192, 104, 224, 176))
					var clean_name = "%s/clean-%02d.png" % [id, frame]
					check(clean.save_png(captures.path_join(clean_name)) == OK, "clean color frame saved")
					clean.convert(Image.FORMAT_L8)
					var gray_name = "%s/gray-%02d.png" % [id, frame]
					check(clean.save_png(captures.path_join(gray_name)) == OK, "grayscale frame saved")
					frames.append({"tick": run.clock.tick, "raw": raw_name, "clean": clean_name, "gray": gray_name})
					feedback.show()
					run.simulation.advance(run, Vector2.ZERO)
				check(run.party.size() == 1 and run.phase == "active", "one hero remains active")
				clips.append({"id": id, "hero": "aren", "permanent_level": 15, "seed": 101, "window": [dimensions.x, dimensions.y], "logical_viewport": [640,360], "crop": [192,104,224,176], "profession": profession, "attack": attack, "fps": 60, "duration_seconds": 1, "frames": frames})
	var dense: Array = []
	for index in range(10):
		var run = prepare(app, "aren", "swordmaster" if index % 2 == 0 else "abyss_swordsman", true)
		run.corruption.add(100)
		for i in range(36): run.spawn_enemy(&"saltbound_thrall", run.hero.position + Vector2.from_angle(i * 0.71) * (65 + i % 5 * 15))
		run.spawn_enemy(&"tidebound_hierophant", run.hero.position + Vector2(90, -70), -1, true)
		var offset = Vector2(30 + index, 28)
		run.create_warning(run.hero.position + offset, "circle", 25, Vector2.RIGHT, 360, 300)
		run.create_warning(run.hero.position + Vector2(-70, -30), "circle", 35, Vector2.RIGHT, 360, 300)
		pose(run, "fifth")
		for member in run.party.slice(1):
			member.next_ready = 0
			member.activations = 4
			AttackExecutor.try_activate(member, run, 240)
		await capture("D%02d" % index)
		dense.append({"id": "D%02d" % index, "file": "D%02d.png" % index, "hero": [320,180], "nearest_warning": [[320 + offset.x,180 + offset.y]], "warning_radius": 25, "accepted_tie": false, "corruption": 100, "companions": 2})
	var manifest = FileAccess.open(captures.path_join("source.json"), FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"clips": clips, "dense": dense, "controlled": true, "human_results": [], "treatment": "Full raw frames preserved. Same simulation tick with CombatFeedback hidden uniformly removes all impact particles and numeric damage/heal text; fixed crop removes HUD/DEV. Original body and weapon arcs retained. Gray uses Godot Image.FORMAT_L8. 60 simulation ticks per one-second sequence; not a measured real-time recording.", "assertions": assertions, "failures": failures}, "", true, true))
	manifest.close()
	app.free()
	paused = false
	for error in errors.snapshot(): check(false, error)
	OS.remove_logger(errors)
	print("SWORD STIMULI: %d assertions; %d failures; no human answers" % [assertions, failures])
	quit(0 if failures == 0 else 1)
