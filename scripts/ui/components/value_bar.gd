extends Control

var caption: Label
var fill: ProgressBar
var fill_style: StyleBoxFlat

func _ready() -> void:
	mouse_filter=MOUSE_FILTER_IGNORE
	custom_minimum_size=Vector2(80,20)
	caption=Label.new()
	caption.add_theme_font_size_override("font_size",12)
	caption.mouse_filter=MOUSE_FILTER_IGNORE
	add_child(caption)
	fill=ProgressBar.new()
	fill.show_percentage=false
	fill.mouse_filter=MOUSE_FILTER_IGNORE
	fill.position=Vector2(0,17)
	fill.size=Vector2(size.x,3)
	fill.add_theme_font_size_override("font_size",1)
	fill_style=StyleBoxFlat.new()
	fill.add_theme_stylebox_override("fill",fill_style)
	add_child(fill)
	resized.connect(func():fill.size=Vector2(size.x,3))

func set_value(label_value: String, current, maximum, tint: Color=Color("79d4ae")) -> void:
	caption.text="%s %s / %s" % [label_value,str(current),str(maximum)]
	fill.max_value=maximum if maximum>0 else 1.0
	fill.value=clampf(current,0,maximum) if maximum>0 else 0.0
	fill_style.bg_color=tint
