extends SceneTree

# Documentation-only exhibit of real ActorPresentation nodes; not a shipping UI.
const Fixture = preload("res://tests/fixtures/run_fixture.gd")
var errors = preload("res://tests/error_capture.gd").new()

func _initialize() -> void:
	ProfileStore.test_mode = true
	OS.add_logger(errors)
	call_deferred("capture_gallery")

func text_at(value: String, at: Vector2, font_size: int, tint: Color) -> void:
	var label = Label.new()
	label.text = value
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	root.add_child(label)

func capture_gallery() -> void:
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var f = Fixture.create(self)
	f.run.hide()
	f.run.get_node("HUD/CombatHUD").hide()
	f.run.camera.enabled = false
	text_at("ABYSS EXPEDITION  /  ROSTER", Vector2(20, 8), 19, Color("e9ce95"))
	text_at("Runtime appearance  /  6 heroes, 3 shared base professions  /  Q1", Vector2(20, 34), 10, Color("92aaa9"))
	var actors: Array = []
	for index in range(6):
		var at = Vector2(20 + (index % 3) * 202, 60 + int(index / 3.0) * 142)
		var card = ColorRect.new()
		card.position = at
		card.size = Vector2(192, 130)
		card.color = Color("14232d")
		root.add_child(card)
		var id = StringName(ContentCatalog.CHARACTERS[index])
		var definition = f.catalog.characters[id]
		var actor = f.catalog.scene("hero").instantiate()
		actor.setup(definition, -index, f.run, true)
		actor.position = at + Vector2(94, 61)
		actor.scale = Vector2(2, 2)
		root.add_child(actor)
		actors.append(actor)
		text_at(definition.display_name + "  /  " + String(definition.base_profession.id).capitalize(), at + Vector2(10, 99), 11, Color("c7ddd7"))
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var result = root.get_texture().get_image().save_png("res://screenshots/quality-20261018/actual-roster.png")
	for actor in actors: actor.free()
	Fixture.dispose(f)
	var failures = errors.snapshot()
	OS.remove_logger(errors)
	print("GALLERY real ActorPresentation nodes: save=", result, " errors=", failures)
	quit(0 if result == OK and failures.is_empty() else 1)
