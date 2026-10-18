extends Control

var run
var values: Label # Compatibility snapshot; visible data is grouped below.
var health_bar: ProgressBar
var xp_bar: ProgressBar
var corruption_bar: ProgressBar
var boss_bar: ProgressBar
var hp_value
var xp_value
var hero_label: Label
var hero_heading_full: String = ""
var run_label: Label
var resource_label: Label
var corruption_label: Label
var party_label: Label
var rescue_label: Label
var boss_label: Label
var portrait
var widgets: Dictionary={}
const RECTANGLES={"hero":Rect2(8,8,192,40),"xp":Rect2(208,8,184,40),"stats":Rect2(400,8,232,40),"boss":Rect2(192,56,256,28),"party":Rect2(8,306,200,46),"rescue":Rect2(216,310,416,38)}

func caption(host: Control,at: Vector2,dimensions: Vector2,color: Color=Color("e9e6d8")) -> Label:
	var item=Label.new()
	item.position=at;item.size=dimensions
	item.add_theme_font_size_override("font_size",12)
	item.add_theme_color_override("font_color",color)
	item.mouse_filter=MOUSE_FILTER_IGNORE
	host.add_child(item)
	return item

func _ready() -> void:
	theme=load("res://data/themes/expedition_theme.tres")
	mouse_filter=MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	for key in RECTANGLES:
		var box=Panel.new()
		box.position=RECTANGLES[key].position;box.size=RECTANGLES[key].size
		box.mouse_filter=MOUSE_FILTER_IGNORE
		box.add_theme_stylebox_override("panel",theme.get_stylebox("panel","PanelContainer"))
		add_child(box);widgets[key]=box
	hero_label=caption(widgets.hero,Vector2(34,1),Vector2(150,17),Color("d6ae68"))
	portrait=load("res://scenes/ui/components/portrait.tscn").instantiate()
	portrait.position=Vector2(5,8);widgets.hero.add_child(portrait)
	hp_value=load("res://scenes/ui/components/value_bar.tscn").instantiate()
	hp_value.position=Vector2(34,18);hp_value.size=Vector2(150,20);widgets.hero.add_child(hp_value);health_bar=hp_value.fill
	run_label=caption(widgets.xp,Vector2(8,1),Vector2(168,17),Color("63d3f2"))
	xp_value=load("res://scenes/ui/components/value_bar.tscn").instantiate()
	xp_value.position=Vector2(8,18);xp_value.size=Vector2(168,20);widgets.xp.add_child(xp_value);xp_bar=xp_value.fill
	resource_label=caption(widgets.stats,Vector2(8,1),Vector2(216,17),Color("d6ae68"))
	corruption_label=caption(widgets.stats,Vector2(8,18),Vector2(216,17))
	corruption_bar=ProgressBar.new();corruption_bar.show_percentage=false;corruption_bar.position=Vector2(8,35);corruption_bar.size=Vector2(216,3);corruption_bar.mouse_filter=MOUSE_FILTER_IGNORE;widgets.stats.add_child(corruption_bar)
	var violet=StyleBoxFlat.new();violet.bg_color=Color("8e5eb5");corruption_bar.add_theme_stylebox_override("fill",violet)
	boss_label=caption(widgets.boss,Vector2(7,1),Vector2(242,17))
	boss_bar=ProgressBar.new();boss_bar.show_percentage=false;boss_bar.position=Vector2(7,21);boss_bar.size=Vector2(242,3);boss_bar.mouse_filter=MOUSE_FILTER_IGNORE;widgets.boss.add_child(boss_bar)
	var red=StyleBoxFlat.new();red.bg_color=Color("f37783");boss_bar.add_theme_stylebox_override("fill",red)
	party_label=load("res://scenes/ui/components/status_indicator.tscn").instantiate();party_label.position=Vector2(8,3);party_label.size=Vector2(184,40);widgets.party.add_child(party_label)
	rescue_label=caption(widgets.rescue,Vector2(8,1),Vector2(400,34))
	values=Label.new();values.hide();add_child(values)
	widgets.boss.hide();widgets.party.hide();widgets.rescue.hide()

