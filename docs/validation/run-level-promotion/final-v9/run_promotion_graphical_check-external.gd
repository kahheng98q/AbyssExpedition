extends SceneTree

class ErrorCapture:
	extends Logger
	
	var mutex: Mutex = Mutex.new()
	var errors: Array[String] = []
	
	func _log_error(_function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		if error_type == Logger.ERROR_TYPE_WARNING: return
		mutex.lock()
		errors.append("%s:%d %s %s" % [file, line, code, rationale])
		mutex.unlock()
	
	func snapshot() -> Array[String]:
		mutex.lock()
		var result = errors.duplicate()
		mutex.unlock()
		return result
	
var assertions = 0
var failures = 0
var captures: String
var errors = ErrorCapture.new()

func _initialize() -> void:
	ProfileStore.test_mode = true
	OS.add_logger(errors)
	call_deferred("run_check")

func check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures += 1; printerr("FAIL: " + message)

func click(control: Control) -> void:
	var point = control.get_global_rect().get_center()
	for down in [true, false]:
		var event = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
	await process_frame
	await process_frame

func wait_ready(page) -> void:
	while Time.get_ticks_msec() < page.armed_at: await process_frame

func capture(name_value: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(captures.path_join(name_value + ".png")) == OK, "capture " + name_value)

func run_check() -> void:
	var args = OS.get_cmdline_user_args()
	if args.size() != 2 or args[0] != "--captures" or DisplayServer.get_name() == "headless": quit(2); return
	captures = args[1]
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(1371, 813)]:
		DisplayServer.window_set_size(dimensions)
		var app = load("res://scenes/app/app.tscn").instantiate()
		app.writer = SaveCoordinator.new("user://tests/run-promotion-graphics-%d/" % Time.get_ticks_usec())
		root.add_child(app)
		var p = app.writer.payload.duplicate(true)
		p.companions = ["lia", "milo"]
		check(app.writer.mutate(p, app.writer.revision(), app.writer.operation_id()), "graphical party selection")
		app.mount_saved_run(101)
		app.set_window_focused(true)
		app.run.set_physics_process(false)
		app.run.progression.collect_xp(1, 10500)
		app.run.choices.present(app.run)
		await process_frame
		await process_frame
		var page = app.modal_host.get_child(0)
		await wait_ready(page)
		check(page.hero_id == "aren" and page.panel.size.x <= 640 and page.panel.size.y <= 360 and paused, "live paused promotion fits viewport")
		check(page.branch_previews.size() == 2, "original sword previews retained")
		check(app.run.get_node("HUD/CombatHUD").xp_title.text == "RUN LEVEL 15", "paused HUD immediately reflects threshold")
		await capture("run-promotion-" + str(dimensions.x))
		if OS.has_feature("debug"):
			await click(app.debug_panel.launcher)
			check(app.debug_panel.overlay.visible and paused, "mouse DEV accessible over promotion")
			for down in [true, false]:
				var event = InputEventKey.new()
				event.physical_keycode = KEY_F9
				event.pressed = down
				Input.parse_input_event(event)
				Input.flush_buffered_events()
			await process_frame
			check(not app.debug_panel.overlay.visible and app.run.pause.is_blocked(), "F9 preserves promotion pause")
		var cancel_button = page.column.get_child(page.column.get_child_count() - 1)
		var scroll = page.column.get_parent()
		scroll.ensure_control_visible(cancel_button)
		await process_frame
		await click(cancel_button)
		while not app.run.choices.offer.is_empty(): app.run.choices.confirm(app.run, app.run.choices.offer_id, app.run.choices.offer[0])
		await process_frame
		await process_frame
		var hud = app.run.get_node("HUD/CombatHUD")
		check(hud.promotion_button.visible and not app.run.pause.is_blocked(), "cancel returns combat with reachable HUD reopen")
		await capture("run-promotion-deferred-" + str(dimensions.x))
		await click(hud.promotion_button)
		page = app.modal_host.get_child(0)
		await wait_ready(page)
		var branch_button = page.find_children("*", "Button", true, false).filter(func(button): return button.text.begins_with("Swordmaster"))[0]
		page.column.get_parent().ensure_control_visible(branch_button)
		await process_frame
		await click(branch_button)
		check(not page.confirm_button.disabled, "mouse branch selection enables run confirmation")
		page.column.get_parent().ensure_control_visible(page.confirm_button)
		await process_frame
		await click(page.confirm_button)
		check(app.run.hero.profession.id == &"swordmaster" and app.run.choices.promotion_hero == "lia", "mouse confirms branch and advances party")
		await capture("run-promotion-next-" + str(dimensions.x))
		app.free()
		paused = false
		await process_frame
	var drain_deadline = Time.get_ticks_msec() + 250
	while Time.get_ticks_msec() < drain_deadline: await process_frame
	for error in errors.snapshot(): check(false, error)
	OS.remove_logger(errors)
	print("RUN PROMOTION GRAPHICAL: %d assertions; %d failures; controlled input and captures" % [assertions, failures])
	quit(0 if failures == 0 else 1)
