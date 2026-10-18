extends Label

func _ready() -> void:
	add_theme_font_size_override("font_size",12)
	mouse_filter=MOUSE_FILTER_IGNORE

func set_status(value: String, critical: bool=false) -> void:
	text=value
	add_theme_color_override("font_color",Color("f37783") if critical else Color("b8c6d1"))
