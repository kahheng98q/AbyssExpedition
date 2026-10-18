extends SceneTree
## External, isolated review fixture. Does not modify/export production resources.
var output: String
var app
var records: Array = []
var failures: Array = []
var require_text_containment: bool = false
var scan_ink: bool = false

func visible_labels(node: Node, result: Array) -> void:
	if node is Label and node.is_visible_in_tree() and not node.text.is_empty(): result.append(node)
	for child in node.get_children(): visible_labels(child,result)

func ink_bounds(host: Node, name_value: String) -> Array:
	# Render actual Labels independently on transparent cells. This measures glyph ink,
	# unlike a Control rectangle or Font.has_char. Scroll reachability remains separate.
	var originals: Array = []
	visible_labels(host,originals)
	var viewport = SubViewport.new()
	viewport.transparent_bg = true
	viewport.size = Vector2i(3072,maxi(512,ceili(originals.size()/4.0)*512))
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var clones: Array = []
	for index in originals.size():
		var original: Label = originals[index]
		var clone = original.duplicate(0) as Label
		clone.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		clone.position = Vector2(index%4*768+64,index/4*512+64)
		clone.size = original.size
		clone.add_theme_font_override("font",original.get_theme_font("font"))
		clone.add_theme_font_size_override("font_size",original.get_theme_font_size("font_size"))
		for key in ["font_color","font_shadow_color","font_outline_color"]:
			clone.add_theme_color_override(key,original.get_theme_color(key))
		for key in ["outline_size","shadow_outline_size","shadow_offset_x","shadow_offset_y","line_spacing"]:
			clone.add_theme_constant_override(key,original.get_theme_constant(key))
		viewport.add_child(clone)
		clones.append(clone)
	await settle()
	var image = viewport.get_texture().get_image()
	var result: Array = []
	for index in originals.size():
		var original: Label = originals[index]
		var cell = Rect2i(index%4*768,index/4*512,768,512)
		var ink = image.get_region(cell).get_used_rect()
		var global_ink = Rect2(original.get_global_rect().position+Vector2(ink.position)-Vector2(64,64),ink.size)
		var panel = original.get_parent()
		while panel!=null and not panel is Panel and not panel is PanelContainer: panel=panel.get_parent()
		var scroll = original.get_parent()
		while scroll!=null and not scroll is ScrollContainer: scroll=scroll.get_parent()
		var row = {"path":str(original.get_path()),"text":original.text,
			"ink_rect":rect_array(global_ink),"nonempty":ink.has_area(),
			"cell_guard_clear":ink.position.x>0 and ink.position.y>0 and ink.end.x<768 and ink.end.y<512}
		if panel!=null:
			row.inside_panel=inside(global_ink,panel.get_global_rect())
			var bounds = panel.get_global_rect().grow(0.5)
			row.horizontal_inside_panel = global_ink.position.x>=bounds.position.x and global_ink.end.x<=bounds.end.x
			row.inside_scroll_content = scroll!=null and inside(global_ink,scroll.get_child(0).get_global_rect())
			row.intentional_vertical_scroll = not row.inside_panel and row.horizontal_inside_panel and row.inside_scroll_content
			if not row.inside_panel and not row.intentional_vertical_scroll and name_value!="ink-calibration":
				failures.append(name_value+": glyph ink crosses panel: "+original.text)
		if not row.cell_guard_clear: failures.append(name_value+": glyph scan cell too small")
		result.append(row)
	viewport.free()
	return result

func _initialize() -> void:
	call_deferred("run_audit")

func rect_array(rect: Rect2) -> Array:
	return [rect.position.x,rect.position.y,rect.size.x,rect.size.y]

func inside(inner: Rect2,outer: Rect2) -> bool:
	return outer.grow(0.5).encloses(inner)

func labels(node: Node,rows: Array) -> void:
	if node is Label and node.is_visible_in_tree():
		var font=node.get_theme_font("font")
		var font_size=node.get_theme_font_size("font_size")
		var missing: Array=[]
		for index in node.text.length():
			var code=node.text.unicode_at(index)
			if code>32 and not font.has_char(code) and code not in missing:missing.append(code)
		var box=node.get_parent()
		while box!=null and not box is Panel and not box is PanelContainer:box=box.get_parent()
		var row={"path":str(node.get_path()),"text":node.text,"rect":rect_array(node.get_global_rect()),"font_size":font_size,"missing_codepoints":missing,"wrapped":node.autowrap_mode!=TextServer.AUTOWRAP_OFF,"line_count":node.get_line_count()}
		if box!=null:
			row.container=rect_array(box.get_global_rect())
			row.crosses_container=not inside(node.get_global_rect(),box.get_global_rect())
		# A Control rectangle overhang is diagnostic, not proof of clipped ink.
		# In particular ScrollContainer content may intentionally be offscreen.
		rows.append(row)
	for child in node.get_children():labels(child,rows)

