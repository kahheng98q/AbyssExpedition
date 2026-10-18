extends "res://tests/performance/benchmark_capture.gd"

# Short, development-only ablation. Never substitutes for the frozen M4/P02 gates.
var probe_mode: String = OS.get_environment("ABYSS_COST_MODE")
var physics_costs: Array[float] = []

func _ready() -> void:
	super._ready()
	warmup = 2.0
	capture = 8.0
	if probe_mode not in ["baseline", "world-hidden", "presenters-off", "both"]:
		get_tree().quit(2)
		return
	run.get_node("CombatWorld").visible = probe_mode not in ["world-hidden", "both"]

func replenish() -> void:
	super.replenish()
	# Visit the same population in every variant, including new spawns.
	for actor in run.party + run.enemies:
		actor.get_node("Presentation").set_process(probe_mode not in ["presenters-off", "both"])

func _physics_process(delta: float) -> void:
	var start = Time.get_ticks_usec()
	super._physics_process(delta)
	physics_costs.append((Time.get_ticks_usec() - start) / 1000.0)

func finish(now: int) -> void:
	physics_costs.sort()
	var actors = []
	for actor in run.party + run.enemies:
		actors.append([actor.actor_id, actor.position, actor.health.current, actor.health.dead,
			actor.next_ready, actor.attack_until, actor.aim, actor.ai_state, actor.deadline])
	var shots = []
	for shot in run.projectiles.get_children():
		if not shot.is_queued_for_deletion():
			shots.append([shot.position, shot.direction, shot.target_id, shot.expires, shot.hit_ids])
	var gameplay = {"tick": run.clock.tick, "actors": actors, "shots": shots,
		"spawns": run.trace.spawns, "kills": run.kills, "requests": run.request_id,
		"consumed": run.damage.consumed, "rewards": workload()}
	var result = {"mode": probe_mode, "diagnostic_only": true, "acceptance": false,
		"physics_callback_samples": physics_costs.size(),
		"physics_callback_p50_ms": physics_costs[physics_costs.size() / 2],
		"physics_callback_p95_ms": physics_costs[floori(physics_costs.size() * 0.95)],
		"gameplay_observation_sha256": var_to_bytes(gameplay).hex_encode().sha256_text(),
		"gameplay_observation": var_to_str(gameplay)}
	var file = FileAccess.open(output.path_join("probe.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(result, "\t"))
	file.close()
	super.finish(now)
