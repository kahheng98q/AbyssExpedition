extends SceneTree

class Benchmark:
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
	var raw: Array[String] = ["seed,sample,tick,frame_ms,enemies,boss,effects,projectiles,gems,stored_xp,stored_coins,process_ms,physics_ms,draw_calls,nodes,memory_bytes"]
	
	func _ready() -> void:
		var args = OS.get_cmdline_user_args()
		var i = 0
		while i < args.size():
			match args[i]:
				"--m4": milestone = "m4"
				"--smoke": smoke = true
				"--vsync-on": vsync_on = true
				"--seed", "--output":
					if i + 1 >= args.size(): get_tree().quit(2); return
					i += 1
					if args[i - 1] == "--output": output = args[i]
					elif SeedStreams.valid_seed(args[i]): seed_value = args[i].to_int()
					else: get_tree().quit(2); return
				_: get_tree().quit(2); return
			i += 1
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
		var counts = {"enemies": 0, "boss": 0, "effects": active_count(run.effects), "projectiles": 0, "gems": 0, "stored_xp": 0, "stored_coins": 0}
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
			last_report_tick = capture_start
			print("BENCH WARMUP COMPLETE seed=%d active=%.2fs" % [seed_value, capture_start / 60.0])
			return
		times.append(frame_ms)
		var c = observed
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
		if run.clock.tick >= finish_tick: finish(now)
	
	func finish(now: int) -> void:
		times.sort()
		var p95 = times[mini(times.size() - 1, floori(times.size() * 0.95))]
		var p99 = times[mini(times.size() - 1, floori(times.size() * 0.99))]
		var summary = {"seed": seed_value, "milestone": milestone, "smoke": smoke, "capture_valid": workload_ok, "frame_budget_pass": p95 <= 16.67 and p99 <= 25, "reference_acceptance": false, "latency_measured": false, "sample_count": times.size(), "warmup_active_seconds": capture_start / 60.0, "capture_active_seconds": (run.clock.tick - capture_start) / 60.0, "capture_wall_seconds": (now - capture_wall) / 1000000.0, "p50_ms": times[floori(times.size() * 0.5)], "p95_ms": p95, "p99_ms": p99, "max_ms": times.back(), "minimums": minimums, "maximums": maximums, "engine": Engine.get_version_info().string, "simulation": ReplayTrace.SIMULATION_VERSION, "catalog": catalog.digest, "debug_build": OS.has_feature("debug"), "renderer": RenderingServer.get_current_rendering_method(), "gpu": RenderingServer.get_video_adapter_name(), "os": OS.get_name() + " " + OS.get_version(), "processor": OS.get_processor_name(), "processor_count": OS.get_processor_count(), "window_observed": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y], "vsync_observed": DisplayServer.window_get_vsync_mode(), "debugger_active": EngineDebugger.is_active(), "fixture_rewards_preserved": workload_ok}
		summary["engine_static_memory_available"] = Performance.get_monitor(Performance.MEMORY_STATIC) > 0
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
	

func _initialize() -> void:
	root.add_child(Benchmark.new())
