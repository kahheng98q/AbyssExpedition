extends Node2D

@export var tile_set: TileSet
@export var props: Texture2D
@export var corruption_texture: Texture2D
var overlay: Node2D
var prop_detail: Sprite2D

func is_complete() -> bool:
	return tile_set!=null and tile_set.has_source(0) and props!=null and corruption_texture!=null and props.get_size()==Vector2(256,96) and corruption_texture.get_size()==Vector2(256,96)

func _ready() -> void:
	if not is_complete():return
	var ground=TileMapLayer.new();ground.name="Ground";ground.z_index=-30;ground.tile_set=tile_set;ground.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(ground)
	for y in range(16):
		for x in range(30):
			var index=(x*17+y*31)%4+(8 if y>=13 else 0)
			if y<13 and (x*17+y*31)%19==0:index=4+(x+y)%4
			ground.set_cell(Vector2i(x,y),0,Vector2i(index%4,index/4))
	# World height remains540: final source row is cropped to28px.
	var atlas=tile_set.get_source(0) as TileSetAtlasSource
	for x in range(30):
		var strip=Sprite2D.new();strip.centered=false;strip.texture=atlas.texture;strip.region_enabled=true;strip.region_rect=Rect2(0,64,32,28);strip.position=Vector2(x*32,512);strip.z_index=-30;add_child(strip)
	var decorations=Node2D.new();decorations.name="Props";decorations.z_index=-10;add_child(decorations)
	var regions=[Rect2(0,0,64,96),Rect2(64,0,32,64),Rect2(96,0,32,64),Rect2(128,0,32,64),Rect2(160,0,32,64),Rect2(192,0,32,64)]
	# Central-camera positions retain the six approved concept landmarks.
	var locations=[Vector2(600,150),Vector2(192,164),Vector2(244,294),Vector2(699,342),Vector2(303,202),Vector2(752,397)]
	for i in regions.size():
		var piece=Sprite2D.new();piece.centered=false;piece.texture=props;piece.region_enabled=true;piece.region_rect=regions[i];piece.position=locations[i];decorations.add_child(piece)
	# Painted prop detail shares its prop's depth, separate from ground corruption.
	prop_detail=Sprite2D.new();prop_detail.name="CorruptionDetail";prop_detail.centered=false;prop_detail.texture=corruption_texture;prop_detail.region_enabled=true;prop_detail.region_rect=regions[0];prop_detail.position=locations[0];decorations.add_child(prop_detail)
	overlay=Node2D.new();overlay.name="Corruption";overlay.z_index=-20;add_child(overlay)
	for at in [Vector2(224,192),Vector2(672,288),Vector2(432,336)]:
		var growth=Sprite2D.new();growth.centered=false;growth.texture=corruption_texture;growth.region_enabled=true;growth.region_rect=Rect2(0,64,64,32);growth.position=at;overlay.add_child(growth)
	set_corruption(0)

func set_corruption(value: int) -> void:
	if overlay!=null:overlay.modulate.a=clampf(value/100.0,0,1)*0.6
	if prop_detail!=null:prop_detail.modulate.a=clampf(value/100.0,0,1)
