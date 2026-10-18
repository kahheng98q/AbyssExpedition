extends SceneTree
## Synthetic display-only save error states and native tooltip edge audit. No file I/O.
var output: String
var records: Array=[]
var failures: Array=[]
const MESSAGE="Unavailable while another action is pending. Retry preserves the same result without spending again."

func _initialize() -> void:
	call_deferred("run_capture")

func rectangle(value: Rect2) -> Array:
	return [value.position.x,value.position.y,value.size.x,value.size.y]

func text_rows(node: Node,rows: Array) -> void:
	if node is Label and node.is_visible_in_tree():rows.append({"text":node.text,"rect":rectangle(node.get_global_rect()),"font_size":node.get_theme_font_size("font_size")})
	for child in node.get_children():text_rows(child,rows)

func tooltip_label(node: Node):
	if node is Label and node.text==MESSAGE and node.is_visible_in_tree():return node
	for child in node.get_children():
		var found=tooltip_label(child)
		if found!=null:return found
	return null

func capture(name_value: String,host: Node,row: Dictionary) -> void:
	for i in range(5):await process_frame
	await RenderingServer.frame_post_draw
	var labels: Array=[];text_rows(host,labels)
	row.merge({"name":name_value,"labels":labels,"window":[root.size.x,root.size.y],"kind":"REAL native renderer; explicitly synthetic display fixture; no save or retry executed"})
	if root.get_texture().get_image().save_png(output.path_join(name_value+".png"))!=OK:failures.append("image "+name_value)
	records.append(row)

func run_capture() -> void:
	var args=OS.get_cmdline_user_args()
	if not args.has("--output"):quit(2);return
	output=args[args.find("--output")+1];DirAccess.make_dir_recursive_absolute(output)
	root.content_scale_size=Vector2i(640,360);root.content_scale_mode=Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP;root.content_scale_stretch=Window.CONTENT_SCALE_STRETCH_INTEGER
	ProjectSettings.set_setting("gui/timers/tooltip_delay_sec",0.05)
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(1371,779)]:
		root.size=dimensions
		for state in ["save-blocked","locked","load-blocked","recovery-required"]:
			var writer=SaveCoordinator.new("user://tests/"+"coastal-expedition-profile-recovery/".repeat(7))
			writer.state=state;writer.error="Synthetic review fixture: storage unavailable. Pending results must remain intact until Retry succeeds."
			var screen=load("res://scenes/ui/save_error.tscn").instantiate()
			screen.writer=writer;root.add_child(screen)
			await process_frame
			var expected="Save location: "+ProjectSettings.globalize_path(writer.store.root)
			var rows: Array=[];text_rows(screen,rows)
			if not rows.any(func(row):return row.text==expected):failures.append("save path omitted")
			await capture("save-%s-%d" % [state,dimensions.x],screen,{"panel_rect":rectangle(screen.panel.get_global_rect()),"panel_inside_viewport":Rect2(0,0,640,360).encloses(screen.panel.get_global_rect()),"full_path_preserved":true,"root_characters":expected.length(),"writer_state":writer.state,"writes_attempted":false})
			screen.free();await process_frame
		for i in range(4):
			var button=load("res://scenes/ui/components/action_button.tscn").instantiate()
			button.theme=load("res://data/themes/expedition_theme.tres")
			button.text="Review";button.tooltip_text=MESSAGE
			button.position=[Vector2(8,8),Vector2(550,8),Vector2(8,322),Vector2(550,322)][i]
			button.size=Vector2(82,30);root.add_child(button)
			var motion=InputEventMouseMotion.new();motion.position=button.position+Vector2(40,15)
			root.push_input(motion,true)
			await create_timer(1.0).timeout
			var label=tooltip_label(root)
			var observation={"hovered_control":str(root.gui_get_hovered_control().get_path()) if root.gui_get_hovered_control()!=null else "none","tooltip_observed":label!=null,"embedded_subwindows":root.gui_embed_subwindows,"engine_owned_placement":true}
			if label!=null:
				var window=label.get_window()
				var bounds=Rect2(window.position,window.size) if window!=root else label.get_parent().get_global_rect()
				observation.tooltip_rect=rectangle(bounds)
				observation.bounds_in_640x360=Rect2(0,0,640,360).encloses(bounds) if root.gui_embed_subwindows else null
			await capture("tooltip-corner-%d-%d" % [i,dimensions.x],root,observation)
			button.free()
			motion=InputEventMouseMotion.new();motion.position=Vector2(320,180);root.push_input(motion,true)
			await create_timer(0.1).timeout
	var file=FileAccess.open(output.path_join("manifest.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"records":records,"failures":failures,"limits":"Display-only error/long-path states, no save I/O. Tooltip absence/geometry remains a recorded finding, not silently passed. Existing10/11px out-of-slice labels remain unchanged. Not a natural manual session."},"  "));file.close()
	print("AUXILIARY UI records=%d failures=%d" % [records.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)
