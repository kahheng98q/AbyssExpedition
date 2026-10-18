extends RefCounted

func isolated_copy(visual):
	var result=visual.duplicate()
	var frames=SpriteFrames.new()
	frames.clear_all()
	for state in visual.sprite_frames.get_animation_names():
		frames.add_animation(state)
		frames.set_animation_speed(state,visual.sprite_frames.get_animation_speed(state))
		frames.set_animation_loop(state,visual.sprite_frames.get_animation_loop(state))
		for i in visual.sprite_frames.get_frame_count(state):frames.add_frame(state,visual.sprite_frames.get_frame_texture(state,i).duplicate())
	result.sprite_frames=frames
	return result

func run(t) -> void:
	print("FIXTURE test_visual_contract")
	var path="res://data/visuals/actor_overrides.tres"
	t.check(ResourceLoader.exists(path),"three exact VD01 sprite mappings delivered")
	if not ResourceLoader.exists(path):return
	var table=load(path)
	t.check(table.validate().is_empty(),"override contract")
	for row in [["hero",&"aren",&"swordsman"],["enemy",&"saltbound_thrall",&""],["enemy",&"skittering_brinejaw",&""]]:
		var visual=table.resolve(row[0],row[1],row[2])
		t.check(visual!=null and visual.validate().is_empty(),"expected actual sprite: "+str(row[1]))
		if visual==null:continue
		var bad=isolated_copy(visual);bad.anchor_px=Vector2i(-1,40)
		t.check(not bad.validate().is_empty(),"invalid anchor rejected")
		bad=isolated_copy(visual);bad.sprite_frames.remove_animation(&"move")
		t.check(not bad.validate().is_empty(),"incomplete frame set rejected")
		bad=isolated_copy(visual)
		var texture=bad.sprite_frames.get_frame_texture(&"idle",0)
		texture.region.position.x=99999
		t.check(not bad.validate().is_empty(),"out-of-atlas region rejected")
		bad=isolated_copy(visual)
		bad.sprite_frames.set_frame(&"move",1,bad.sprite_frames.get_frame_texture(&"move",0))
		t.check(not bad.validate().is_empty(),"duplicate filler region rejected")
	t.check(table.resolve("hero",&"brann",&"swordsman")==null,"Brann keeps full legacy rendering")
	t.check(table.resolve("hero",&"aren",&"swordmaster")==null,"promoted Aren keeps full legacy rendering")
	t.check(table.resolve("enemy",&"lantern_cantor",&"")==null,"out-of-slice enemy fallback")
	var legacy=VisualSet.new()
	t.check(legacy.validate().is_empty(),"legacy visual needs no migration")
