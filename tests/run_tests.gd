extends SceneTree

var failures: int = 0
var assertions: int = 0
var suite: String = "unit"
var error_capture = preload("res://tests/error_capture.gd").new()
class TestWatchdog extends Node:
	var deadline: int = Time.get_ticks_msec() + 55000
	func _process(_delta: float) -> void:
		if Time.get_ticks_msec() >= deadline:
			printerr("FAIL: test watchdog expired")
			get_tree().quit(3)
const SUITES = {
	"run_promotion": ["res://tests/integration/test_run_promotion.gd"],
	"combat_audio": ["res://tests/unit/test_voice_allocator.gd", "res://tests/integration/test_audio_facts.gd", "res://tests/integration/test_combat_audio.gd", "res://tests/unit/test_audio_content.gd"],
	"pacing": ["res://tests/integration/test_pacing.gd", "res://tests/unit/test_waves.gd", "res://tests/integration/test_choice_pause.gd", "res://tests/integration/test_replay.gd"],
	"combat_feedback": ["res://tests/unit/test_combat_feedback.gd"],
	"integration_m4": ["res://tests/unit/test_corruption.gd", "res://tests/integration/test_corruption_combat.gd", "res://tests/unit/test_events.gd", "res://tests/integration/test_m4_chapter.gd"],
	"integration_m3": ["res://tests/integration/test_m3_rescue.gd", "res://tests/integration/test_m3_draws.gd"],
	"recruitment": ["res://tests/unit/test_rescue.gd", "res://tests/unit/test_recruitment.gd", "res://tests/unit/test_m3_passives.gd"],
	"debug_panel": ["res://tests/integration/test_debug_panel.gd"],
	"progression": ["res://tests/unit/test_permanent_progression.gd"],
	"persistence": ["res://tests/integration/test_persistence_v1.gd", "res://tests/integration/test_persistence_v3.gd"],
	"abilities": ["res://tests/unit/test_promotion.gd", "res://tests/unit/test_profession_abilities.gd", "res://tests/unit/test_companions.gd"],
	"integration_m2": ["res://tests/integration/test_m2_party.gd", "res://tests/integration/test_m2_app.gd", "res://tests/integration/test_promotion_preview.gd"],
	"unit": ["res://tests/unit/test_benchmark_contract.gd", "res://tests/unit/test_configured_upgrades.gd", "res://tests/unit/test_content_contract.gd", "res://tests/unit/test_combat.gd", "res://tests/unit/test_waves.gd", "res://tests/unit/test_run_upgrades.gd", "res://tests/unit/test_run_outcomes.gd", "res://tests/unit/test_seed_streams.gd"],
	"scene_smoke": ["res://tests/scenes/test_scene_smoke.gd", "res://tests/scenes/test_m1_ui.gd"],
	"integration_m1": ["res://tests/integration/test_choice_pause.gd", "res://tests/integration/test_m1_loop.gd"],
	"replay": ["res://tests/integration/test_replay.gd"]
	,"full_run": ["res://tests/integration/test_full_run.gd"]
}

func _initialize() -> void:
	ProfileStore.test_mode = true
	OS.add_logger(error_capture)
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func run() -> void:
	root.add_child(TestWatchdog.new())
	var args = OS.get_cmdline_user_args()
	var i = 0
	while i < args.size():
		if args[i] == "--suite" and i + 1 < args.size():
			i += 1
			suite = args[i]
		elif args[i] == "--seed" and i + 1 < args.size():
			i += 1
			if not SeedStreams.valid_seed(args[i]):
				printerr("Invalid seed")
				quit(2)
				return
		else:
			printerr("Unknown/missing argument: " + args[i])
			quit(2)
			return
		i += 1
	if not SUITES.has(suite):
		printerr("Unknown suite: " + suite)
		quit(2)
		return
	if SUITES[suite].is_empty():
		printerr("Suite has no registered fixtures")
		quit(2)
		return
	for path in SUITES[suite]:
		var script = load(path)
		if script == null or not script.can_instantiate():
			check(false, "missing/invalid fixture " + path)
			continue
		var fixture = script.new()
		await fixture.run(self)
	# AudioServer releases stopped native playback on its mixer thread. Allow its
	# shutdown work to finish even when --fixed-fps accelerates test frames.
	var mix_deadline = Time.get_ticks_msec() + 250
	while Time.get_ticks_msec() < mix_deadline: await process_frame
	for error in error_capture.snapshot(): check(false, "engine/script error: " + error)
	OS.remove_logger(error_capture)
	print("SUITE %s: %d assertions; %d failures; 0 skipped" % [suite, assertions, failures])
	quit(0 if failures == 0 else 1)
