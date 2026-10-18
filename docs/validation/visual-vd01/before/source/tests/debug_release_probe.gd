extends SceneTree

class CaptureErrors extends Logger:
	var errors: Array[String] = []
	func _log_error(_function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _backtraces: Array[ScriptBacktrace]) -> void:
		if error_type != Logger.ERROR_TYPE_WARNING: errors.append("%s:%d %s %s" % [file, line, code, rationale])

var assertions: int = 0
var failures: int = 0
var capture_errors = CaptureErrors.new()

func _initialize() -> void:
	OS.add_logger(capture_errors)
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func run() -> void:
	check(not OS.has_feature("debug"), "probe executes an actual release template")
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/debug-release-%d-%d/" % [OS.get_process_id(), Time.get_ticks_usec()])
	root.add_child(app)
	current_scene = app
	app.mount_run(RunStartSnapshot.new(101, &"aren"))
	app.run.set_physics_process(false)
	check(app.debug_panel == null, "release app never mounts developer UI")
	check(app.find_child("OpenDebugPanel", true, false) == null and not root.title.contains("Developer Build"), "release has no debug launcher or developer title")
	var event = InputEventKey.new()
	event.keycode = KEY_F9
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	check(app.debug_panel == null and not app.run.pause.is_blocked(), "F9 cannot open or pause release gameplay")
	event = InputEventKey.new()
	event.physical_keycode = KEY_F9
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	check(app.debug_panel == null and not app.run.pause.is_blocked(), "physical F9 cannot open or pause release gameplay")
	var bytes = app.writer.store.read(app.writer.store.generations()[0].path)
	var service = load("res://scripts/debug/debug_action_service.gd").new()
	service.bind(app)
	check(not service.ensure_session().ok and service.writer == null, "release cannot create a debug save session")
	# Deliberately forge controller state: native feature checks still reject actions.
	service.active = true
	service.writer = app.writer
	for action in ["level_max", "materials", "spawn", "boss", "kill_all", "god_mode", "restart", "test_branch"]:
		check(not service.execute(action, {"character_id": "aren", "branch": "swordmaster"}).ok, "release action denied " + action)
	check(not service._materials({"materials": 100}).ok and not service._level_one({}).ok and not service.promote("aren", "swordmaster", app.writer.revision()).ok, "direct debug mutation entry points deny release use")
	check(bytes == app.writer.store.read(app.writer.store.generations()[0].path), "release denial leaves save unchanged")
	var speed = load("res://scripts/debug/battle_speed_controller.gd").new()
	check(not speed.set_speed(4) and Engine.time_scale == 1 and Engine.physics_ticks_per_second == 60, "release speed controls denied")
	speed.captured = true
	speed.prior_time_scale = 4
	speed.prior_tick_rate = 240
	speed.reset()
	check(Engine.time_scale == 1 and Engine.physics_ticks_per_second == 60, "forged speed restoration state has no release effect")
	var health = ActorHealth.new(100)
	health.debug_invincible = true
	health.debug_god_mode = true
	check(health.receive(10, 0, true) and health.current == 90, "forged debug health flags have no effect in release")
	var forged_ui = load("res://scenes/debug/debug_panel.tscn").instantiate()
	forged_ui.app = app
	root.add_child(forged_ui)
	await process_frame
	check(not is_instance_valid(forged_ui), "manually instantiating hidden UI in release cannot enable it")
	app.free()
	await process_frame
	paused = false
	for error in capture_errors.errors: check(false, error)
	OS.remove_logger(capture_errors)
	print("DEBUG RELEASE: %d assertions; %d failures; 0 skipped" % [assertions, failures])
	quit(0 if failures == 0 else 1)
