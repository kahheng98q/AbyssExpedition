extends SceneTree
func _initialize() -> void:
	call_deferred("run_probe")
func measure(label: String) -> void:
	for i in range(20): await process_frame
	print("DRAW PROBE ", label, " calls=", Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), " process_ms=", Performance.get_monitor(Performance.TIME_PROCESS)*1000)
func run_probe() -> void:
	var bench = load("res://tests/performance/benchmark_capture.gd").new()
	root.add_child(bench)
	bench.set_physics_process(false)
	bench.set_process(false)
	await measure("full")
	bench.run.get_node("CombatWorld/CoastField").hide()
	await measure("no_field")
	bench.run.actors.hide()
	await measure("no_field_no_actors")
	bench.run.projectiles.hide()
	await measure("no_field_no_actors_no_projectiles")
	quit()