func bind_run(expedition) -> void:
	run=expedition
	run.state_changed.connect(refresh)
	refresh()

func refresh() -> void:
	if run==null:return
	refresh_hero_heading()
	run_label.text="Run Lv %d" % run.progression.level
	hp_value.set_value("HP",ceili(run.hero.health.current),ceili(run.hero.health.maximum))
	xp_value.set_value("XP",run.progression.xp,run.progression.level*100,Color("63d3f2"))
	portrait.set_identity(run.hero.definition.id,run.hero.profession.id)
	resource_label.text="%s · Coins %d" % [run.clock.display_time(),run.coins]
	corruption_label.text="Abyss %d/100 · C / Esc details" % run.corruption.value
	corruption_bar.value=run.corruption.value
	values.text="%s · %s · %s · %s · %s · Seed %d" % [hero_heading_full,run_label.text,hp_value.caption.text,xp_value.caption.text,resource_label.text,run.snapshot.seed_value]
	var party: PackedStringArray=[]
	for member in run.party.slice(1):
		party.append("%s  %s" % [member.definition.display_name,"DOWNED" if member.health.dead else "HP %d / %d" % [ceili(member.health.current),ceili(member.health.maximum)]])
	party_label.text="\n".join(party);widgets.party.visible=not party.is_empty()
	match run.rescue.state:
		"defending":rescue_label.text="RESCUE %.1f / 30.0s\nStay in the circle" % (run.rescue.elapsed/60.0)
		"succeeded":rescue_label.text="SUCCESS · %s earned\nSave at victory / defeat" % ("1 ticket" if run.rescue.owned_at_start else "Sera")
		"failed":rescue_label.text="RESCUE FAILED\nTry next expedition"
		"declined":rescue_label.text="RESCUE DECLINED\nAvailable next expedition"
		_:rescue_label.text=""
	widgets.rescue.visible=not rescue_label.text.is_empty()
	widgets.boss.visible=run.boss_actor!=null or run.clock.tick>=32400
	boss_label.text="TIDEBOUND HIEROPHANT" if run.boss_actor!=null else "THE HIEROPHANT APPROACHES"
	boss_bar.visible=run.boss_actor!=null
	if run.boss_actor!=null:
		boss_bar.max_value=run.boss_actor.health.maximum;boss_bar.value=run.boss_actor.health.current
	position_widgets()

func refresh_hero_heading() -> void:
	var suffix=" · Hero Lv %d" % run.hero.permanent_level
	var full=run.hero.definition.display_name+suffix
	if full==hero_heading_full:return
	hero_heading_full=full
	var name_value=run.hero.definition.display_name
	var font=hero_label.get_theme_font("font")
	var font_size=hero_label.get_theme_font_size("font_size")
	if font.get_string_size(full,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=150:
		hero_label.text=full
		return
	# Keep the exact permanent level visible; the existing pause page has the full name.
	while not name_value.is_empty() and font.get_string_size(name_value+"…"+suffix,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>150:
		name_value=name_value.left(name_value.length()-1)
	hero_label.text=name_value+"…"+suffix

func _process(_delta: float) -> void:
	if run!=null:position_widgets()

func position_widgets() -> void:
	var hero_at=run.hero.get_global_transform_with_canvas().origin
	var move_top=hero_at.y<48 or hero_at.x<28 or hero_at.x>612
	var move_bottom=hero_at.y>306
	for key in RECTANGLES:
		var at=RECTANGLES[key].position
		if key in ["hero","xp","stats","boss"] and move_top:at.y+=88
		if key in ["party","rescue"] and move_bottom:at.y-=58
		if widgets[key].position!=at:widgets[key].position=at

func layout_rectangles() -> Dictionary:
	var result={}
	for key in widgets:
		if widgets[key].visible:
			var r=widgets[key].get_global_rect()
			result[key]=[r.position.x,r.position.y,r.size.x,r.size.y]
	return result
