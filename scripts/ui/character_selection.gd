extends "res://scripts/ui/screen.gd"

signal start_requested(hero_id: StringName, seed_value: int)
signal back_requested
signal roster_requested
var saved_seed: int = -1
var catalog: ContentCatalog
var profile: Dictionary = {}
var selected: StringName = &"aren"
var seed_edit: LineEdit
var error_label: Label
var preview: Label
var hero_buttons: Dictionary = {}

func _ready() -> void:
	build_scroll(540)
	column.add_theme_constant_override("separation", 3)
	label("CHOOSE YOUR CHARACTER", 23, Color(0.57, 0.93, 0.89))
	label("Every party starts BASE / RUN Lv1. Promote in combat at RUN Lv15.")
	var row = GridContainer.new()
	row.columns = 3
	row.add_theme_constant_override("separation", 8)
	column.add_child(row)
	for id_value in ContentCatalog.CHARACTERS:
		if (profile.is_empty() and id_value not in ProfileData.STARTERS) or (not profile.is_empty() and not profile.owned.has(id_value)): continue
		var hero = catalog.characters[StringName(id_value)]
		var item = Button.new()
		var profession = String(hero.base_profession.id)
		item.text = hero.display_name + " / RUN Lv1\nBASE " + profession.capitalize()
		item.add_theme_font_size_override("font_size", 12)
		item.custom_minimum_size = Vector2(140, 42)
		item.pressed.connect(func(): select_hero(hero.id))
		row.add_child(item)
		hero_buttons[hero.id] = item
	preview = label("", 12)
	preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview.custom_minimum_size.y = 20
	label("SEED  /  blank generates one; decimal 0–2147483647", 11)
	seed_edit = LineEdit.new()
	seed_edit.placeholder_text = "Random seed"
	seed_edit.text = str(saved_seed if saved_seed >= 0 else randi_range(0, 2147483647))
	seed_edit.max_length = 10
	seed_edit.add_theme_font_size_override("font_size", 12)
	column.add_child(seed_edit)
	error_label = label("", 11, Color(1, 0.62, 0.5))
	label("WASD / arrows move. Enter confirms focused buttons.", 11)
	label("Same seed repeats randomness with matching version and decisions.", 10)
	button("Start Expedition", request_start)
	button("Character roster / companions / branch previews", func(): roster_requested.emit())
	button("Back", func(): back_requested.emit())
	select_hero(selected)
	hero_buttons[selected].grab_focus()

func select_hero(id_value: StringName) -> void:
	if not hero_buttons.has(id_value): return
	selected = id_value
	preview.text = catalog.characters[id_value].description

	for hero_id in hero_buttons:
		hero_buttons[hero_id].modulate = Color(0.6, 1, 0.85) if hero_id == id_value else Color.WHITE

func request_start() -> void:
	var value = seed_edit.text.strip_edges()
	if value.is_empty():
		value = str(randi_range(0, 2147483647))
		seed_edit.text = value
		error_label.text = "Seed %s ready. Press Start Expedition to begin." % value
		return
	if not SeedStreams.valid_seed(value):
		error_label.text = "Enter a whole decimal seed from 0 to 2147483647."
		return
	start_requested.emit(selected, value.to_int())
