extends "res://tests/performance/benchmark_capture.gd"

# Development fixture only. Original M4 fixture remains unchanged.
# Replenish approved base effects at their real lifetimes, never extend them.
func replenish() -> void:
	super.replenish()
	for arc in run.effects.get_children():
		if arc.reach == 16: arc.queue_free()
	var arcs = 0
	for arc in run.effects.get_children():
		if not arc.is_queued_for_deletion() and arc.reach == 48: arcs += 1
	while arcs < 30:
		var arc = catalog.scene("melee_arc").instantiate()
		arc.run = run
		arc.reach = 48
		arc.angle = 100
		arc.position = Vector2(120+arcs%10*48,180+floori(arcs/10.0)*72)
		arc.expires = run.clock.tick+10
		run.effects.add_child(arc)
		arcs += 1
	for shot in run.projectiles.get_children():
		if not shot.homing: shot.queue_free()
	var stars = 0
	for shot in run.projectiles.get_children():
		if not shot.is_queued_for_deletion() and shot.homing: stars += 1
	while stars < 100:
		var shot = catalog.scene("projectile").instantiate()
		shot.run = run
		shot.homing = true
		shot.speed = 180
		shot.reach = 160
		shot.position = Vector2(180+stars%10*48,150+floori(stars/10.0)*15)
		shot.direction = Vector2.RIGHT
		shot.expires = run.clock.tick+180
		run.projectiles.add_child(shot)
		stars += 1

func workload() -> Dictionary:
	var counts=super.workload()
	counts.new_arcs=0
	counts.new_stars=0
	counts.new_actors=0
	for arc in run.effects.get_children():
		if not arc.is_queued_for_deletion() and arc.get("using_sprite") == true: counts.new_arcs+=1
	for shot in run.projectiles.get_children():
		if not shot.is_queued_for_deletion() and shot.get("using_sprite") == true: counts.new_stars+=1
	for actor in run.party+run.enemies:
		if actor.get_node("Presentation").get("using_sprite") == true: counts.new_actors+=1
	counts.fallback_arcs=counts.effects-counts.new_arcs
	counts.fallback_stars=counts.projectiles-counts.new_stars
	counts.fallback_actors=run.party.size()+run.enemies.size()-counts.new_actors
	return counts

func _process(delta: float) -> void:
	if run != null and capture_start>=0 and OS.get_environment("ABYSS_VISUAL_MODE")=="after":
		var c=workload()
		workload_ok=workload_ok and c.new_arcs>=30 and c.new_stars>=100 and c.new_actors>0
	super._process(delta)
