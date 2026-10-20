extends RefCounted

func run(t) -> void:
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/combat-audio-%d/" % Time.get_ticks_usec())
	t.root.add_child(app)
	app.mount_run(RunStartSnapshot.new(101,&"aren"))
	app.run.set_physics_process(false)
	var has_audio = app.run.get_property_list().any(func(item): return item.name == "combat_audio")
	t.check(has_audio, "real expedition owns singleCombatAudio")
	if not has_audio: app.leave_run(); app.free(); return
	var r = app.run
	var audio = r.combat_audio
	t.check(audio.players.size()==8 and audio.get_parent()==r, "eight prebuilt realplayers owned byrun")
	for player in audio.players: t.check(player is AudioStreamPlayer and player.max_polyphony==1, "each player exactly onevoice")
	r.progression.collect_xp(999999,600)
	r.choices.present(r)
	t.check(audio.last_level_offer_id<0, "offer signal before UI mount cannot playlevel")
	await t.process_frame
	var first = r.choices.offer_id
	t.check(audio.last_level_offer_id==first and audio.allocator.snapshot()[0].busy, "mounted choice starts level reservedvoice")
	app.refresh_modal(app.generation)
	t.check(audio.upgrade_fifo.is_empty(), "refresh does not duplicate level")
	app.show_choice(first, r.choices.offer, app.generation-1)
	t.check(audio.last_level_offer_id==first, "old deferredgeneration ignored")
	for reason in ["focus","event","rescue","summary","debug"]:
		var token=r.pause.acquire(reason,"audio-all-token-test")
		t.check(audio.players[0].stream_paused, "nonlevel token freezes actual upgrade player: "+reason)
		var before=audio.allocator.accepted
		audio.on_damage({"generation":r.generation,"tick":0,"target_role":&"enemy","fatal":true})
		t.check(audio.allocator.accepted==before,"paused damage signal rejected: "+reason)
		r.pause.release(token,"audio-all-token-test")
		t.check(not audio.players[0].stream_paused,"removing only nonlevel token restores remaining phrase")
	var manual = r.pause.acquire("manual","audio-test")
	t.check(audio.players[0].stream_paused, "manual plus level freezes upgrade")
	r.choices.confirm(r,first,r.choices.offer[0])
	await t.process_frame
	t.check(audio.upgrade_fifo.size()==1, "rapid consecutive real choices enqueue FIFO")
	var accepted = audio.allocator.accepted
	audio.on_attack({"generation":r.generation,"tick":0,"source_id":0,"is_companion":false,"weapon_mode":&"arc","activation_id":1})
	t.check(audio.allocator.accepted==accepted, "signals during pause rejected withoutbacklog")
	r.pause.release(manual,"audio-test")
	t.check(not audio.players[0].stream_paused, "onlylevel allows remaining upgrade toresume")
	var audio_deadline = Time.get_ticks_msec()+2000
	while (not audio.upgrade_fifo.is_empty() or audio.allocator.snapshot()[0].busy) and Time.get_ticks_msec()<audio_deadline:
		await t.process_frame
	t.check(audio.upgrade_fifo.is_empty(), "finished plays presented FIFO in order")
	audio.set_enabled(false)
	audio.present_level(r.generation,999)
	t.check(audio.upgrade_fifo.is_empty() and audio.allocator.active_count()==0, "disabled audio never accumulates")
	audio.set_enabled(true)
	r.finish("abandonment")
	t.check(audio.disposed and audio.allocator.active_count()==0 and audio.upgrade_fifo.is_empty(), "finish stops and clearsall sessionstate")
	var old_generation=app.generation
	app.leave_run()
	app.mount_run(RunStartSnapshot.new(101,&"aren"))
	app.run.set_physics_process(false)
	var next_audio=app.run.combat_audio
	next_audio.on_attack({"generation":old_generation,"tick":0,"source_id":0,"is_companion":false,"weapon_mode":&"arc","activation_id":1})
	next_audio.present_level(old_generation,1000)
	t.check(next_audio.allocator.active_count()==0 and next_audio.last_level_offer_id<0,"late priorgeneration facts and level cannot cross restart")
	app.leave_run()
	app.free()
	t.paused=false
	await t.process_frame
