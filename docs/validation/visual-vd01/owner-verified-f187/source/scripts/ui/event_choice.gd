extends "res://scripts/ui/screen.gd"

signal confirmed(identity: int, choice: StringName)
var run
var offer: Dictionary = {}
var consumed: bool = false
var release_required: bool = true

func _ready() -> void:
	build(600)
	if run == null: return # Content smoke instantiation without an active offer.
	var definition = run.catalog.events[StringName(offer.kind)]
	label(definition.presentation, 23, Color(0.76, 0.61, 0.97))
	label("Aetheran Coast / ocean-cult relics stir beneath the surf.", 11)
	label("HP %.1f / %.1f · Coins %d · Corruption %d / 100" % [run.hero.health.current, run.hero.health.maximum, run.coins, run.corruption.value], 12)
	label("Power lasts this expedition and affects the living party.", 11)
	label("More corruption grants gem XP and makes future waves harder.", 11)
	for choice in definition.choices:
		var reason = EventEffects.unavailable(run, choice.id)
		var action = button(choice.presentation, func(): resolve(choice.id))
		action.disabled = reason != ""
		if reason != "": label(reason, 10, Color(1, 0.7, 0.5))
		if not action.disabled and get_viewport().gui_get_focus_owner() == null: action.grab_focus()
	label("[C] after closing: full corruption thresholds. No cost to leave.", 10)

func _process(_delta: float) -> void:
	if not Input.is_action_pressed("ui_accept"): release_required = false

func resolve(choice: StringName) -> void:
	if consumed or release_required or Time.get_ticks_msec() < armed_at: return
	if run == null or EventEffects.unavailable(run, choice) != "": return
	consumed = true
	confirmed.emit(int(offer.id), choice)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		resolve(&"leave" if offer.get("kind") == "mysterious_merchant" else &"decline")
		get_viewport().set_input_as_handled()
