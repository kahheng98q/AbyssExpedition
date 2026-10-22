extends SceneTree
class BenchmarkBase:
	extends Node
	
	var run
	var catalog: ContentCatalog
	var seed_value: int = 101
	var warmup: float = 30.0
	var capture: float = 120.0
	var times: Array[float] = []
	var prior: int = 0
	var milestone: String = "m2"
	var output: String = ""
	var smoke: bool = false
	var pacing_audio_mode: String = ""
	var pacing_diagnostic: bool = false
	var unfocused_samples: int = 0
	var capture_audio_start: int = 0
	var voice_peak: int = 0
	var vsync_on: bool = false
	var started: int = 0
	var capture_start: int = -1
	var capture_wall: int = 0
	var finish_tick: int = -1
	var fixture_xp: int = 0
	var fixture_coins: int = 0
	var gem_sequence: int = 1000000
	var observed: Dictionary = {}
	var workload_ok: bool = true
	var minimums: Dictionary = {}
	var maximums: Dictionary = {}
	var last_report_tick: int = 0
	var raw: Array[String] = ["seed,sample,tick,frame_ms,enemies,boss,effects,projectiles,gems,stored_xp,stored_coins,process_ms,physics_ms,draw_calls,nodes,memory_bytes,audio_cues,audio_voices"]
	
	func _ready() -> void:
		var args = OS.get_cmdline_user_args()
		var i = 0
		while i < args.size():
			match args[i]:
				"--diagnostic": pacing_diagnostic = true
				"--m4": milestone = "m4"
				"--smoke": smoke = true
				"--vsync-on": vsync_on = true
				"--pacing-audio":
					if i+1>=args.size() or args[i+1] not in ["enabled","disabled"]: get_tree().quit(2); return
					i+=1
					pacing_audio_mode=args[i]
				"--seed", "--output":
					if i + 1 >= args.size(): get_tree().quit(2); return
					i += 1
					if args[i - 1] == "--output": output = args[i]
					elif SeedStreams.valid_seed(args[i]): seed_value = args[i].to_int()
					else: get_tree().quit(2); return
				_: get_tree().quit(2); return
			i += 1
		if pacing_audio_mode != "":
			if smoke or seed_value!=101 or milestone!="m4" or OS.has_feature("debug") or EngineDebugger.is_active() or AudioServer.get_driver_name()=="Dummy":
				printerr("FAIL: pacing audio benchmark requires seed101/full M4/real audio/current Release without debugger")
				get_tree().quit(2); return
		elif pacing_diagnostic:
			get_tree().quit(2); return
		if smoke:
			warmup = 1.0
			capture = 2.0
		if output == "": output = "user://tests/benchmark-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()]
		if DirAccess.make_dir_recursive_absolute(output) != OK: get_tree().quit(1); return
		DisplayServer.window_set_size(Vector2i(1920, 1080))
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_on else DisplayServer.VSYNC_DISABLED)
		catalog = ContentCatalog.new()
		add_child(catalog)
		if not catalog.load_all(): get_tree().quit(1); return
		run = catalog.scene("expedition").instantiate()
		add_child(run)
		run.set_physics_process(false)
		var profile = ProfileData.fresh()
		profile.active = "milo"
		profile.companions = ["aren", "lia"]
		run.start(catalog, RosterService.snapshot(profile, seed_value))
		if pacing_audio_mode!="": run.combat_audio.set_enabled(pacing_audio_mode=="enabled")
		if milestone == "m4": run.corruption.add(100)
		run.hero.stats.pickup_radius = 0
		for member in run.party: member.health.invulnerable_until = 2147483647
		replenish()
		observed = workload()
		prior = Time.get_ticks_usec()
		started = prior
	
	func active_count(host: Node) -> int:
		var count = 0
		for item in host.get_children():
			if not item.is_queued_for_deletion(): count += 1
		return count
	
	func workload() -> Dictionary:
		var counts = {"enemies": 0, "boss": 0, "effects": active_count(run.effects), "projectiles": 0, "gems": 0, "stored_xp": 0, "stored_coins": 0, "audio_cues":run.combat_audio.allocator.accepted, "audio_voices":run.combat_audio.allocator.active_count()}
		for actor in run.enemies:
			if actor.health.dead: continue
			if actor.is_boss: counts.boss += 1
			else: counts.enemies += 1
		for shot in run.projectiles.get_children():
			if not shot.is_queued_for_deletion() and shot.speed > 0 and not shot.direction.is_zero_approx(): counts.projectiles += 1
		for gem in run.pickups.get_children():
			if gem.is_queued_for_deletion() or gem.collected: continue
			counts.gems += 1
			counts.stored_xp += gem.value
			counts.stored_coins += gem.coins
		return counts
	
	func replenish() -> void:
		var living = {"normals": 0, "boss": 0}
		for actor in run.enemies:
			if actor.health.dead: continue
			if actor.is_boss: living.boss += 1
			else: living.normals += 1
		if living.boss == 0:
			var boss = run.spawn_enemy(&"tidebound_hierophant", Vector2(48, 48), -1, true)
			boss.health = ActorHealth.new(1000000000)
		while living.normals < 100:
			var i = living.normals
			run.spawn_enemy(StringName(ContentCatalog.ENEMIES[i % 5]), Vector2(40 + i % 20 * 44, 60 + floori(i / 20.0) * 72))
			living.normals += 1
		while active_count(run.effects) < 30:
			var arc = catalog.scene("melee_arc").instantiate()
			arc.position = Vector2(80 + run.effects.get_child_count() % 10 * 48, 130)
			arc.expires = run.clock.tick + 600
			arc.reach = 16
			run.effects.add_child(arc)
		while active_count(run.projectiles) < 100:
			var shot = catalog.scene("projectile").instantiate()
			shot.run = run
			shot.position = Vector2(16, 420 + run.projectiles.get_child_count() % 16)
			shot.direction = Vector2.RIGHT
			shot.speed = 120
			shot.expires = run.clock.tick + 180
			run.projectiles.add_child(shot)
		while active_count(run.pickups) < 500:
			var gem = catalog.scene("xp_gem").instantiate()
			gem.position = Vector2(16 + gem_sequence % 30 * 30, 16 + floori((gem_sequence % 500) / 30.0) * 20)
			gem.pickup_id = gem_sequence
			gem_sequence += 1
			fixture_xp += gem.value
			fixture_coins += gem.coins
			run.pickups.add_child(gem)
		var retained = 0
		var recipient = null
		for gem in run.pickups.get_children():
			if gem.is_queued_for_deletion(): continue
			if recipient == null: recipient = gem
			retained += 1
			if retained > 500:
				recipient.value += gem.value
				recipient.coins += gem.coins
				gem.queue_free()
	
	func _physics_process(_delta: float) -> void:
		if run == null or (finish_tick >= 0 and run.clock.tick >= finish_tick): return
		if run.phase != "active":
			printerr("FAIL: benchmark expedition ended before capture completed")
			get_tree().quit(1)
			return
		if run.choices.event_token >= 0:
			var free = &"leave" if run.events.current.kind == "mysterious_merchant" else &"decline"
			run.choices.resolve_event(run, run.events.current.id, free)
		if run.rescue.state == "offered": run.choices.resolve_rescue(run, false)
		while not run.choices.offer.is_empty(): run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
		run.simulation.advance(run, Vector2.ZERO)
		replenish()
		observed = workload()
	
	func _process(_delta: float) -> void:
		if run == null: return
		var now = Time.get_ticks_usec()
		var frame_ms = (now - prior) / 1000.0
		prior = now
		if run.pause.is_blocked(): return
		if capture_start < 0:
			if run.clock.tick < roundi(warmup * 60): return
			capture_start = run.clock.tick
			finish_tick = capture_start + roundi(capture * 60)
			capture_wall = now
			capture_audio_start=run.combat_audio.allocator.accepted
			voice_peak=0
			last_report_tick = capture_start
			print("BENCH WARMUP COMPLETE seed=%d active=%.2fs" % [seed_value, capture_start / 60.0])
			return
		times.append(frame_ms)
		if not get_window().has_focus(): unfocused_samples += 1
		var c = observed
		voice_peak=maxi(voice_peak,c.audio_voices)
		if run.clock.tick - last_report_tick >= 1800:
			last_report_tick = run.clock.tick
			print("BENCH PROGRESS seed=%d captured_active=%.1f/%.1fs" % [seed_value, (run.clock.tick - capture_start) / 60.0, capture])
		for key in c:
			minimums[key] = mini(minimums.get(key, c[key]), c[key])
			maximums[key] = maxi(maximums.get(key, c[key]), c[key])
		workload_ok = workload_ok and c.enemies == 100 and c.boss == 1 and c.effects >= 30 and c.projectiles >= 100 and c.gems == 500
		var expected_xp = fixture_xp + run.kills * roundi(10 * run.corruption.modifiers().xp)
		workload_ok = workload_ok and c.stored_xp == expected_xp and c.stored_coins == fixture_coins + run.kills and run.coins == 0
		raw.append("%d,%d,%d,%.4f,%d,%d,%d,%d,%d,%d,%d,%.4f,%.4f,%d,%d,%d" % [seed_value, times.size(), run.clock.tick, frame_ms, c.enemies, c.boss, c.effects, c.projectiles, c.gems, c.stored_xp, c.stored_coins, Performance.get_monitor(Performance.TIME_PROCESS) * 1000, Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000, Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), Performance.get_monitor(Performance.OBJECT_NODE_COUNT), Performance.get_monitor(Performance.MEMORY_STATIC)])
		raw[-1] += ",%d,%d" % [c.audio_cues,c.audio_voices]
		if run.clock.tick >= finish_tick: finish(now)
	
	func finish(now: int) -> void:
		times.sort()
		var p95 = times[mini(times.size() - 1, floori(times.size() * 0.95))]
		var p99 = times[mini(times.size() - 1, floori(times.size() * 0.99))]
		var summary = {"seed": seed_value, "milestone": milestone, "smoke": smoke, "capture_valid": workload_ok, "frame_budget_pass": p95 <= 16.67 and p99 <= 25, "reference_acceptance": false, "latency_measured": false, "sample_count": times.size(), "warmup_active_seconds": capture_start / 60.0, "capture_active_seconds": (run.clock.tick - capture_start) / 60.0, "capture_wall_seconds": (now - capture_wall) / 1000000.0, "p50_ms": times[floori(times.size() * 0.5)], "p95_ms": p95, "p99_ms": p99, "max_ms": times.back(), "minimums": minimums, "maximums": maximums, "engine": Engine.get_version_info().string, "simulation": ReplayTrace.SIMULATION_VERSION, "catalog": catalog.digest, "debug_build": OS.has_feature("debug"), "renderer": RenderingServer.get_current_rendering_method(), "gpu": RenderingServer.get_video_adapter_name(), "os": OS.get_name() + " " + OS.get_version(), "processor": OS.get_processor_name(), "processor_count": OS.get_processor_count(), "window_observed": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y], "vsync_observed": DisplayServer.window_get_vsync_mode(), "debugger_active": EngineDebugger.is_active(), "fixture_rewards_preserved": workload_ok}
		if pacing_audio_mode!="":
			var audio_state={"enabled":pacing_audio_mode=="enabled","driver":AudioServer.get_driver_name(),"device":AudioServer.output_device,"sample_rate":AudioServer.get_mix_rate(),"cue_count":run.combat_audio.allocator.accepted-capture_audio_start,"peak_voices":voice_peak,"debug_build":OS.has_feature("debug"),"debugger_active":EngineDebugger.is_active(),"warmup":capture_start/60.0,"capture":(run.clock.tick-capture_start)/60.0,"samples":times.size(),"size":DisplayServer.window_get_size(),"vsync":DisplayServer.window_get_vsync_mode()}
			audio_state["same_machine_target"] = OS.get_processor_name().contains("5800H") and RenderingServer.get_video_adapter_name().contains("1650")
			var audio_error=audio_validation_error(audio_state, not pacing_diagnostic)
			summary["audio"]=audio_state
			summary["audio_mode"]=pacing_audio_mode
			summary["audio_validation_error"]=audio_error
			workload_ok=workload_ok and audio_error.is_empty()
			summary["capture_valid"]=workload_ok
			summary["reference_acceptance"]=false
			summary["same_machine_target"]=OS.get_processor_name().contains("5800H") and RenderingServer.get_video_adapter_name().contains("1650")
			summary["build_hash"] = OS.get_environment("ABYSS_PACING_BUILD_HASH")
			summary["fixture_hash"] = OS.get_environment("ABYSS_PACING_BENCHMARK_HASH")
			summary["diagnostic"] = pacing_diagnostic
		summary["engine_static_memory_available"] = Performance.get_monitor(Performance.MEMORY_STATIC) > 0
		summary["engine_pid"] = OS.get_process_id()
		summary["retained_hit_ids"] = run.damage.consumed.size()
		summary["kills"]=run.kills
		summary["window_focused_at_finish"]=get_window().has_focus()
		summary["focus_observation"] = {"samples":times.size(),"unfocused_samples":unfocused_samples,"fully_focused":unfocused_samples==0,"method":"Window.has_focus at every captured render frame"}
		summary["requests_created"] = run.request_id
		summary["engine_max_fps"] = Engine.max_fps
		summary["physics_ticks_per_second"] = Engine.physics_ticks_per_second
		var file = FileAccess.open(output.path_join("%s-%d.csv" % [milestone, seed_value]), FileAccess.WRITE)
		if file == null: get_tree().quit(1); return
		file.store_string("\n".join(raw))
		file.close()
		file = FileAccess.open(output.path_join("%s-%d.json" % [milestone, seed_value]), FileAccess.WRITE)
		if file == null: get_tree().quit(1); return
		file.store_string(JSON.stringify(summary, "  "))
		file.close()
		print("BENCH seed=%d samples=%d active=%.1fs p95=%.3f p99=%.3f capture_valid=%s budget_pass=%s debug_build=%s output=%s" % [seed_value, times.size(), summary.capture_active_seconds, p95, p99, workload_ok, summary.frame_budget_pass, summary.debug_build, ProjectSettings.globalize_path(output)])
		get_tree().quit(0 if workload_ok else 1)
	
	static func audio_validation_error(state: Dictionary, require_target: bool = true) -> String:
		if state.driver=="Dummy": return "real audio driver required"
		if require_target and not state.get("same_machine_target",false): return "SC007 target hardware required"
		if str(state.get("device","")).is_empty() or state.get("sample_rate",0)<=0: return "known real audio endpoint required"
		if state.debug_build or state.debugger_active: return "actual Release without debugger required"
		if state.warmup<30.0 or state.capture<120.0 or state.samples<=0: return "insufficient active sample duration"
		if state.size!=Vector2i(1920,1080) or state.vsync!=DisplayServer.VSYNC_DISABLED: return "wrong display/VSync"
		if state.peak_voices>8: return "voice budget exceeded"
		if state.enabled and (state.cue_count<=0 or state.peak_voices<=0): return "enabled comparison actually silent"
		if not state.enabled and (state.cue_count!=0 or state.peak_voices!=0): return "disabled comparison played audio"
		return ""
	
class SwordBenchmark:
	extends BenchmarkBase
	
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
	
func _initialize() -> void:
	call_deferred("begin")
func begin() -> void:
	root.add_child(SwordBenchmark.new())
