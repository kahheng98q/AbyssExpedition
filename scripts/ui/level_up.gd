extends "res://scripts/ui/screen.gd"

signal confirmed(offer_id: int, upgrade_id: StringName)
var run
var identity: int
var options: Array

func _ready() -> void:
	build(490)
	label("LEVEL UP  /  CHOOSE ONE", 24, Color(0.57, 0.93, 0.89))
	label("The world is paused. Your choice lasts for this expedition.")
	for i in options.size():
		var definition = run.catalog.upgrades[options[i]]
		var count = run.progression.stacks.get(definition.id, 0)
		var item = button("%d  %s  ·  %d taken\n%s" % [i + 1, definition.label, count, definition.effect_preview()], func(): confirmed.emit(identity, definition.id))
		item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		item.custom_minimum_size.y = 48
		if i == 0: item.grab_focus()
	label("Arrows + Enter or click. No reroll or skip.", 11)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and Time.get_ticks_msec() >= armed_at:
		var index = event.keycode - KEY_1
		if index >= 0 and index < options.size():
			get_viewport().set_input_as_handled()
			confirmed.emit(identity, options[index])
