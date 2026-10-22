extends Control

const INK = Color("0b1420")
const MINT = Color("a9e8d2")
const GOLD = Color("e9ce95")
const MUTED = Color("899da9")
var run
var promotion_button: Button
var values: Label
var hero_label: Label
var xp_title: Label
var health_bar: ProgressBar
var xp_bar: ProgressBar
var xp_label: Label
var clock_label: Label
var goal_label: Label
var seed_label: Label
var boss_label: Label
var boss_bar: ProgressBar
var party_label: Label
var rescue_label: Label
var corruption_label: Label
var corruption_detail: Label
var corruption_bar: ProgressBar
var health_trail: ProgressBar
var trail_value: float = -1
var previous_tick: int = -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel(Rect2(8, 7, 206, 44))
	panel(Rect2(252, 5, 136, 44))
	panel(Rect2(430, 7, 202, 44))
	hero_label = label_at(Vector2(16, 9), 11, MINT)
	values = label_at(Vector2(16, 23), 10, Color("dce9e3"))
	health_trail = bar(Vector2(16, 37), Vector2(190, 7), Color("d39a67"))
	health_bar = bar(Vector2(16, 37), Vector2(190, 7), MINT)
	var empty = StyleBoxEmpty.new()
	health_bar.add_theme_stylebox_override("background", empty)
	xp_title = label_at(Vector2(438, 9), 11, Color("a7ccee"))
	xp_label = label_at(Vector2(438, 23), 10, Color("dce9e3"))
	xp_bar = bar(Vector2(438, 37), Vector2(186, 7), Color("75a9d0"))
	clock_label = label_at(Vector2(252, 4), 22, GOLD, 136)
	goal_label = label_at(Vector2(252, 32), 9, MUTED, 136)
	panel(Rect2(452, 284, 180, 66))
	corruption_label = label_at(Vector2(461, 289), 11, Color("c6a6e8"))
	corruption_bar = bar(Vector2(461, 309), Vector2(162, 4), Color("a780ce"))
	corruption_detail = label_at(Vector2(461, 316), 9, MUTED)
	seed_label = label_at(Vector2(461, 332), 9, MUTED)
	party_label = label_at(Vector2(12, 310), 10, MINT)
	rescue_label = label_at(Vector2(100, 263), 11, GOLD, 440)
	var help = label_at(Vector2(12, 338), 10, MUTED)
	help.text = "WASD move   /   Auto attack   /   Esc pause"
	boss_label = label_at(Vector2(170, 61), 11, Color("f4baac"), 300)
	boss_bar = bar(Vector2(200, 80), Vector2(240, 5), Color("c76b79"))
	boss_bar.hide()
	promotion_button = Button.new()
	promotion_button.name = "RunPromotion"
	promotion_button.position = Vector2(242, 92)
	promotion_button.size = Vector2(156, 26)
	promotion_button.add_theme_font_size_override("font_size", 11)
	promotion_button.text = "Promotion / RUN Lv15"
	promotion_button.pressed.connect(func(): run.choices.request_promotion(run))
	promotion_button.hide()
	add_child(promotion_button)

func panel(rect: Rect2) -> void:
	var box = Panel.new()
	box.position = rect.position
	box.size = rect.size
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color(INK, 0.96)
	style.border_color = Color("34444c")
	style.set_border_width_all(1)
	box.add_theme_stylebox_override("panel", style)
	add_child(box)

func label_at(at: Vector2, size_value: int, tint: Color, width: float = 0) -> Label:
	var item = Label.new()
	item.position = at
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item.add_theme_font_size_override("font_size", size_value)
	item.add_theme_color_override("font_color", tint)
	item.add_theme_color_override("font_shadow_color", Color("071018"))
	item.add_theme_constant_override("shadow_offset_y", 1)
	if width > 0:
		item.size.x = width
		item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(item)
	return item

