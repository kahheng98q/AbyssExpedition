extends SceneTree
## Real elapsed-time capture of controlled scenarios. Not a physical-display video.
var output: String
var app
var records: Array=[]
var segments: Array=[]
var failures: Array=[]
var observed: Array=[]
var speed
var clip_start: int

func _initialize() -> void:
	call_deferred("capture_run")

func movement(action: String="") -> void:
	for key in ["move_right","move_down","move_left","move_up"]:
		Input.action_release(key)
	if not action.is_empty():Input.action_press(action)

func actor_record(actor) -> Dictionary:
	if not is_instance_valid(actor):return {"exists":false}
	var view=actor.get_node("Presentation")
	var has_sprite=view.get("using_sprite")==true
	return {"exists":true,"id":str(actor.definition.id),"position":[actor.position.x,actor.position.y],"velocity":[actor.velocity.x,actor.velocity.y],"hp":actor.health.current,"dead":actor.health.dead,"dead_at":actor.dead_at,"attack_until":actor.attack_until,"hurt_until":actor.health.hurt_until,"deadline":actor.deadline,"ai_state":actor.ai_state,"using_sprite":has_sprite,"pose":str(view.sprite.animation) if has_sprite else "procedural","frame":view.sprite.frame if has_sprite else -1,"flip":view.get("facing_x") if has_sprite else null,"display_offset":[view.position.x,view.position.y]}

func segment(name_value: String,seconds: float,action: String="") -> void:
	movement(action)
	var run=app.run
	var begin=Time.get_ticks_usec()
	var start_tick=run.clock.tick
	var start_position=run.hero.position
	var next_sample=begin
	var first=records.size()
	while Time.get_ticks_usec()-begin<int(seconds*1000000):
		await process_frame
		if Time.get_ticks_usec()<next_sample:continue
		await RenderingServer.frame_post_draw
		var filename="frame-%04d.png" % records.size()
		var at=Time.get_ticks_usec()
		var snapshot={"segment":name_value,"image":filename,"elapsed_usec":at-clip_start,"segment_usec":at-begin,"tick":run.clock.tick,"hero":actor_record(run.hero),"actors":observed.map(actor_record),"paused":run.pause.is_blocked(),"engine_scale":Engine.time_scale,"physics_tick_rate":Engine.physics_ticks_per_second,"effects":run.effects.get_child_count(),"projectiles":run.projectiles.get_child_count(),"telegraphs":run.telegraphs.get_child_count()}
		if root.get_texture().get_image().save_png(output.path_join(filename))!=OK:failures.append("save "+filename)
		records.append(snapshot)
		next_sample=at+33333
	var row={"name":name_value,"seconds_requested":seconds,"elapsed_usec":Time.get_ticks_usec()-begin,"tick_start":start_tick,"tick_end":run.clock.tick,"frame_first":first,"frame_end_exclusive":records.size(),"input_action":action,"position_start":[start_position.x,start_position.y],"position_end":[run.hero.position.x,run.hero.position.y]}
	segments.append(row)
	if name_value=="manual-pause" and run.clock.tick!=start_tick:failures.append("paused tick advanced")
	if name_value.begins_with("move-") and run.hero.position.distance_to(start_position)<10:failures.append(name_value+" did not move")

