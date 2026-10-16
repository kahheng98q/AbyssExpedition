extends "res://scripts/ui/screen.gd"

signal closed
var run

func _ready() -> void:
	build(550)
	label("THE ABYSS  /  %d of 100" % (run.corruption.value if run != null else 0), 22)
	label("+5 corruption per active minute. Contracts offer power at a cost.", 12)
	label("25: +10% gem XP; future waves +10% enemies (rounded up).", 12)
	label("50: +20% gem XP; +10 points Broodmother / -10 Thrall*.", 12)
	label("75: +30% gem XP; future enemies deal +15% damage.", 12)
	label("100: +40% gem XP; waves +20%; boss adds a warned circle.", 12)
	label("*Can introduce Broodmothers early. Existing enemies stay fixed.", 10)
	label("All bonuses are totals. Old gems keep their XP. Corruption never kills.", 10)
	button("Return to expedition", func(): closed.emit()).grab_focus()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		# Closing synchronously detaches this control from its viewport.
		if Time.get_ticks_msec() >= armed_at: closed.emit()
