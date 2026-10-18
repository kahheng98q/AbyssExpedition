extends SceneTree

var output: String
var mode: String
var records: Array = []
var failures: int = 0
var app

func _initialize() -> void:
	call_deferred("capture_run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)

func child_rectangles(node: Node,key: String,boxes: Dictionary) -> void:
	for child in node.get_children():
		if child is Control and child.is_visible_in_tree():
			var rect=child.get_global_rect()
			boxes[key+"/"+String(child.name)]=[rect.position.x,rect.position.y,rect.size.x,rect.size.y]
		child_rectangles(child,key+"/"+String(child.name),boxes)

func capture(name_value: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image = root.get_texture().get_image()
	check(image.save_png(output.path_join(name_value + ".png")) == OK, name_value)
	var hud = app.run.get_node("HUD/CombatHUD")
	var boxes = hud.layout_rectangles() if hud.has_method("layout_rectangles") else {}
	if hud.get("widgets") is Dictionary:
		for key in hud.widgets:
			if hud.widgets[key].visible:child_rectangles(hud.widgets[key],key,boxes)
	records.append({"name": name_value, "kind": "REAL Godot viewport capture; not a physical-window screenshot", "native_size": [image.get_width(), image.get_height()], "window_observed": [root.size.x, root.size.y], "tick": app.run.clock.tick, "seed": 101, "hero_position": [app.run.hero.position.x, app.run.hero.position.y], "camera": [app.run.camera.position.x, app.run.camera.position.y] if app.run.get("camera") != null else [480,270], "corruption": app.run.corruption.value, "hud_rects": boxes, "catalog_digest": app.catalog.digest})
	records[-1].party=app.run.party.map(func(actor):return {"id":String(actor.definition.id),"profession":String(actor.profession.id),"position":[actor.position.x,actor.position.y],"hp":actor.health.current,"dead":actor.health.dead})
	records[-1].enemies=app.run.enemies.map(func(actor):return {"id":String(actor.definition.id),"position":[actor.position.x,actor.position.y],"hp":actor.health.current,"dead":actor.health.dead,"state":actor.ai_state,"deadline":actor.deadline})
	records[-1].offer=app.run.choices.offer.duplicate()
	records[-1].fixture_input="no user movement; explicit state/tick samples defined in retained harness"
	records[-1].effects=app.run.effects.get_child_count()
	records[-1].projectiles=app.run.projectiles.get_child_count()
	var window_transform=root.get_final_transform()
	var screen_transform=root.get_screen_transform()
	records[-1].window_content_transform=[window_transform.x.x,window_transform.x.y,window_transform.y.x,window_transform.y.y,window_transform.origin.x,window_transform.origin.y]
	records[-1].screen_transform=[screen_transform.x.x,screen_transform.x.y,screen_transform.y.x,screen_transform.y.y,screen_transform.origin.x,screen_transform.origin.y]
	records[-1].window_position=[root.position.x,root.position.y]

func extended(run) -> void:
	for upgraded in [false,true]:
		var arc=run.catalog.scene("melee_arc").instantiate()
		arc.run=run;arc.position=run.hero.position;arc.direction=Vector2.RIGHT;arc.expires=run.clock.tick+10
		arc.reach=72 if upgraded else 48
		run.effects.add_child(arc)
		var star=run.catalog.scene("projectile").instantiate()
		star.run=run;star.position=run.party[2].position+Vector2(-30,-30);star.homing=true;star.expires=run.clock.tick+180
		star.profession=run.catalog.professions[&"elemental_sage"] if upgraded else run.catalog.professions[&"mage"]
		run.projectiles.add_child(star)
		await capture("effects-upgraded-fallback-1280" if upgraded else "effects-approved-1280")
		records[-1].selectors={"arc_new_sprite":arc.using_sprite,"star_new_sprite":star.using_sprite,"reach":arc.reach,"promotion":upgraded}
		check(arc.using_sprite==not upgraded and star.using_sprite==not upgraded,"effect selector at draw time")
		arc.free();star.free()
	var field=run.get_node("CombatWorld/CoastField")
	field.force_fallback=true;field.queue_redraw()
	for actor in run.party+run.enemies:actor.get_node("Presentation").force_fallback=true
	await capture("fallback-complete-1280")
	field.force_fallback=false;field.queue_redraw()
	for actor in run.party+run.enemies:actor.get_node("Presentation").force_fallback=false
	var original=run.hero.profession
	run.hero.profession=run.catalog.professions[&"swordmaster"]
	run.state_changed.emit()
	await capture("promoted-aren-procedural-1280")
	run.hero.profession=original
	var definition=run.hero.definition
	run.hero.definition=run.catalog.characters[&"brann"]
	run.state_changed.emit()
	await capture("brann-procedural-1280")
	run.hero.definition=definition
	run.state_changed.emit()
	var base=run.clock.tick
	DirAccess.make_dir_recursive_absolute(output.path_join("motion"))
	for i in range(60):
		var tick=base+i*2
		run.clock.tick=tick
		run.hero.aim=[Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP][i/15]
		run.hero.velocity=run.hero.aim*96
		if i%15==0:
			run.hero.attack_until=tick+12
			var arc=run.catalog.scene("melee_arc").instantiate()
			arc.run=run;arc.position=run.hero.position;arc.direction=run.hero.aim;arc.expires=tick+10
			run.effects.add_child(arc)
			var shot=run.catalog.scene("projectile").instantiate()
			shot.run=run;shot.homing=true;shot.speed=180;shot.position=run.party[2].position;shot.expires=tick+180
			run.projectiles.add_child(shot)
		if i%15==3:run.hero.health.hurt_until=tick+2
		for shot in run.projectiles.get_children():
			if not shot.is_queued_for_deletion():shot.simulate(tick)
		run.cleanup_effects(tick)
		await capture("motion/frame-%03d" % i)
	run.hero.velocity=Vector2.ZERO;run.hero.attack_until=-1;run.hero.health.hurt_until=-1;run.clock.tick=base
	await recognition(run)

func recognition(run) -> void:
	# Frozen G1 recognition-01 fixture. These are controlled engine renders,
	# not an ordinary play session, timing measurement or human result.
	var thralls=[Vector2(206,175),Vector2(415,249),Vector2(260,170),Vector2(354,180),Vector2(383,220),Vector2(190,259),Vector2(476,279),Vector2(310,283)]
	var crabs=[Vector2(438,172),Vector2(242,260),Vector2(270,217),Vector2(367,258),Vector2(454,237),Vector2(215,218)]
	var offset=Vector2(160,90)
	run.hero.position=Vector2(320,208)+offset;run.hero.aim=Vector2.RIGHT
	run.camera.position=Vector2(480,270);run.camera.force_update_scroll()
	run.party[1].position=Vector2(279,231)+offset
	run.party[2].position=Vector2(358,247)+offset;run.party[2].health.dead=false
	run.boss_actor.position=Vector2(493,211)+offset
	for actor in run.enemies.duplicate():
		if actor!=run.boss_actor:
			run.enemies.erase(actor);run.registry.erase(actor.actor_id);actor.free()
	for child in run.telegraphs.get_children():child.free()
	for child in run.effects.get_children():child.free()
	for child in run.projectiles.get_children():child.free()
	for condition in ["normal","dense","max-corruption"]:
		if condition!="max-corruption":
			for i in (2 if condition=="normal" else 6):
				var index=i if condition=="normal" else i+2
				run.spawn_enemy(&"saltbound_thrall",thralls[index]+offset)
			for i in (2 if condition=="normal" else 4):
				var index=i if condition=="normal" else i+2
				run.spawn_enemy(&"skittering_brinejaw",crabs[index]+offset)
		var corruption=0 if condition=="normal" else 50 if condition=="dense" else 100
		run.corruption.add(corruption-run.corruption.value)
		run.create_warning(Vector2(493,211)+offset,"circle",62,Vector2.RIGHT,70,99999)
		run.create_warning(Vector2(413,205)+offset,"circle",52,Vector2.RIGHT,70,99999)
		DirAccess.make_dir_recursive_absolute(output.path_join("recognition/"+condition))
		var arc_expires=-1
		for i in range(60):
			run.clock.tick=32445+i*2
			run.cleanup_effects(run.clock.tick)
			if run.clock.tick>arc_expires:
				var arc=run.catalog.scene("melee_arc").instantiate();arc.run=run;arc.position=run.hero.position;arc.direction=Vector2.RIGHT;arc.expires=run.clock.tick+10;arc_expires=arc.expires;run.hero.attack_until=run.clock.tick+12;run.effects.add_child(arc)
			while run.projectiles.get_child_count()<2:
				var shot=run.catalog.scene("projectile").instantiate();shot.run=run;shot.homing=true;shot.speed=180;shot.position=[Vector2(304,246),Vector2(393,236)][run.projectiles.get_child_count()]+offset;shot.expires=run.clock.tick+180;run.projectiles.add_child(shot)
			await capture("recognition/%s/frame-%03d" % [condition,i])
		for child in run.telegraphs.get_children():child.free()
		for child in run.effects.get_children():child.free()
		for child in run.projectiles.get_children():child.free()
	run.clock.tick=32445

func capture_run() -> void:
	var args = OS.get_cmdline_user_args()
	check(args.has("--output") and args.has("--mode"), "explicit output and before/after required")
	if failures: quit(2); return
	output = args[args.find("--output") + 1]
	mode = args[args.find("--mode") + 1]
	check(mode in ["before", "phase-4", "after"], "known mode")
	check(DirAccess.make_dir_recursive_absolute(output) == OK, "capture directory")
	root.content_scale_size = Vector2i(640,360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(1371,779)]:
		root.size = dimensions
		app = load("res://scenes/app/app.tscn").instantiate()
		app.writer = SaveCoordinator.new("user://tests/visual-%s-%d-%d/" % [mode, dimensions.x, Time.get_ticks_usec()])
		root.add_child(app)
		current_scene = app
		var payload = ProfileData.fresh()
		payload.companions = ["lia", "milo"]
		app.writer.payload.companions = payload.companions.duplicate()
		app.mount_run(RosterService.snapshot(payload,101))
		var run = app.run
		run.set_physics_process(false)
		run.clock.tick = 32445
		for corruption in [0,100]:
			run.corruption.add(corruption-run.corruption.value)
			for i in range(14):
				if i >= run.enemies.size(): run.spawn_enemy(&"saltbound_thrall" if i%2==0 else &"skittering_brinejaw", Vector2(280+i%7*58,180+floori(i/7.0)*120))
			if run.boss_actor == null: run.spawn_enemy(&"tidebound_hierophant", Vector2(650,270), -1, true)
			run.boss_actor.deadline=0
			BossController.decide(run.boss_actor,run,run.clock.tick)
			run.party[2].health.dead = true
			run.rescue.state = "defending"
			run.rescue.elapsed = 1080
			run.state_changed.emit()
			await capture("combat-c%d-%d" % [corruption,dimensions.x])
		for state in ["succeeded","failed","declined"]:
			run.rescue.state=state
			run.state_changed.emit()
			await capture("rescue-%s-%d" % [state,dimensions.x])
		if mode != "before":
			var spots=[Vector2(10,270),Vector2(950,270),Vector2(480,10),Vector2(480,530),Vector2(10,10),Vector2(950,10),Vector2(10,530),Vector2(950,530)]
			for i in spots.size():
				run.hero.position=spots[i]
				run.camera.position=spots[i].round()
				run.camera.reset_smoothing()
				run.camera.force_update_scroll()
				run.rescue.state="defending"
				run.state_changed.emit()
				var near_warning=run.create_warning(run.hero.position+Vector2(20,20),"circle",32,Vector2.RIGHT,70,99999)
				await capture("edge-%d-%d" % [i,dimensions.x])
				near_warning.free()
			run.hero.position=Vector2(480,270);run.camera.position=run.hero.position
			run.camera.force_update_scroll();run.state_changed.emit()
		run.progression.collect_xp(999001,100)
		run.choices.present(run)
		app.show_choice(run.choices.offer_id,run.choices.offer)
		await capture("level-up-%d" % dimensions.x)
		if mode=="after" and dimensions.x==1280:
			app.clear_host(app.modal_host);run.pause.cancel_all()
			await extended(run)
		app.free()
		paused = false
		await process_frame
	var f=FileAccess.open(output.path_join("capture-manifest.json"),FileAccess.WRITE)
	f.store_string(JSON.stringify({"mode":mode,"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_current_rendering_method(),"profile":"isolated user://tests only","records":records,"failures":failures},"  "))
	f.close()
	print("VISUAL CAPTURE mode=%s records=%d failures=%d" % [mode,records.size(),failures])
	quit(0 if failures==0 else 1)