func settle() -> void:
	for i in range(8):await process_frame
	await RenderingServer.frame_post_draw

func inspect(name_value: String,host: Node,strict: bool,save_image: bool=true) -> void:
	await settle()
	var rows: Array=[]
	labels(host,rows)
	var missing=rows.filter(func(row):return not row.missing_codepoints.is_empty())
	var overflow=rows.filter(func(row):return row.get("crosses_container",false))
	var record={"name":name_value,"fixture":"current catalog values" if strict else "SYNTHETIC boundary fixture; not a natural run or new content","requested_window":[root.size.x,root.size.y],"viewport":[root.get_texture().get_width(),root.get_texture().get_height()],"labels":rows,"missing_glyph_labels":missing.size(),"container_overflow_labels":overflow.size()}
	if scan_ink and root.size.x==1280:
		record.glyph_ink=await ink_bounds(host,name_value)
	if host.get("panel") is PanelContainer:
		record.panel_rect=rect_array(host.panel.get_global_rect())
		record.panel_inside_viewport=inside(host.panel.get_global_rect(),Rect2(0,0,640,360))
		var scroll=host.column.get_parent() as ScrollContainer
		if scroll!=null:
			record.scroll_max_y=scroll.get_v_scroll_bar().max_value
			record.scroll_page_y=scroll.get_v_scroll_bar().page
			record.scroll_content_width=host.column.size.x
			record.scroll_available_width=scroll.size.x
			record.horizontal_content_fits=host.column.size.x<=scroll.size.x+0.5
	if strict and (not missing.is_empty() or not record.get("panel_inside_viewport",true) or not record.get("horizontal_content_fits",true)):
		failures.append(name_value)
	if require_text_containment and name_value.begins_with("synthetic-long-name-") and host.get("hero_label") is Label:
		var heading=host.hero_label
		var contained=inside(heading.get_global_rect(),host.widgets.hero.get_global_rect()) and heading.text.contains("Hero Lv 1")
		record.name_and_level_contained=contained
		if not contained:failures.append(name_value+": name/level overlap")
	if require_text_containment and name_value.begins_with("synthetic-long-cards-"):
		var headings=rows.filter(func(row):return row.text.contains("Resolve of the Forgotten"))
		record.full_headings_wrap_inside_cards=headings.size()==3 and headings.all(func(row):return row.wrapped and row.line_count>1 and not row.crosses_container)
		if not record.full_headings_wrap_inside_cards:failures.append(name_value+": clipped upgrade title")
	if save_image:
		var path=output.path_join(name_value+".png")
		if root.get_texture().get_image().save_png(path)!=OK:failures.append("image "+path)
		record.image=name_value+".png"
	records.append(record)

func catalog_fingerprint() -> String:
	var data: Array=[]
	for id in app.catalog.characters:data.append([str(id),app.catalog.characters[id].display_name])
	for id in app.catalog.upgrades:
		var definition=app.catalog.upgrades[id]
		data.append([str(id),definition.label,definition.effect_preview()])
	return JSON.stringify(data).sha256_text()

func choice(options: Array,name_value: String,strict: bool) -> void:
	var screen=app.catalog.scene("level_up").instantiate()
	screen.run=app.run;screen.identity=1;screen.options=options
	app.modal_host.add_child(screen)
	await inspect(name_value,screen,strict)
	var scroll=screen.column.get_parent() as ScrollContainer
	if scroll.get_v_scroll_bar().max_value>scroll.get_v_scroll_bar().page:
		scroll.scroll_vertical=int(scroll.get_v_scroll_bar().max_value)
		await inspect(name_value+"-bottom",screen,strict)
	screen.free()
	await process_frame

