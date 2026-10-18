extends Control

var column: VBoxContainer
var panel: PanelContainer
var armed_at: int = 0

func build(width: float = 430) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	armed_at = Time.get_ticks_msec() + 180
	var tint = ColorRect.new()
	tint.color = Color(0.025, 0.05, 0.075, 0.95)
	tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(tint)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	panel = PanelContainer.new()
	panel.custom_minimum_size.x = width
	theme = load("res://data/themes/expedition_theme.tres")
	panel.theme_type_variation = &"ScreenPanel"
	center.add_child(panel)
	column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	panel.add_child(column)

func label(text: String, font_size: int = 12, color: Color = Color(0.78, 0.87, 0.9)) -> Label:
	var item = Label.new()
	item.text = text
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", color)
	column.add_child(item)
	return item

func build_scroll(width: float = 570) -> void:
	build(width)
	panel.remove_child(column)
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(width - 40, 294)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	panel.add_child(scroll)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(column)

func button(text: String, action: Callable) -> Button:
	var item = Button.new()
	item.text = text
	item.custom_minimum_size.y = 27
	item.add_theme_font_size_override("font_size", 12)
	item.pressed.connect(func():
		if Time.get_ticks_msec() >= armed_at: action.call())
	column.add_child(item)
	return item
