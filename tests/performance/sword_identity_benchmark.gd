extends "res://tests/performance/benchmark_capture.gd"

# External measurement layer; original combat/healing paths are used unchanged.
var sword_windows: Array = []
var sword_inputs: Array = []
var sword_events: Array = []
var sword_frames: Array = []
var candidate: bool = false
var sword_ready: bool = false
var measurement_errors: Array = []

func _ready() -> void:
	if OS.has_feature("debug") or EngineDebugger.is_active() or AudioServer.get_driver_name() == "Dummy":
		printerr("FAIL: actual Release, no debugger and real audio required")
		get_tree().quit(2)
		return
	candidate = OS.get_environment("ABYSS_SWORD_CANDIDATE") == "yes"
	super._ready()
	if not is_instance_valid(run): return
	run.free()
	run = catalog.scene("expedition").instantiate()
	add_child(run)
	run.set_physics_process(false)
	var profile = ProfileData.fresh()
	profile.owned.aren = OwnedHero.record("aren", 1400, "swordmaster")
	profile.owned.brann = OwnedHero.record("brann", 1400, "abyss_swordsman")
	profile.owned.lia = OwnedHero.record("lia", 1400)
	profile.active = "aren"
	profile.companions = ["brann", "lia"]
	run.start(catalog, RosterService.snapshot(profile, 101))
	run.progression.level = 15
	assert(PromotionService.apply(run, "aren", "swordmaster"))
	assert(PromotionService.apply(run, "brann", "abyss_swordsman"))
	# Avoid exact overlap with the integer spawn/drop grid at radius zero.
	# This fixed external layout is shared by baseline/candidate, not a rule patch.
	for member in run.party: member.position += Vector2(0.25, 0.25)
	run.camera.position = run.hero.position.round()
	run.corruption.add(100)
	run.hero.stats.pickup_radius = 0
	for member in run.party: member.health.invulnerable_until = 2147483647
	fixture_xp = 0
	fixture_coins = 0
	gem_sequence = 1000000
	for index in range(12):
		sword_windows.append({"start": 1800 + 600 * index, "end": 2400 + 600 * index, "dual": 0, "spin": 0, "long": 0, "heal": 0, "rendered": {"dual": 0, "spin": 0, "long": 0, "heal": 0}})
	run.attack_committed.connect(on_sword_attack)
	sword_ready = true
	replenish()
	for i in range(2):
		var target = run.enemies[i + 1] # skip boss; original enemy AI still applies
		target.position = run.party[i].position + Vector2(24, 0)
		target.health = ActorHealth.new(1000000000)
	observed = workload()
	prior = Time.get_ticks_usec()
	started = prior
	RenderingServer.frame_post_draw.connect(on_sword_render)

func window_index(tick: int) -> int:
	return (tick - 1800) / 600 if tick >= 1800 and tick < 9000 else -1

func on_sword_attack(fact: Dictionary) -> void:
	var actor = run.actor_by_id(fact.source_id)
	if actor == null: return
	var index = window_index(fact.tick)
	if index < 0: return
	var kind = "dual" if actor.profession.id == &"swordmaster" else ("long" if actor.profession.id == &"abyss_swordsman" else "")
	if kind.is_empty(): return
	sword_windows[index][kind] += 1
	sword_events.append({"tick": fact.tick, "source_id": fact.source_id, "activation_id": fact.activation_id, "kind": kind})
	if kind == "dual" and fact.activation_id % actor.profession.fifth_interval == 0:
		sword_windows[index].spin += 1
		sword_events.append({"tick": fact.tick, "source_id": fact.source_id, "activation_id": fact.activation_id, "kind": "spin"})

func _physics_process(delta: float) -> void:
	if not sword_ready: return
	var brann = run.party[1]
	var tick = run.clock.tick
	if tick % 600 == 0 and not brann.health.dead:
		brann.health.current = brann.health.maximum - 10.0
		sword_inputs.append({"tick": tick, "source_id": brann.actor_id, "kind": "benchmark_missing_health", "health": brann.health.current})
	var before: float = brann.health.current
	var requests = run.damage.requests.duplicate(true)
	var consumed = run.activation_heals.duplicate()
	super._physics_process(delta)
	var healed: float = brann.health.current - before
	var index = window_index(tick)
	if index >= 0 and healed > 0:
		var accepted = requests.filter(func(hit): return hit.get("heal_source", -1) == brann.actor_id and not consumed.has(str(brann.actor_id) + ":" + str(hit.get("activation", -1))) and run.activation_heals.has(str(brann.actor_id) + ":" + str(hit.get("activation", -1))))
		if accepted.is_empty():
			workload_ok = false
			if measurement_errors.size() < 8: measurement_errors.append({"kind": "unattributed_positive_heal", "tick": tick, "actual_heal": healed, "requests": requests.size(), "before_keys": consumed.keys(), "after_keys": run.activation_heals.keys()})
		else:
			var hit = accepted[0]
			sword_windows[index].heal += 1
			sword_events.append({"tick": tick, "source_id": brann.actor_id, "activation_id": hit.activation, "request_id": hit.id, "kind": "heal", "actual_heal": healed})

