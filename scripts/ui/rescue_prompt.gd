extends "res://scripts/ui/screen.gd"

signal resolved(accepted: bool)
var owned: bool = false
var consumed: bool = false

func _ready() -> void:
	build(500)
	label("A LIGHT IN THE SURF", 23, Color(0.57, 0.93, 0.89))
	label("Sera needs your help. Defend her position for 30 active seconds.", 12)
	label("Stay inside the marked 96-pixel circle, centered where you accept.", 11)
	label("Leaving once or dying fails. Combat and normal waves continue.", 11)
	label("Reward: " + ("1 recruitment ticket (Sera already owned)." if owned else "Sera, a Mage with Guiding Light."), 12)
	label("Earned on success; saved at victory or defeat. Abandon grants nothing.", 10)
	button("Accept rescue", func(): resolve(true)).grab_focus()
	button("Decline / Escape", func(): resolve(false))

func resolve(accepted: bool) -> void:
	if consumed: return
	consumed = true
	resolved.emit(accepted)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE and Time.get_ticks_msec() >= armed_at:
		resolve(false)
		get_viewport().set_input_as_handled()
