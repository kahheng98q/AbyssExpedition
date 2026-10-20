extends SceneTree

var app
var output: String
var started_unix: float
var started_utc: String
var started: int
var events: Array=[]
var failures: Array=[]
var label: String=""
var peak_voices: int=0
var errors=preload("res://tests/error_capture.gd").new()

func _initialize() -> void:
	ProfileStore.test_mode=true
	OS.add_logger(errors)
	call_deferred("run")

func mark(kind: String, fact: Dictionary={}) -> void:
	events.append({"wall_ms":Time.get_ticks_msec()-started,"scenario":label,"kind":kind,"fact":fact.duplicate(true)})

func wait_wall(seconds: float) -> void:
	var deadline=Time.get_ticks_msec()+roundi(seconds*1000)
	while Time.get_ticks_msec()<deadline: await process_frame

func mount(hero: StringName) -> void:
	app.set_window_focused(true)
	app.mount_run(RunStartSnapshot.new(101,hero))
	app.run.combat_audio.cue_started.connect(func(cue,index):
		peak_voices=maxi(peak_voices,app.run.combat_audio.allocator.active_count())
		mark("cue_started",{"cue":cue,"slot_index":index,"generation":app.run.generation,"tick":app.run.clock.tick}))
	app.run.attack_committed.connect(func(fact): mark("attack_committed",fact))
	app.run.damage_accepted.connect(func(fact): mark("damage_accepted",fact))

func run() -> void:
	var args=OS.get_cmdline_user_args()
	if args.size()!=2 or args[0]!="--output": quit(2); return
	output=args[1]
	if AudioServer.get_driver_name()=="Dummy":
		FileAccess.open(output.path_join("audio-blocked.json"),FileAccess.WRITE).store_string(JSON.stringify({"status":"BLOCKED","reason":"real audio driver unavailable; Dummy is not capture acceptance"}))
		quit(3); return
	started=Time.get_ticks_msec()
	started_utc=Time.get_datetime_string_from_system(true)
	started_unix=Time.get_unix_time_from_system()
	app=load("res://scenes/app/app.tscn").instantiate()
	app.writer=SaveCoordinator.new("user://tests/audio-capture-%d/" % started)
	root.add_child(app)
	for hero in [&"aren",&"lia",&"milo"]:
		label="normal-"+String(hero)
		mount(hero)
		app.run.spawn_enemy(&"shellbound_husk",app.run.hero.position+Vector2(30,0))
		mark("scenario_start")
		await wait_wall(4.0)
		mark("scenario_end")
		app.leave_run()
	label="synthetic-eight-voice-mix"
	mount(&"aren")
	var r=app.run
	r.set_physics_process(false)
	for repeat in 3:
		r.combat_audio.stop_players()
		for index in 7:
			var slot=r.combat_audio.allocator.request("hero_hurt",repeat*30+index,r.generation)
			r.combat_audio.start_player(slot,"hero_hurt")
		r.combat_audio.allocator.claim_level(r.clock.tick,r.generation)
		r.combat_audio.start_player(0,"level")
		mark("stress_started",{"voices":r.combat_audio.allocator.active_count()})
		await wait_wall(0.5)
	label="negative-facts-pause-restart"
	r.combat_audio.stop_players()
	r.hero.health.invulnerable_until=1000
	r.queue_hit(r.hero,999,Vector2.ZERO,0,false,false)
	r.damage.resolve_tick_hits(r,0)
	if r.combat_audio.allocator.accepted!=0: failures.append("invulnerable_false_cue")
	var victim=r.spawn_enemy(&"saltbound_thrall",r.hero.position+Vector2(30,0))
	r.queue_hit(victim,999,Vector2.RIGHT,0,false,false)
	r.queue_hit(victim,999,Vector2.RIGHT,0,false,false)
	r.damage.resolve_tick_hits(r,0)
	if r.combat_audio.allocator.accepted!=1: failures.append("fatal_double_cue")
	var token=r.pause.acquire("manual","capture")
	var accepted=r.combat_audio.allocator.accepted
	r.attack_committed.emit({"generation":r.generation,"tick":1,"source_id":0,"is_companion":false,"weapon_mode":&"arc","activation_id":999})
	if r.combat_audio.allocator.accepted!=accepted: failures.append("paused_false_cue")
	await wait_wall(0.3)
	r.pause.release(token,"capture")
	await wait_wall(0.3)
	# Real mounted upgrade; programmatic XP is diagnostic only, never natural timing.
	r.progression.collect_xp(888888,100)
	r.choices.present(r)
	await process_frame
	mark("upgrade_mounted",{"offer":r.choices.offer_id})
	await wait_wall(0.4)
	r.finish("abandonment")
	await process_frame
	await wait_wall(0.4)
	mount(&"milo")
	app.run.set_physics_process(false)
	if app.run.combat_audio.allocator.active_count()!=0: failures.append("cross_run_voice")
	await wait_wall(0.4)
	app.leave_run()
	app.free()
	paused=false
	await wait_wall(0.25)
	for error in errors.snapshot(): failures.append(error)
	OS.remove_logger(errors)
	var file=FileAccess.open(output.path_join("audio-events.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"driver":AudioServer.get_driver_name(),"device":AudioServer.output_device,"sample_rate":AudioServer.get_mix_rate(),"engine":Engine.get_version_info().string,"simulation":ReplayTrace.SIMULATION_VERSION,"started_utc":started_utc,"started_unix":started_unix,"peak_voices":peak_voices,"events":events,"failures":failures,"limitation":"controlled scenarios and synthetic worst-case mix; listening/identification still require humans"},"\t"))
	file.close()
	print("AUDIO CAPTURE SCENARIOS: peak_voices=%d failures=%s" % [peak_voices,failures])
	quit(0 if failures.is_empty() and peak_voices==8 else 1)
