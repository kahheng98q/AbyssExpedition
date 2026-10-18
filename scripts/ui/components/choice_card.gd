extends PanelContainer

signal chosen(offer_id: int, upgrade_id: StringName)
var offer_id: int
var upgrade_id: StringName
var effect_text: String
var heading: String
var stack_text: String
var slot: int
var button: Button

func configure(identity: int,index: int,definition: UpgradeDefinition,count: int) -> void:
	offer_id=identity
	upgrade_id=definition.id
	effect_text=definition.effect_preview()
	heading="%d  %s" % [index+1,definition.label]
	stack_text="%d / %d taken" % [count,definition.max_stacks] if definition.max_stacks>0 else "%d taken" % count
	slot=0 if definition.id==&"might" else 1 if definition.id==&"quick_hands" else 2 if definition.id==&"vitality" else 3

func _ready() -> void:
	button=load("res://scenes/ui/components/action_button.tscn").instantiate()
	button.custom_minimum_size.y=64
	add_child(button)
	var content=VBoxContainer.new()
	content.mouse_filter=MOUSE_FILTER_IGNORE
	content.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	content.offset_left=12;content.offset_right=-12;content.offset_top=6;content.offset_bottom=-6
	content.add_theme_constant_override("separation",2)
	button.add_child(content)
	var row=HBoxContainer.new()
	row.mouse_filter=MOUSE_FILTER_IGNORE
	content.add_child(row)
	var icon=load("res://scenes/ui/components/skill_icon.tscn").instantiate()
	row.add_child(icon)
	icon.set_slot(slot)
	var title=Label.new()
	title.text=heading
	title.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size",16)
	title.size_flags_horizontal=SIZE_EXPAND_FILL
	title.mouse_filter=MOUSE_FILTER_IGNORE
	row.add_child(title)
	var stacks=Label.new();stacks.text=stack_text;stacks.mouse_filter=MOUSE_FILTER_IGNORE;row.add_child(stacks)
	var effect=Label.new()
	effect.text=effect_text
	effect.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	effect.mouse_filter=MOUSE_FILTER_IGNORE
	content.add_child(effect)
	content.minimum_size_changed.connect(func():button.custom_minimum_size.y=maxf(64,content.get_combined_minimum_size().y+12))
	button.pressed.connect(func():chosen.emit(offer_id,upgrade_id))