func capture_run() -> void:
	var args=OS.get_cmdline_user_args()
	if not args.has("--output"):quit(2);return
	output=args[args.find("--output")+1]
	DirAccess.make_dir_recursive_absolute(output)
	root.content_scale_size=Vector2i(640,360)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch=Window.CONTENT_SCALE_STRETCH_INTEGER
	root.size=Vector2i(1280,720)
	app=load("res://scenes/app/app.tscn").instantiate()
	app.writer=SaveCoordinator.new("user://tests/visual-wallclock-%d/" % Time.get_ticks_usec())
	root.add_child(app);current_scene=app
	app.mount_run(RosterService.snapshot(ProfileData.fresh(),101))
	var run=app.run
	run.spawn_enemy(&"saltbound_thrall",run.hero.position+Vector2(110,0))
	run.spawn_enemy(&"skittering_brinejaw",run.hero.position+Vector2(-110,0))
	await process_frame
	clip_start=Time.get_ticks_usec()
	for action in ["right","down","left","up"]:
		await segment("move-"+action,0.8,"move_"+action)
	await segment("idle",0.4)
	run.toggle_manual_pause();app.refresh_modal()
	await segment("manual-pause",0.6)
	run.toggle_manual_pause();app.refresh_modal()
	await segment("resume",0.4)
	if OS.has_feature("debug"):
		speed=load("res://scripts/debug/battle_speed_controller.gd").new()
		if not speed.set_speed(2):failures.append("debug speed not set")
		await segment("source-debug-2x",0.7,"move_right")
		speed.reset()
		await segment("source-reset-1x",0.4,"move_left")
	# Separate unregistered observers: real run clock; explicitly injected pose events.
	# They never enter target selection, damage, drops or party logic.
	var observer=CharacterFactory.create(app.catalog.characters[&"aren"],run)
	observer.position=run.hero.position+Vector2(60,25);run.actors.add_child(observer)
	observed.append(observer)
	observer.attack_until=run.clock.tick+12
	await segment("controlled-attack-first",0.04)
	observer.health.hurt_until=run.clock.tick+2
	await segment("controlled-attack-hurt",0.035)
	await segment("controlled-attack-resume",0.12)
	observer.get_node("Presentation").hide()
	observer.attack_until=run.clock.tick+12
	await segment("controlled-late-hidden",0.10)
	observer.get_node("Presentation").show()
	await segment("controlled-late-visible",0.08)
	observer.attack_until=run.clock.tick-1
	await segment("controlled-expired-event",0.08)
	var crab=app.catalog.scene("enemy").instantiate()
	crab.setup(app.catalog.enemies[&"skittering_brinejaw"],-200,run)
	crab.position=run.hero.position+Vector2(-65,25);run.actors.add_child(crab);observed.append(crab)
	crab.ai_state="warning";crab.deadline=run.clock.tick+45
	run.create_warning(crab.position,"cone",105,Vector2.RIGHT,16,crab.deadline)
	await segment("controlled-warning",0.2)
	crab.health.hurt_until=run.clock.tick+2
	await segment("controlled-warning-hurt",0.035)
	await segment("controlled-warning-resume",0.2)
	observer.health.receive(observer.health.current+1,run.clock.tick,true)
	var dying=run.spawn_enemy(&"saltbound_thrall",run.hero.position+Vector2(100,25))
	dying.health.receive(dying.health.current+1,run.clock.tick,false)
	run.mark_dead(dying);observed.append(dying)
	var death_tick=run.clock.tick
	await segment("controlled-death-and-actual-enemy-cleanup",0.6)
	if is_instance_valid(dying) and run.clock.tick>death_tick+24:failures.append("enemy retained after cleanup deadline")
	if run.hero.get_node("Presentation").get("using_sprite")==true:
		if not records.any(func(row):return row.segment=="controlled-attack-hurt" and row.actors[0].pose=="hurt"):failures.append("two-tick hurt pose not captured")
		if not records.any(func(row):return row.segment=="controlled-late-visible" and row.actors[0].pose=="attack" and row.actors[0].frame>0):failures.append("late attack observation not captured")
		if records.any(func(row):return row.segment=="controlled-expired-event" and row.actors[0].pose=="attack"):failures.append("expired attack replayed")
	movement()
	var result={"kind":"REAL native viewport sampled against elapsed wall clock; controlled test, not physical display video or natural manual acceptance","seed":101,"engine":Engine.get_version_info().string,"debug_build":OS.has_feature("debug"),"renderer":RenderingServer.get_current_rendering_method(),"catalog_digest":app.catalog.digest,"native_size":[640,360],"requested_window":[1280,720],"segments":segments,"records":records,"failures":failures,"limits":"Natural engine physics/input action movement and manual pause; explicit observer state injection separately named. No physical input/display latency, window border capture, human score or frame-perfect natural session claimed. Source-only existing debug speed is not enabled in release."}
	var file=FileAccess.open(output.path_join("manifest.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"  "));file.close()
	app.free()
	print("WALLCLOCK CAPTURE records=%d segments=%d failures=%d" % [records.size(),segments.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)
