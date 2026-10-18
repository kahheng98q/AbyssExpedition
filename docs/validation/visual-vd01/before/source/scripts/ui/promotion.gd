extends "res://scripts/ui/screen.gd"

signal confirmed(hero: String, branch: String, revision: int)
signal canceled
var catalog: ContentCatalog
var payload: Dictionary = ProfileData.fresh()
var hero_id: String = "aren"
var revision: int = 0
var selected: String = ""
var preview: Label
var confirm_button: Button
var submitted: bool = false
var branch_previews: Dictionary = {}

func _ready() -> void:
	build_scroll(590)
	column.add_theme_constant_override("separation", 3)
	label("PROMOTE " + hero_id.to_upper(), 22)
	label("Permanent choice · requires level 15 and one item · no respec", 11)
	var why = PromotionService.reason(payload, hero_id)
	label("Ready to promote" if why == "" else why, 12, Color(1, 0.8, 0.4))
	label("Retains " + String(catalog.characters[StringName(hero_id)].passive.id).capitalize(), 11)
	var base = catalog.professions[StringName(ProfileData.BASES[hero_id])]
	var initial_focus: Button
	for branch in base.promotion_ids:
		var p = catalog.professions[branch]
		var row = HBoxContainer.new()
		column.add_child(row)
		var visual = Control.new()
		visual.custom_minimum_size = Vector2(72, 58)
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(visual)
		var actor = catalog.scene("hero").instantiate()
		# Presentation-only actor consumes the exact same VisualSet as combat.
		actor.setup(catalog.characters[StringName(hero_id)], 0, {"clock": RunClock.new()}, true)
		actor.profession = p
		actor.position = Vector2(36, 30)
		actor.scale = Vector2(2, 2)
		visual.add_child(actor)
		branch_previews[branch] = actor
		var action = button(String(branch).capitalize() + " — " + p.description, func():
			selected = String(branch)
			preview.text = p.description + "\nHP %d · damage %d · reach %d" % [p.starting_stats.max_health, p.starting_stats.damage, p.starting_stats.reach]
			confirm_button.disabled = PromotionService.reason(payload, hero_id, selected) != "")
		action.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		action.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.remove_child(action)
		row.add_child(action)
		if initial_focus == null: initial_focus = action
	preview = label("Choose a branch to preview. Fifth effects count fired attacks once.", 11)
	preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	confirm_button = button("Confirm permanent branch / spend 1 item", submit)
	confirm_button.disabled = true
	button("Cancel — spend nothing", func(): canceled.emit())
	initial_focus.grab_focus()

func submit() -> void:
	if submitted or selected.is_empty() or PromotionService.reason(payload, hero_id, selected) != "": return
	submitted = true
	confirm_button.disabled = true
	confirmed.emit(hero_id, selected, revision)
