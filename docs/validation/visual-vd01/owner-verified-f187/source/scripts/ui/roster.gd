extends "res://scripts/ui/screen.gd"

signal confirmed(active: String, companions: Array)
signal promotion_requested(hero: String)
signal back_requested
var catalog: ContentCatalog
var payload: Dictionary = ProfileData.fresh()
var active: String
var companions: Array
var error_label: Label

func _ready() -> void:
	active = payload.active
	companions = payload.companions.duplicate()
	rebuild()

func rebuild() -> void:
	for node in get_children():
		remove_child(node)
		node.queue_free()
	build_scroll(590)
	column.add_theme_constant_override("separation", 4)
	label("ROSTER  /  %d promotion items" % payload.promotion_items, 18)
	label("One active hero and up to two companions. Changes apply next run.", 11)
	for id in ContentCatalog.CHARACTERS:
		if not payload.owned.has(id): continue
		var h = payload.owned[id]
		var character = catalog.characters[StringName(id)]
		var profession = h.promotion_id if h.promotion_id != "" else ProfileData.BASES[id]
		label("%s · Lv %d · XP %d / 2900 · %s → %s · %s" % [character.display_name, h.level, h.total_xp, ProfileData.BASES[id].capitalize(), profession.capitalize(), String(character.passive.id).capitalize()], 11)
		var row = HBoxContainer.new()
		column.add_child(row)
		var main = Button.new()
		main.text = "Active ✓" if active == id else "Set active"
		main.pressed.connect(func():
			if Time.get_ticks_msec() < armed_at: return
			active = id
			companions.erase(id)
			rebuild())
		row.add_child(main)
		var follower = Button.new()
		follower.text = "Companion ✓" if companions.has(id) else "Add companion"
		follower.disabled = active == id
		follower.pressed.connect(func():
			if Time.get_ticks_msec() < armed_at: return
			if companions.has(id): companions.erase(id)
			else: companions.append(id)
			rebuild())
		row.add_child(follower)
		var promote = Button.new()
		promote.text = "View / promote"
		promote.pressed.connect(func():
			if Time.get_ticks_msec() >= armed_at: promotion_requested.emit(id))
		row.add_child(promote)
		var eligibility = Label.new()
		eligibility.add_theme_font_size_override("font_size", 10)
		eligibility.text = PromotionService.reason(payload, id)
		row.add_child(eligibility)
	error_label = label(ProfileValidator.party(payload, active, companions), 11, Color(1, 0.65, 0.5))
	button("Save party & return", func():
		var why = ProfileValidator.party(payload, active, companions)
		if why != "": error_label.text = why
		else: confirmed.emit(active, companions)).grab_focus()
	button("Cancel", func(): back_requested.emit())