func bar(at: Vector2, dimensions: Vector2, tint: Color) -> ProgressBar:
	var item = ProgressBar.new()
	item.position = at
	item.show_percentage = false
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill = StyleBoxFlat.new()
	fill.bg_color = tint
	item.add_theme_stylebox_override("fill", fill)
	var background = StyleBoxFlat.new()
	background.bg_color = Color("26343f")
	item.add_theme_stylebox_override("background", background)
	add_child(item)
	item.size = dimensions
	return item

func bind_run(expedition) -> void:
	run = expedition
	run.state_changed.connect(refresh)
	refresh()

func refresh() -> void:
	if run == null: return
	promotion_button.visible = run.phase == "active" and not PromotionService.eligible(run).is_empty()
	var hp: float = run.hero.health.current
	var maximum: float = run.hero.health.maximum
	hero_label.text = "%s / %s" % [run.hero.definition.display_name.to_upper(), String(run.hero.profession.id).capitalize()]
	values.text = "HP  %d / %d" % [ceili(hp), ceili(maximum)]
	health_bar.max_value = maximum
	health_bar.value = hp
	# An active-tick-only damage trail; it cannot animate through a pause.
	if trail_value < 0 or hp > trail_value: trail_value = hp
	if previous_tick >= 0:
		trail_value = move_toward(trail_value, hp, maxf(0, run.clock.tick - previous_tick) * maximum / 90.0)
	previous_tick = run.clock.tick
	health_trail.max_value = maximum
	health_trail.value = trail_value
	xp_title.text = "RUN LEVEL %d" % run.progression.level
	xp_label.text = "XP  %d / %d" % [run.progression.xp, run.progression.level * 100]
	xp_bar.max_value = run.progression.level * 100
	xp_bar.value = run.progression.xp
	clock_label.text = run.clock.display_time()
	var next_event: int = 120 if run.clock.tick < 7200 else (240 if run.clock.tick < 14400 else (360 if run.clock.tick < 21600 else 540))
	var remaining: int = maxi(0, next_event - run.clock.tick / 60)
	goal_label.text = "%s IN %02d:%02d" % ["EVENT" if next_event < 540 else "BOSS", remaining / 60, remaining % 60]
	if run.clock.tick >= 32400: goal_label.text = "DEFEAT THE HIEROPHANT"
	var m = run.corruption.modifiers()
	corruption_bar.value = run.corruption.value
	corruption_label.text = "ABYSS %d   /   C details" % run.corruption.value
	corruption_detail.text = "XP +%d%%  WAVE +%d%%  DMG +%d%%" % [roundi((m.xp - 1) * 100), roundi((m.count - 1) * 100), roundi((m.damage - 1) * 100)]
	seed_label.text = "COINS %d   /   SEED %d" % [run.coins, run.snapshot.seed_value]
	var followers: PackedStringArray = []
	for member in run.party.slice(1):
		followers.append("%s  %s" % [member.definition.display_name, "DOWNED" if member.health.dead else "%d/%d" % [ceili(member.health.current), ceili(member.health.maximum)]])
	party_label.text = "  /  ".join(followers)
	match run.rescue.state:
		"defending": rescue_label.text = "RESCUE  /  HOLD THE CIRCLE  %.1f / 30s" % (run.rescue.elapsed / 60.0)
		"succeeded": rescue_label.text = "RESCUED  /  %s saved after victory or defeat" % ("1 ticket" if run.rescue.owned_at_start else "Sera")
		"failed": rescue_label.text = "RESCUE LOST  /  Try again next expedition"
		"declined": rescue_label.text = "Rescue declined / Available next expedition"
		_: rescue_label.text = ""
	if run.boss_actor != null:
		boss_label.text = "T I D E B O U N D   H I E R O P H A N T"
		boss_bar.show()
		boss_bar.max_value = run.boss_actor.health.maximum
		boss_bar.value = run.boss_actor.health.current
	elif run.clock.tick >= 32400:
		boss_label.text = "THE HIEROPHANT APPROACHES"
