extends SceneTree

class CaptureErrors extends Logger:
	var errors: Array[String] = []
	func _log_error(_function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _backtraces: Array[ScriptBacktrace]) -> void:
		if error_type != Logger.ERROR_TYPE_WARNING: errors.append("%s:%d %s %s" % [file, line, code, rationale])

var failures: int = 0
var assertions: int = 0
var capture_errors = CaptureErrors.new()
var output_path: String

func _initialize() -> void:
	OS.add_logger(capture_errors)
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func key(code: int, unicode_value: int = 0) -> void:
	var event = InputEventKey.new()
	event.keycode = code
	event.unicode = unicode_value
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	event = InputEventKey.new()
	event.keycode = code
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func capture(name_value: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(output_path.path_join(name_value + ".png")) == OK, "capture " + name_value)

func physical_key(code: int) -> void:
	for down in [true, false]:
		var event = InputEventKey.new()
		event.physical_keycode = code
		event.pressed = down
		Input.parse_input_event(event)
		Input.flush_buffered_events()

func click_control(button: Control) -> void:
	var point = button.get_global_rect().get_center()
	var motion = InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for down in [true, false]:
		var event = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
	await process_frame
	await process_frame

func click_action(panel, action: String) -> void:
	for entry in panel.buttons:
		if entry.action != action: continue
		await click_control(entry.button)
		return
	check(false, "missing action button " + action)

func verify_debug_access() -> void:
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/debug-access-%d-%d/" % [OS.get_process_id(), Time.get_ticks_usec()])
	root.add_child(app)
	current_scene = app
	var panel = app.debug_panel
	await process_frame
	await RenderingServer.frame_post_draw
	check(panel.launcher.is_visible_in_tree() and not panel.overlay.visible, "debug launcher discoverable before first F9")
	check(root.title.contains("Developer Build"), "window title identifies developer build")
	await capture("debug-access-menu")
	app.writer.state = "save-blocked"
	await click_control(panel.launcher)
	check(not panel.overlay.visible and not paused and panel.banner.text.contains("Debug unavailable:"), "unavailable profile reports visible reason without pausing menu")
	check(Rect2(0, 0, 640, 360).encloses(panel.banner.get_global_rect()), "debug failure message fits viewport " + str(panel.banner.get_global_rect()))
	app.writer.state = "ready"
	await click_control(panel.launcher)
	check(panel.overlay.visible and paused, "mouse debug launcher opens from main menu")
	key(KEY_F9)
	await process_frame
	check(not panel.overlay.visible and not paused, "logical F9 closes panel opened by mouse in menu")
	app.mount_run(RunStartSnapshot.new(101, &"lia"))
	app.run.set_physics_process(false)
	await process_frame
	await capture("debug-access-combat")
	check(Rect2(0, 0, 640, 360).encloses(panel.launcher.get_global_rect()), "debug launcher fits combat viewport")
	await click_control(panel.launcher)
	check(panel.overlay.visible and paused and app.run.pause.is_blocked(), "mouse debug launcher opens and pauses combat")
	panel.xp_amount.get_line_edit().grab_focus()
	physical_key(KEY_F9)
	await process_frame
	check(not panel.overlay.visible and not app.run.pause.is_blocked(), "physical F9 closes from a focused XP input")
	var held = InputEventKey.new()
	held.physical_keycode = KEY_F9
	held.pressed = true
	held.echo = true
	Input.parse_input_event(held)
	Input.flush_buffered_events()
	check(not panel.overlay.visible, "held F9 repeat does not reopen panel")
	physical_key(KEY_F9)
	await process_frame
	check(panel.overlay.visible and paused, "physical F9 opens combat panel")
	var close
	for button in panel.overlay.find_children("*", "Button", true, false):
		if button.text == "F9 · Close": close = button
	check(close != null, "panel exposes mouse close button")
	if close != null: await click_control(close)
	check(not panel.overlay.visible and not app.run.pause.is_blocked(), "mouse Close releases only debug combat pause")
	app.run.toggle_manual_pause()
	await click_control(panel.launcher)
	check(panel.overlay.visible, "mouse launcher works during existing manual pause")
	key(KEY_F9)
	await process_frame
	check(not panel.overlay.visible and app.run.pause.is_blocked() and app.run.manual_token >= 0, "F9 close preserves pre-existing manual pause")
	app.run.toggle_manual_pause()
	app.free()
	await process_frame
	paused = false

