extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	var f = Fixture.create(t, &"milo")
	var run = f.run
	var enemy = run.spawn_enemy(&"saltbound_thrall", run.hero.position + Vector2(80, 0))
	AttackExecutor.try_activate(run.hero, run, 0)
	run.hero.health.receive(5, 0, true)
	enemy.statuses.apply({"damage": 20.0, "burn": true, "frost": true}, 0)
	run.spawns.schedule_wave(run, 0)
	var frozen = [run.clock.tick, run.hero.position, run.hero.health.current, run.hero.next_ready, run.hero.health.invulnerable_until, enemy.position, enemy.statuses.next_burn, run.projectiles.get_child(0).position, run.spawns.reservations.size()]
	run.progression.collect_xp(900, 650)
	run.choices.present(run)
	var offer = run.choices.offer.duplicate()
	var identity = run.choices.offer_id
	t.check(run.pause.is_blocked() and offer.size() == 3, "level acquires pause and stable offer")
	run.toggle_manual_pause()
	for i in range(120): run.simulation.advance(run, Vector2.ONE)
	run.queue_hit(run.hero, 1000, Vector2.ZERO, 0, false, false)
	t.check(run.damage.requests.is_empty(), "paused callback cannot enqueue damage")
	t.check(frozen == [run.clock.tick, run.hero.position, run.hero.health.current, run.hero.next_ready, run.hero.health.invulnerable_until, enemy.position, enemy.statuses.next_burn, run.projectiles.get_child(0).position, run.spawns.reservations.size()], "all gameplay state freezes")
	run.choices.present(run)
	t.check(run.choices.offer == offer, "re-entry never resamples")
	t.check(not run.choices.confirm(run, identity, &"unknown"), "unoffered choice rejected")
	t.check(run.choices.confirm(run, identity, offer[0]), "one valid choice applied")
	t.check(not run.choices.confirm(run, identity, offer[0]), "old offer cannot be confirmed again")
	t.check(run.clock.tick == frozen[0] and run.progression.pending == 2, "no tick between queued levels")
	while run.progression.pending > 0:
		run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
	t.check(run.pause.is_blocked() and run.manual_token >= 0, "choice release preserves manual pause")
	run.toggle_manual_pause()
	run.simulation.advance(run, Vector2.ZERO)
	t.check(run.clock.tick == 1, "resume advances once without catch-up")
	Fixture.dispose(f)
	# Real mid-stage suspension: XP collection is not repeated on resume.
	f = Fixture.create(t)
	run = f.run
	var gem = f.catalog.scene("xp_gem").instantiate()
	gem.position = run.hero.position
	gem.value = 650
	gem.pickup_id = 700
	run.pickups.add_child(gem)
	run.simulation.advance(run, Vector2.ZERO)
	t.check(run.simulation.stage == 3 and run.clock.tick == 0, "stage suspended after XP before scheduling")
	while run.progression.pending > 0: run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
	run.simulation.advance(run, Vector2.ZERO)
	t.check(run.progression.level == 4 and run.progression.xp == 50 and run.clock.tick == 1, "resume suspended stage without duplicate pickup or tick")
	Fixture.dispose(f)
	await native_choice_queue(t)

func choice_screen(t,run):
	var screen=run.catalog.scene("level_up").instantiate()
	screen.run=run;screen.identity=run.choices.offer_id;screen.options=run.choices.offer.duplicate()
	t.root.add_child(screen);screen.armed_at=0
	screen.confirmed.connect(func(identity,id):run.choices.confirm(run,identity,id))
	return screen

func native_key(t,code: int) -> void:
	var event=InputEventKey.new();event.keycode=code;event.pressed=true
	t.root.push_input(event)
	await t.process_frame
	event=InputEventKey.new();event.keycode=code;event.pressed=false
	t.root.push_input(event)
	await t.process_frame

func native_choice_queue(t) -> void:
	var f=Fixture.create(t)
	var run=f.run
	run.progression.collect_xp(420000,650);run.choices.present(run)
	run.toggle_manual_pause()
	var event_token=run.pause.acquire("event","native-choice-test")
	var screen=choice_screen(t,run)
	await t.process_frame
	t.check(t.root.gui_get_focus_owner()==screen.cards[0].button,"nested native cards focus first option")
	var offer=run.choices.offer.duplicate();var identity=run.choices.offer_id
	var key=InputEventKey.new();key.keycode=KEY_1;key.pressed=true;key.echo=true
	screen._unhandled_key_input(key)
	key.echo=false;screen.armed_at=Time.get_ticks_msec()+180;screen._unhandled_key_input(key)
	t.check(run.choices.offer_id==identity and run.progression.pending==3,"echo and180ms gate cannot consume queued offers")
	screen.armed_at=0;key.keycode=KEY_ESCAPE;screen._unhandled_key_input(key)
	t.check(run.choices.offer==offer and run.pause.is_blocked(),"Esc cannot skip choice or release pause owners")
	await native_key(t,KEY_DOWN)
	t.check(t.root.gui_get_focus_owner()==screen.cards[1].button,"native arrow navigation reaches second nested card")
	await native_key(t,KEY_ENTER)
	t.check(run.progression.pending==2 and run.progression.stacks.get(offer[1],0)==1,"native Enter confirms exact focused Resource once")
	screen.cards[1].button.pressed.emit()
	t.check(run.progression.pending==2,"old consumed button cannot confirm next queued offer")
	screen.free()
	Input.action_press("ui_accept")
	screen=choice_screen(t,run)
	screen.cards[0].button.pressed.emit()
	t.check(screen.release_required and run.progression.pending==2,"new queued screen rejects held Enter")
	Input.action_release("ui_accept");screen._process(0)
	screen.cards[0].button.pressed.emit()
	t.check(run.progression.pending==1,"fresh click after release consumes one queued offer")
	screen.free();screen=choice_screen(t,run)
	key.keycode=KEY_3;key.echo=true;screen._unhandled_key_input(key)
	t.check(run.progression.pending==1,"held number repeat cannot consume fresh offer")
	key.echo=false;screen._unhandled_key_input(key)
	t.check(run.progression.pending==0 and run.clock.tick==0,"fresh number key completes queue without a simulation tick")
	t.check(run.pause.is_blocked() and run.manual_token>=0 and run.pause.tokens.has(event_token),"manual and event owners both survive choice closure")
	run.toggle_manual_pause()
	t.check(run.pause.is_blocked(),"manual close preserves event pause")
	run.pause.release(event_token,"native-choice-test")
	t.check(not run.pause.is_blocked(),"world resumes only after all pause owners release")
	screen.free();Fixture.dispose(f)
