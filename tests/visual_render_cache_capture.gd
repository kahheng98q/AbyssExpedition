extends SceneTree
## Compare normal retained draw commands with an unconditional redraw reference.
var output: String
var records: Array = []
var failures: Array = []

func _initialize() -> void:
	call_deferred("run_capture")

func settle() -> void:
	for i in range(3): await process_frame
	await RenderingServer.frame_post_draw

func run_capture() -> void:
	var args = OS.get_cmdline_user_args()
	if not args.has("--output"): quit(2); return
	output = args[args.find("--output") + 1]
	DirAccess.make_dir_recursive_absolute(output)
	root.content_scale_size = Vector2i(640,360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	var catalog = ContentCatalog.new()
	root.add_child(catalog)
	if not catalog.load_all(): quit(1); return
	var run = catalog.scene("expedition").instantiate()
	root.add_child(run)
	run.set_physics_process(false)
	run.start(catalog,RunStartSnapshot.new(101,&"aren"))
	var crab = run.spawn_enemy(&"skittering_brinejaw",Vector2(540.25,270.75))
	var thrall = run.spawn_enemy(&"saltbound_thrall",Vector2(420.25,270.75))
	var actors = [run.hero, crab, thrall]
	var arc = catalog.scene("melee_arc").instantiate()
	arc.run = run
	arc.position = Vector2(490,290)
	arc.expires = 115
	run.effects.add_child(arc)
	for fallback in [false,true]:
		for step in range(18):
			run.clock.tick = 100 + step
			for actor in actors:
				actor.get_node("Presentation").force_fallback = fallback
				actor.position += Vector2(0.23,0.17)
				actor.velocity = Vector2(30,0) if step % 2 == 0 else Vector2.ZERO
				actor.aim = [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP][step % 4]
				actor.attack_until = 112
				actor.health.hurt_until = 106 if step < 8 else -1
				actor.health.invulnerable_until = 112
				actor.health.current = actor.health.maximum - step
				actor.corrupted = step % 3 == 0
				actor.ai_state = "warning" if step < 9 else "ready"
				actor.deadline = 109
				actor.health.dead = step >= 14
				actor.dead_at = 114 if step >= 14 else -1
			arc.force_fallback = fallback
			arc.direction = [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP][step % 4]
			arc.reach = 48 if step < 9 else 72
			arc.angle = 100 if step < 12 else 120
			arc.color = Color("a5f3e8") if step < 15 else Color("f37783")
			await settle()
			var cached = root.get_texture().get_image()
			for actor in actors: actor.get_node("Presentation").queue_redraw()
			arc.queue_redraw()
			await settle()
			var reference = root.get_texture().get_image()
			var matches = cached.get_data() == reference.get_data()
			var name_value = "%s-%02d" % ["fallback" if fallback else "sprite",step]
			records.append({"case":name_value,"tick":run.clock.tick,"exact_pixel_match":matches})
			if not matches:
				failures.append(name_value)
				cached.save_png(output.path_join(name_value+"-cached.png"))
				reference.save_png(output.path_join(name_value+"-redraw.png"))
	var file = FileAccess.open(output.path_join("manifest.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"kind":"controlled native rendered pixel equality, not human acceptance",
		"records":records,"failures":failures,"simulation_advanced":false},"\t"))
	file.close()
	print("RENDER CACHE pairs=%d failures=%d" % [records.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)