func verify_xp_buttons() -> void:
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/debug-xp-buttons-%d-%d/" % [OS.get_process_id(), Time.get_ticks_usec()])
	root.add_child(app)
	current_scene = app
	var profile = PermanentProgression.add_character_xp(app.writer.payload, "lia", 1300)
	check(app.writer.mutate(profile, app.writer.revision(), app.writer.operation_id(), {"kind": "test_fixture"}), "Lia level 14 fixture saved")
	var normal = app.writer
	var normal_path = normal.store.generations()[0].path
	var normal_bytes = normal.store.read(normal_path)
	app.mount_run(RunStartSnapshot.new(101, &"lia"))
	app.run.set_physics_process(false)
	await process_frame
	await RenderingServer.frame_post_draw
	key(KEY_F9)
	await process_frame
	await process_frame
	var panel = app.debug_panel
	check(panel.selected(panel.character_choice) == "lia", "panel initially targets deployed hero Lia")
	for index in range(panel.character_choice.item_count):
		if panel.character_choice.get_item_metadata(index) == "lia": panel.character_choice.select(index)
	panel.update_branches()
	panel.refresh()
	await process_frame
	await click_action(panel, "level_one")
	check(panel.service.writer.payload.owned.lia.level == 15, "mouse +1 level button changes selected Lia")
	check(app.run.hero.permanent_level == 15 and panel.character_stats.text.contains("Lv 15"), "mouse level change reflected in live actor and panel")
	var hud = app.run.get_node("HUD/CombatHUD")
	check(hud.values.text.contains("Hero Lv 15") and hud.values.text.contains("Run Lv 1"), "HUD distinguishes permanent hero level from shared run level")
	panel.xp_amount.get_line_edit().grab_focus()
	panel.xp_amount.get_line_edit().select_all()
	for digit in [50, 53, 48]: key(digit, digit)
	check(panel.xp_amount.get_line_edit().text == "250", "native typing replaces XP field without pressing Enter")
	await click_action(panel, "character_xp")
	check(panel.service.writer.payload.owned.lia.total_xp == 1650 and app.run.hero.permanent_level == 17, "mouse XP button applies newly typed amount and updates hero")
	await click_action(panel, "run_xp")
	check(app.run.progression.level == 2 and app.run.progression.xp == 150 and app.run.progression.pending == 1, "mouse run XP button uses entered amount through shared upgrade rules")
	check(hud.values.text.contains("Hero Lv 17") and hud.values.text.contains("Run Lv 2") and hud.xp_bar.max_value == 200 and hud.xp_bar.value == 150, "HUD updates run XP threshold and retains permanent level")
	check(panel.run_stats.text.contains("XP 150 / 200"), "shared run XP reflected inside open debug panel")
	await capture("debug-xp-level-buttons")
	await click_action(panel, "level_ten")
	check(panel.service.writer.payload.owned.lia.level == 27 and app.run.hero.permanent_level == 27, "mouse +10 level button updates selected hero")
	await click_action(panel, "level_max")
	await click_action(panel, "level_one")
	check(panel.service.writer.payload.owned.lia.level == 30 and panel.service.writer.payload.owned.lia.total_xp == 2900 and panel.feedback.text.contains("maximum level 30"), "maximum and repeated +1 stay capped with visible feedback")
	check(app.run.hero.permanent_level == 30 and is_equal_approx(app.run.hero.health.maximum, 237), "maximum level updates live Lia health scaling")
	panel.tabs.current_tab = 3
	await process_frame
	await process_frame
	await click_action(panel, "load_test")
	check(panel.service.writer.payload.owned.lia.total_xp == 2900 and app.run.hero.permanent_level == 30, "reload sandbox button retains committed XP and reapplies live level")
	check(normal.store.read(normal_path) == normal_bytes and normal.payload.owned.lia.total_xp == 1300, "XP and level button actions leave normal profile unchanged")
	while not app.run.choices.offer.is_empty(): app.run.choices.confirm(app.run, app.run.choices.offer_id, app.run.choices.offer[0])
	key(KEY_F9)
	await process_frame
	check(not panel.overlay.visible and not app.run.pause.is_blocked(), "XP upgrades and debug panel can finish without leaving combat paused")
	check(hud.values.get_global_rect().end.x <= 640, "HUD hero and run levels fit viewport")
	await capture("debug-xp-level-hud")
	check(panel.service.execute("restart").ok and app.run.hero.permanent_level == 30, "restarted sandbox run loads permanent level from saved progression")
	app.free()
	await process_frame
	paused = false