func _process(delta: float) -> void:
	if sword_ready and capture_start >= 0 and measurement_errors.size() < 8:
		var c = observed
		var expected_xp = fixture_xp + run.kills * roundi(10 * run.corruption.modifiers().xp)
		if c.enemies != 100 or c.boss != 1 or c.effects < 30 or c.projectiles < 100 or c.gems != 500 or c.stored_xp != expected_xp or c.stored_coins != fixture_coins + run.kills or run.coins != 0:
			measurement_errors.append({"kind": "original_workload_guard", "tick": run.clock.tick, "observed": c.duplicate(true), "expected_xp": expected_xp, "expected_coins": fixture_coins + run.kills, "collected_coins": run.coins})
	super._process(delta)

func on_sword_render() -> void:
	if not sword_ready or not candidate: return
	var tick = run.clock.tick - 1
	var index = window_index(tick)
	if index < 0: return
	var found = {}
	var visible_rect = Rect2(run.camera.position - Vector2(320, 180), Vector2(640, 360))
	for effect in run.effects.get_children():
		if effect.is_queued_for_deletion() or not effect.is_visible_in_tree(): continue
		var fields = effect.get_property_list().map(func(item): return item.name)
		if not fields.has("sword_visual"): continue
		var visual = effect.get("sword_visual")
		if visual.is_empty() or run.clock.tick >= visual.expires_tick or not visible_rect.has_point(effect.position): continue
		if visual.arc_kind == "spin": found.spin = visual.activation_id
		elif visual.identity == "long": found.long = visual.activation_id
		elif visual.identity == "dual" and visual.arc_kind == "secondary": found.dual = visual.activation_id
	var feedback = run.get_node("CombatWorld/CombatFeedback")
	if feedback.get_property_list().any(func(item): return item.name == "heal_records"):
		for record in feedback.get("heal_records").values():
			var source = run.actor_by_id(record.source_id)
			if source != null and visible_rect.has_point(source.position) and run.clock.tick < record.expires_tick: found.heal = record.activation_id
	if not found.is_empty():
		for key in found: sword_windows[index].rendered[key] += 1
		sword_frames.append({"tick": tick, "frame": Engine.get_frames_drawn(), "activations": found})

func finish(now: int) -> void:
	for window in sword_windows:
		for key in ["dual", "spin", "long", "heal"]:
			if window[key] < (5 if key in ["dual", "long"] else 1): workload_ok = false
			if candidate and window.rendered[key] < 1: workload_ok = false
	super.finish(now)
	var path = output.path_join("%s-%d.json" % [milestone, seed_value])
	var summary = JSON.parse_string(FileAccess.get_file_as_string(path))
	summary["sword_windows"] = sword_windows
	summary["sword_inputs"] = sword_inputs
	summary["sword_layout"] = {"party_offset": [0.25, 0.25], "near_targets": "first two normals at party[0/1].position + (24,0)", "pickup_radius": 0, "temporary_upgrades": "none"}
	summary["sword_events"] = sword_events
	summary["sword_frames"] = sword_frames
	summary["measurement_errors"] = measurement_errors
	summary["sword_candidate"] = candidate
	summary["build_hash"] = OS.get_environment("ABYSS_SWORD_BUILD_HASH")
	summary["fixture_hash"] = OS.get_environment("ABYSS_SWORD_FIXTURE_HASH")
	summary["audio"] = {"driver": AudioServer.get_driver_name(), "device": AudioServer.output_device, "sample_rate": AudioServer.get_mix_rate(), "cue_count": run.combat_audio.allocator.accepted, "peak_voices": voice_peak}
	summary["capture_valid"] = workload_ok
	summary["human_or_reference_acceptance"] = false
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(summary, "", true, true))
	file.close()
	get_tree().quit(0 if workload_ok else 1)

func _exit_tree() -> void:
	if RenderingServer.frame_post_draw.is_connected(on_sword_render): RenderingServer.frame_post_draw.disconnect(on_sword_render)
