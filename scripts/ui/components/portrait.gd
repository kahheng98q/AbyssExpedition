extends Control
var face: TextureRect
var fallback: Label
var last_identity: StringName
var last_profession: StringName

func _ready() -> void:
	mouse_filter=MOUSE_FILTER_IGNORE
	face=TextureRect.new()
	face.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	face.size=Vector2(24,24)
	face.mouse_filter=MOUSE_FILTER_IGNORE
	add_child(face)
	fallback=Label.new()
	fallback.add_theme_font_size_override("font_size",12)
	fallback.mouse_filter=MOUSE_FILTER_IGNORE
	add_child(fallback)

func set_identity(identity: StringName, profession: StringName) -> void:
	if identity==last_identity and profession==last_profession:return
	last_identity=identity
	last_profession=profession
	var path="res://assets/ui/aren_portrait_vd01.png"
	face.texture=load(path) if identity==&"aren" and profession==&"swordsman" and ResourceLoader.exists(path) else null
	fallback.text=String(identity).left(1).to_upper() if face.texture==null else ""