func run() -> void:
	check(OS.has_feature("debug"), "graphical panel check requires a real debug build")
	output_path = ProjectSettings.globalize_path("res://screenshots/")
	var args = OS.get_cmdline_user_args()
	if args.has("--captures"): output_path = args[args.find("--captures") + 1]
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	await verify_debug_access()
	await verify_xp_buttons()
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/debug-graphical-%d-%d/" % [OS.get_process_id(), Time.get_ticks_usec()])
	root.add_child(app)
	current_scene = app
	app.mount_run(RunStartSnapshot.new(101, &"aren"))
	app.run.set_physics_process(false)
	var panel = app.debug_panel
	check(panel != null and not panel.overlay.visible, "hidden at startup")
	await process_frame
	await RenderingServer.frame_post_draw
	key(KEY_F9)
	await process_frame
	await process_frame
	check(panel.overlay.visible and paused and app.run.pause.is_blocked(), "native F9 input opens panel while paused")
	panel.service.execute("eligibility", {"character_id": "aren"})
	panel.service.execute("add_companion", {"companion_id": "lia"})
	panel.service.execute("add_companion", {"companion_id": "milo"})
	panel.service.execute("spawn", {"enemy_id": "skittering_brinejaw", "count": 10})
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(1371, 813)]:
		DisplayServer.window_set_size(dimensions)
		for index in range(4):
			panel.tabs.current_tab = index
			panel.refresh()
			await process_frame
			await process_frame
			check(Rect2(0, 0, 640, 360).encloses(panel.tabs.get_global_rect()), "tab fits viewport " + str(index))
			check(Rect2(0, 0, 640, 360).encloses(panel.feedback.get_global_rect()), "feedback fits viewport")
			await capture("debug-" + str(dimensions.x) + "-tab-" + str(index))
			var scroll = panel.tabs.get_child(index)
			scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
			await capture("debug-" + str(dimensions.x) + "-tab-" + str(index) + "-bottom")
		panel.open_promotion(false)
		await capture("debug-" + str(dimensions.x) + "-promotion")
		var screen = panel.promotion_host.get_child(0)
		check(screen.panel.size.x <= 640 and screen.panel.size.y <= 360, "existing promotion modal fits debug overlay")
		panel.clear_promotion()
		print("DEBUG GRAPHICAL window=%s actual=%s four tabs / scroll / promotion / paused native input" % [dimensions, DisplayServer.window_get_size()])
	panel.open_promotion(false)
	var promotion = panel.promotion_host.get_child(0)
	promotion.selected = "swordmaster"
	promotion.submit()
	check(app.run.hero.profession.id == &"swordmaster", "existing promotion UI submits sandbox class")
	key(KEY_F9)
	await process_frame
	check(not panel.overlay.visible and not app.run.pause.is_blocked(), "native F9 closes panel")
	app.run.clock.tick = 45
	app.run.spawns.simulate(app.run, 45)
	app.run.spawn_enemy(&"saltbound_thrall", app.run.hero.position + Vector2(25, 0))
	AttackExecutor.try_activate(app.run.hero, app.run, 45)
	app.run.state_changed.emit()
	await capture("debug-promoted-party-combat")
	app.free()
	await process_frame
	paused = false
	for error in capture_errors.errors: check(false, error)
	OS.remove_logger(capture_errors)
	print("DEBUG GRAPHICAL: assertions=%d failures=%d" % [assertions, failures])
	quit(0 if failures == 0 else 1)
