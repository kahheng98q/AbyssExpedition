extends PanelContainer
var message: String=""

func _ready() -> void:
	mouse_filter=MOUSE_FILTER_IGNORE
	var label=Label.new()
	label.text=message
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x=240
	label.add_theme_font_size_override("font_size",12)
	label.mouse_filter=MOUSE_FILTER_IGNORE
	add_child(label)
