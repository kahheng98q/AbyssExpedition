class_name VisualSet
extends Resource

@export var id: StringName
@export var silhouette: String = "diamond"
@export var palette: Color = Color.WHITE
@export var idle: String = "procedural_idle"
@export var move: String = "procedural_move"
@export var attack: String = "procedural_attack"
@export var hurt: String = "procedural_hurt"
@export var death: String = "procedural_death"
@export var directional_flip: bool = true
@export var sprite_frames: SpriteFrames
@export var canvas_px: Vector2i = Vector2i(32,48)
@export var anchor_px: Vector2i = Vector2i(16,40)
@export var style_revision: String = ""
@export_enum("hero","enemy") var actor_kind: String = "hero"
@export var contact_only: bool = false
@export var warning_only: bool = false

func validate() -> String:
	for component in [palette.r, palette.g, palette.b, palette.a]:
		if not is_finite(component): return "nonfinite palette component"
	if silhouette not in ["diamond", "sword", "bow", "star", "crab", "lantern", "shell", "tentacles", "triangle", "crown"]: return "unregistered silhouette"
	for state in [idle, move, attack, hurt, death]:
		if state.is_empty(): return "missing visual state"
	if sprite_frames != null: return validate_frames()
	return ""

func validate_frames() -> String:
	if canvas_px.x<=0 or canvas_px.y<=0 or anchor_px.x<0 or anchor_px.y<0 or anchor_px.x>=canvas_px.x or anchor_px.y>=canvas_px.y:return "invalid canvas/anchor"
	if style_revision.is_empty():return "missing sprite revision"
	var minima={"idle":2 if actor_kind=="hero" else 1,"move":4 if actor_kind=="hero" else 2,"hurt":1,"death":4 if actor_kind=="hero" else 3}
	if not contact_only:minima["warning" if warning_only else "attack"]=1 if actor_kind=="enemy" else 3
	for state in minima:
		if not sprite_frames.has_animation(state) or sprite_frames.get_frame_count(state)<minima[state]:return "missing/incomplete state: "+state
	for state in sprite_frames.get_animation_names():
		var seen={}
		for i in sprite_frames.get_frame_count(state):
			var texture=sprite_frames.get_frame_texture(state,i)
			if not texture is AtlasTexture or texture.atlas==null:return "missing atlas texture"
			var r=texture.region
			if r.size!=Vector2(canvas_px) or r.position!=r.position.round() or not Rect2(Vector2.ZERO,texture.atlas.get_size()).encloses(r):return "invalid atlas region"
			var key=texture.atlas.resource_path+str(r)
			if seen.has(key):return "duplicate frame region"
			seen[key]=true
	return ""
