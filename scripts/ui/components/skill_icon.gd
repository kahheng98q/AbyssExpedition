extends TextureRect

func _ready() -> void:
	custom_minimum_size=Vector2(16,16)
	expand_mode=EXPAND_IGNORE_SIZE
	stretch_mode=STRETCH_KEEP_ASPECT_CENTERED
	mouse_filter=MOUSE_FILTER_IGNORE

func set_slot(index: int) -> void:
	var path="res://assets/ui/slice_icons_vd01.png"
	if not ResourceLoader.exists(path):return
	var atlas=AtlasTexture.new()
	atlas.atlas=load(path)
	atlas.region=Rect2(clampi(index,0,5)*16,0,16,16)
	texture=atlas
