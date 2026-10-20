extends SceneTree

var failures: int=0
var assertions: int=0
var captures: String
var errors=preload("res://tests/error_capture.gd").new()

func _initialize() -> void:
	ProfileStore.test_mode=true
	OS.add_logger(errors)
	call_deferred("run")

func check(value: bool, message: String) -> void:
	assertions+=1
	if not value: failures+=1; printerr("FAIL: "+message)

func capture(name_value: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(captures.path_join(name_value+".png"))==OK,"saved "+name_value)

func f9() -> void:
	for pressed in [true,false]:
		var event=InputEventKey.new()
		event.keycode=KEY_F9
		event.physical_keycode=KEY_F9
		event.pressed=pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()

func run() -> void:
	var args=OS.get_cmdline_user_args()
	if args.size()!=2 or args[0]!="--captures": quit(2); return
	captures=args[1]
	root.content_scale_size=Vector2i(640,360)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
	var app=load("res://scenes/app/app.tscn").instantiate()
	app.writer=SaveCoordinator.new("user://tests/pacing-graphics-%d/" % Time.get_ticks_usec())
	root.add_child(app)
	var panel=app.debug_panel
	app.set_window_focused(false)
	app.mount_run(RunStartSnapshot.new(101,&"aren"))
	app.run.set_physics_process(false)
	check(app.focus_token>0 and app.run.clock.tick==0,"start unfocused blocks initialtick")
	app.set_window_focused(true)
	var r=app.run
	r.spawns.schedule_wave(r,0)
	check(not r.pause.is_blocked() and r.spawns.reservations.size()==4,"focus recovery preserves opening")
	await capture("opening")
	r.progression.collect_xp(999999,300)
	r.choices.present(r)
	await process_frame
	check(r.combat_audio.last_level_offer_id==r.choices.offer_id,"actual mounted level dispatched")
	var level_id=r.combat_audio.last_level_offer_id
	app.show_choice(level_id-1,r.choices.offer.duplicate(),app.generation)
	app.show_choice(level_id,r.choices.offer.duplicate(),app.generation-1)
	check(r.combat_audio.last_level_offer_id==level_id,"old offer and generation rejected")
	app.refresh_modal()
	check(r.combat_audio.upgrade_fifo.is_empty(),"refresh does not replay")
	var level_token=r.choices.pause_token
	app.set_window_focused(false)
	check(r.combat_audio.players[0].stream_paused,"focus freezes level voice immediately")
	app.set_window_focused(true)
	check(r.pause.tokens.has(level_token) and not r.combat_audio.players[0].stream_paused,"focus releases only its token")
	f9()
	await process_frame
	check(panel.overlay.visible and r.pause.is_blocked(),"F9 reaches protected panel over choice")
	await capture("choice-dev")
	f9()
	await process_frame
	check(not panel.overlay.visible and r.pause.tokens.has(level_token),"F9 close preserves level pause")
	while not r.choices.offer.is_empty():
		r.choices.confirm(r,r.choices.offer_id,r.choices.offer[0])
		await process_frame
	await capture("resumed")
	r.finish("abandonment")
	await process_frame
	check(app.run==null and app.debug_panel==panel,"results retain App-owned debug singleinstance")
	app.mount_run(RunStartSnapshot.new(101,&"aren"))
	app.run.set_physics_process(false)
	check(app.run.combat_audio.allocator.active_count()==0 and app.debug_panel==panel,"restart has no crossrun voices and samepanel")
	await capture("restart")
	app.free()
	paused=false
	var deadline=Time.get_ticks_msec()+250
	while Time.get_ticks_msec()<deadline: await process_frame
	for error in errors.snapshot(): check(false,error)
	OS.remove_logger(errors)
	print("PACING AUDIO GRAPHICAL: %d assertions; %d failures" % [assertions,failures])
	quit(0 if failures==0 else 1)