func run_audit() -> void:
	var args=OS.get_cmdline_user_args()
	if not args.has("--output"):quit(2);return
	output=args[args.find("--output")+1]
	require_text_containment=args.has("--require-text-containment")
	scan_ink=args.has("--ink-bounds")
	DirAccess.make_dir_recursive_absolute(output)
	root.content_scale_size=Vector2i(640,360)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_stretch=Window.CONTENT_SCALE_STRETCH_INTEGER
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(1371,779)]:
		root.size=dimensions
		app=load("res://scenes/app/app.tscn").instantiate()
		app.writer=SaveCoordinator.new("user://tests/visual-ui-boundary-%d/" % Time.get_ticks_usec())
		root.add_child(app);current_scene=app
		var payload=ProfileData.fresh()
		payload.companions=["lia","milo"]
		app.writer.payload.companions=payload.companions.duplicate()
		app.mount_run(RosterService.snapshot(payload,101))
		var original_fingerprint=catalog_fingerprint()
		var run=app.run
		run.set_physics_process(false)
		run.clock.tick=32445;run.rescue.state="defending";run.rescue.elapsed=1080
		run.corruption.add(100-run.corruption.value)
		run.spawn_enemy(&"tidebound_hierophant",Vector2(650,270),-1,true)
		var hud=run.get_node("HUD/CombatHUD")
		for id in app.catalog.characters:
			run.hero.definition=app.catalog.characters[id]
			run.state_changed.emit()
			await inspect("hud-%s-%d" % [id,dimensions.x],hud,true,id==&"aren")
		run.hero.definition=app.catalog.characters[&"aren"]
		var old=[run.hero.health.current,run.hero.health.maximum,run.progression.xp,run.coins]
		run.hero.health.current=999999999;run.hero.health.maximum=999999999
		run.progression.xp=999999999;run.coins=999999999999
		run.state_changed.emit()
		await inspect("synthetic-huge-values-%d" % dimensions.x,hud,false)
		run.coins=9223372036854775807
		run.state_changed.emit()
		await inspect("synthetic-int64-coins-%d" % dimensions.x,hud,false)
		run.hero.health.current=old[0];run.hero.health.maximum=old[1];run.progression.xp=old[2];run.coins=old[3]
		var original=run.hero.definition
		run.hero.definition=original.duplicate()
		run.hero.definition.display_name="Aren of the Saltbound Coastal Expedition"
		run.state_changed.emit()
		await inspect("synthetic-long-name-%d" % dimensions.x,hud,false)
		if require_text_containment:
			var pause_screen=app.catalog.scene("pause_menu").instantiate()
			pause_screen.run=run;app.modal_host.add_child(pause_screen)
			await inspect("synthetic-name-details-%d" % dimensions.x,pause_screen,false)
			var detail_rows: Array=[];labels(pause_screen,detail_rows)
			if not detail_rows.any(func(row):return row.text.contains(run.hero.definition.display_name)):failures.append("full hero name missing in pause details")
			pause_screen.free()
		run.hero.definition=original;run.state_changed.emit()
		var ids=app.catalog.upgrades.keys()
		for first in range(0,ids.size(),3):
			var group=ids.slice(first,mini(first+3,ids.size()))
			while group.size()<3:group.append(group[-1])
			await choice(group,"catalog-upgrades-%02d-%d" % [first,dimensions.x],true)
		var original_upgrade=app.catalog.upgrades[ids[0]]
		var synthetic=original_upgrade.duplicate()
		synthetic.effects=original_upgrade.effects.duplicate()
		for i in range(8):synthetic.effects.append(original_upgrade.effects[0])
		app.catalog.upgrades[ids[0]]=synthetic
		await choice([ids[0],ids[0],ids[0]],"synthetic-long-effects-%d" % dimensions.x,false)
		synthetic.label="Resolve of the Forgotten Coastal Expedition — Extended Boundary Fixture"
		await choice([ids[0],ids[0],ids[0]],"synthetic-long-cards-%d" % dimensions.x,false)
		app.catalog.upgrades[ids[0]]=original_upgrade
		if catalog_fingerprint()!=original_fingerprint:failures.append("fixture mutated catalog")
		app.free();paused=false;await process_frame
	var calibration: Array = []
	if scan_ink:
		var panel = Panel.new()
		panel.size=Vector2(40,24)
		root.add_child(panel)
		var label=Label.new()
		label.text="INTENTIONAL GLYPH OVERFLOW CALIBRATION"
		panel.add_child(label)
		await settle()
		calibration=await ink_bounds(panel,"ink-calibration")
		if calibration.size()!=1 or calibration[0].get("horizontal_inside_panel",true):
			failures.append("ink calibration failed to detect deliberately overflowing glyphs")
		panel.free()
	var result={"kind":"REAL native renderer and layout measurements; synthetic inputs explicitly separated","engine":Engine.get_version_info().string,"renderer":RenderingServer.get_current_rendering_method(),"profile":"isolated user://tests; no production save","catalog_unchanged":not failures.has("fixture mutated catalog"),"glyph_ink_scan":scan_ink,"records":records,"failures":failures,"limits":"No physical-window screenshots, human readability score, hardware latency or natural manual session. Optional transparent Label ink scan uses actual resolved fonts at native resolution for the1280 request; other sizes share640x360 layout. Font.has_char is font coverage. Scroll reachability and natural review remain separate."}
	result.ink_calibration=calibration
	var file=FileAccess.open(output.path_join("audit.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"  "));file.close()
	print("UI BOUNDARY AUDIT records=%d strict_failures=%d" % [records.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)
