extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	var f = Fixture.create(t)
	var run = f.run
	var hud = run.get_node("HUD/CombatHUD")
	run.clock.tick = 32400
	run.hero.health.current = 73
	run.progression.xp = 55
	run.state_changed.emit()
	t.check(hud.values.text.contains("73 / 250") and hud.values.text.contains("55 / 100") and hud.values.text.contains("09:00") and hud.values.text.contains("101"), "HUD matches authoritative HP XP time seed")
	run.progression.collect_xp(1, 100)
	run.choices.present(run)
	var screen = f.catalog.scene("level_up").instantiate()
	screen.run = run
	screen.identity = run.choices.offer_id
	screen.options = run.choices.offer.duplicate()
	t.root.add_child(screen)
	var count = 0
	for node in screen.column.get_children():
		if node is Button: count += 1
	t.check(count == 3, "exactly three level buttons")
	t.check(t.root.get_viewport().gui_get_focus_owner() is Button, "keyboard focus is available")
	var event = InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	screen._unhandled_key_input(event)
	t.check(run.choices.offer.size() == 3, "Escape cannot dismiss upgrade")
	screen.free()
	Fixture.dispose(f)
