extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var c=ContentCatalog.new()
	root.add_child(c)
	if not c.load_all(): quit(1);return
	for seed_value in [101,202,303]:
		var r=c.scene("expedition").instantiate()
		root.add_child(r)
		r.set_physics_process(false)
		r.start(c,RunStartSnapshot.new(seed_value,&"aren"))
		r.spawns.schedule_wave(r,0)
		for slot in r.spawns.reservations:
			var screen=slot.point-r.hero.position+Vector2(320,180)
			var covered=Rect2(8,6,206,46).has_point(screen) or Rect2(252,4,136,46).has_point(screen) or Rect2(430,6,202,46).has_point(screen)
			print("OPENING seed=%d slot=%d screen=%s center_overlaps_HUD_geometry=%s" % [seed_value,slot.slot_index,screen,covered])
		r.free()
	c.free()
	quit()
