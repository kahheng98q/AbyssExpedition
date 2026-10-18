extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	print("FIXTURE test_visual_ui")
	var path="res://scenes/ui/components/value_bar.tscn"
	t.check(ResourceLoader.exists(path),"VD01 native ValueBar delivered")
	if not ResourceLoader.exists(path): return
	var value=load(path).instantiate()
	t.root.add_child(value)
	value.set_value("HP",-3,0)
	t.check(value.caption.text.contains("-3 / 0") and value.fill.value==0,"zero maximum safe; exact negative label is not clamped")
	value.set_value("XP",150,100)
	t.check(value.caption.text.contains("150 / 100") and value.fill.value==100,"only graphical ratio clamped")
	value.free()
	var f=Fixture.create(t)
	var run=f.run
	run.clock.tick=32445
	run.hero.health.current=73
	run.progression.xp=55
	run.state_changed.emit()
	var hud=run.get_node("HUD/CombatHUD")
	t.check(hud.hp_value.caption.text.contains("73 / 250") and hud.xp_value.caption.text.contains("55 / 100"),"native HUD values authoritative")
	var before=[run.clock.tick,run.hero.health.current,run.progression.xp,run.coins,run.corruption.value]
	for i in range(4):hud.refresh()
	t.check(before==[run.clock.tick,run.hero.health.current,run.progression.xp,run.coins,run.corruption.value],"HUD refresh has no gameplay side effects")
	var original=run.hero.definition
	run.hero.definition=original.duplicate()
	run.hero.definition.display_name="Aren of the Saltbound Coastal Expedition"
	hud.refresh()
	t.check(hud.hero_label.text.ends_with("Hero Lv 1") and hud.hero_label.text.contains("…"),"long HUD name elides without hiding exact permanent level")
	t.check(hud.values.text.contains(run.hero.definition.display_name),"compatibility value snapshot preserves full name")
	var pause_screen=f.catalog.scene("pause_menu").instantiate()
	pause_screen.run=run;t.root.add_child(pause_screen)
	t.check(pause_screen.column.get_child(2).text==run.hero.definition.display_name,"existing pause details preserve full hero identity")
	pause_screen.free();run.hero.definition=original;hud.refresh()
	run.progression.collect_xp(774,650)
	run.choices.present(run)
	var screen=f.catalog.scene("level_up").instantiate()
	screen.run=run
	screen.identity=run.choices.offer_id
	screen.options=run.choices.offer.duplicate()
	t.root.add_child(screen)
	t.check(screen.cards.size()==3,"exact three native choice cards")
	for i in range(3):
		var d=f.catalog.upgrades[screen.options[i]]
		t.check(screen.cards[i].upgrade_id==d.id and screen.cards[i].effect_text==d.effect_preview(),"choice Resource ID/order/effect preserved")
	var emitted=[]
	screen.confirmed.connect(func(offer,id):emitted.append([offer,id]))
	var e=InputEventKey.new();e.keycode=KEY_1;e.pressed=true
	screen.armed_at=Time.get_ticks_msec()+180
	screen._unhandled_key_input(e)
	t.check(emitted.is_empty(),"180ms guard")
	screen.armed_at=0;e.echo=true
	screen._unhandled_key_input(e)
	t.check(emitted.is_empty(),"held/repeat edge rejected")
	e.echo=false;screen._unhandled_key_input(e);screen._unhandled_key_input(e)
	t.check(emitted.size()==1 and emitted[0]==[screen.identity,screen.options[0]],"one signal only; same offer cannot double submit")
	screen.free()
	Fixture.dispose(f)
