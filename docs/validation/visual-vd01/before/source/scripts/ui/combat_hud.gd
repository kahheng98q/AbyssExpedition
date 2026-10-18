extends Control

var run
var values: Label
var health_bar: ProgressBar
var xp_bar: ProgressBar
var boss_label: Label
var boss_bar: ProgressBar
var party_label: Label
var rescue_label: Label
var corruption_label: Label
var corruption_bar: ProgressBar

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel = ColorRect.new()
	panel.color = Color(0.025, 0.055, 0.075, 0.94)
	panel.position = Vector2(0, 0)
	panel.size = Vector2(640, 42)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	values = Label.new()
	values.position = Vector2(10, 3)
	values.add_theme_font_size_override("font_size", 12)
	add_child(values)
	health_bar = bar(Vector2(10, 24), Vector2(210, 8), Color(0.4, 0.87, 0.71))
	xp_bar = bar(Vector2(230, 24), Vector2(170, 8), Color(0.36, 0.77, 1))
	var help = Label.new()
	help.text = "WASD / arrows move  ·  Auto attack  ·  Esc pause"
	help.position = Vector2(10, 340)
	help.add_theme_font_size_override("font_size", 11)
	help.add_theme_color_override("font_color", Color(0.7, 0.85, 0.87))
	add_child(help)
	help.text += "  ·  C Abyss"
	corruption_label = Label.new()
	corruption_label.position = Vector2(10, 76)
	corruption_label.add_theme_font_size_override("font_size", 10)
	add_child(corruption_label)
	corruption_bar = bar(Vector2(10, 94), Vector2(120, 5), Color(0.7, 0.38, 0.93))
	party_label = Label.new()
	party_label.position = Vector2(10, 320)
	party_label.add_theme_font_size_override("font_size", 11)
	add_child(party_label)
	rescue_label = Label.new()
	rescue_label.position = Vector2(10, 300)
	rescue_label.add_theme_font_size_override("font_size", 11)
	add_child(rescue_label)
	boss_label = Label.new()
	boss_label.position = Vector2(195, 47)
	boss_label.add_theme_font_size_override("font_size", 12)
	add_child(boss_label)
	boss_bar = bar(Vector2(185, 64), Vector2(270, 5), Color(0.95, 0.35, 0.47))
	boss_bar.hide()

func bar(at: Vector2, dimensions: Vector2, color: Color) -> ProgressBar:
	var item = ProgressBar.new()
	item.position = at
	item.size = dimensions
	item.show_percentage = false
	item.add_theme_font_size_override("font_size", 1)
	var fill = StyleBoxFlat.new()
	fill.bg_color = color
	item.add_theme_stylebox_override("fill", fill)
	var background = StyleBoxFlat.new()
	background.bg_color = Color(0.15, 0.2, 0.24)
	item.add_theme_stylebox_override("background", background)
	add_child(item)
	# Set final size after percentage/theme minimum sizes have been removed.
	item.size = dimensions
	return item

func bind_run(expedition) -> void:
	run = expedition
	run.state_changed.connect(refresh)
	refresh()

func refresh() -> void:
	if run == null: return
	var m = run.corruption.modifiers()
	corruption_bar.value = run.corruption.value
	corruption_label.text = "ABYSS %d/100 · XP +%d%% · waves +%d%% · damage +%d%% · coins %d" % [run.corruption.value, roundi((m.xp - 1) * 100), roundi((m.count - 1) * 100), roundi((m.damage - 1) * 100), run.coins]
	values.text = "%s · Hero Lv %d  HP %d / %d  Run Lv %d · XP %d / %d  %s  Seed %d" % [run.hero.definition.display_name, run.hero.permanent_level, ceili(run.hero.health.current), ceili(run.hero.health.maximum), run.progression.level, run.progression.xp, run.progression.level * 100, run.clock.display_time(), run.snapshot.seed_value]
	health_bar.max_value = run.hero.health.maximum
	health_bar.value = run.hero.health.current
	xp_bar.max_value = run.progression.level * 100
	xp_bar.value = run.progression.xp
	var followers: PackedStringArray = []
	for member in run.party.slice(1):
		followers.append("%s %s" % [member.definition.display_name, "DOWNED" if member.health.dead else "HP %d/%d" % [ceili(member.health.current), ceili(member.health.maximum)]])
	party_label.text = "   ·   ".join(followers)
	match run.rescue.state:
		"defending": rescue_label.text = "RESCUE  Stay in the circle: %.1f / 30.0s" % (run.rescue.elapsed / 60.0)
		"succeeded": rescue_label.text = "RESCUE SUCCESS · %s earned; save at victory/defeat" % ("1 ticket" if run.rescue.owned_at_start else "Sera")
		"failed": rescue_label.text = "RESCUE FAILED · try again next expedition"
		"declined": rescue_label.text = "Rescue declined · available next expedition"
		_: rescue_label.text = ""
	if run.boss_actor != null:
		boss_label.text = "TIDEBOUND HIEROPHANT  /  dodge the warnings"
		boss_bar.show()
		boss_bar.max_value = run.boss_actor.health.maximum
		boss_bar.value = run.boss_actor.health.current
	elif run.clock.tick >= 32400:
		boss_label.text = "THE HIEROPHANT APPROACHES"
