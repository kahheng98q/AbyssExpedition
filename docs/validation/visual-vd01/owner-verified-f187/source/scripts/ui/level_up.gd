extends "res://scripts/ui/screen.gd"

signal confirmed(offer_id: int, upgrade_id: StringName)
var run
var identity: int
var options: Array
var cards: Array = []
var consumed: bool = false
var release_required: bool = false

func _ready() -> void:
	build_scroll(490)
	var scroll=column.get_parent() as ScrollContainer
	scroll.custom_minimum_size=Vector2(450,304)
	column.add_theme_constant_override("separation",4)
	label("A MOMENT OF RESOLVE",20,Color("d6ae68"))
	label("World paused · This expedition only",12)
	for i in options.size():
		var definition=run.catalog.upgrades[options[i]]
		var card=load("res://scenes/ui/components/choice_card.tscn").instantiate()
		card.configure(identity,i,definition,run.progression.stacks.get(definition.id,0))
		column.add_child(card)
		card.chosen.connect(_submit)
		cards.append(card)
		if i==0:card.button.grab_focus()
	label("1 / 2 / 3 · Arrows + Enter · Click · No reroll / skip",12)
	release_required=Input.is_action_pressed("ui_accept")

func _process(_delta: float) -> void:
	if not Input.is_action_pressed("ui_accept"):release_required=false

func _submit(offer_id: int,upgrade_id: StringName) -> void:
	if consumed or release_required or Time.get_ticks_msec()<armed_at:return
	consumed=true
	for card in cards:card.button.disabled=true
	confirmed.emit(offer_id,upgrade_id)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var index=event.keycode-KEY_1
		if index>=0 and index<options.size():
			get_viewport().set_input_as_handled()
			_submit(identity,options[index])
