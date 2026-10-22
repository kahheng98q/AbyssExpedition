extends "res://scripts/ui/screen.gd"

const SwordPreview = preload("res://scripts/ui/promotion_preview.gd")

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
var host_overlay: Control

func _ready() -> void:
	build_scroll(590)
	column.add_theme_constant_override("separation", 3)
	label("PROMOTE " + hero_id.to_upper(), 22)
	label("Permanent choice · requires level 15 and one item · no respec", 11)
	var why = PromotionService.reason(payload, hero_id)
	label("Ready to promote" if why == "" else why, 12, Color(1, 0.8, 0.4))
	label("Retains " + String(catalog.characters[StringName(hero_id)].passive.id).capitalize(), 11)
	var base = catalog.professions[StringName(ProfileData.BASES[hero_id])]
	var sword_row: HBoxContainer
	if base.id == &"swordsman":
		label("演示 · 示例数值 · 节奏示意", 10)
		sword_row = HBoxContainer.new()
		sword_row.add_theme_constant_override("separation", 8)
		column.add_child(sword_row)
	var initial_focus: Button
	for branch in base.promotion_ids:
		var p = catalog.professions[branch]
		var row: Container
		if sword_row != null:
			row = VBoxContainer.new()
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			sword_row.add_child(row)
			var visual = SwordPreview.new()
			visual.setup(p, hero_id)
			visual.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(visual)
			branch_previews[branch] = visual
		else:
			row = HBoxContainer.new()
			column.add_child(row)
			var visual = Control.new()
			visual.custom_minimum_size = Vector2(72, 58)
			visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(visual)
			var actor = catalog.scene("hero").instantiate()
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
	button("Cancel — spend nothing", cancel)
	initial_focus.grab_focus()
	if is_instance_valid(host_overlay):
		host_overlay.visibility_changed.connect(update_occlusion)
		update_occlusion()

func submit() -> void:
	if submitted or selected.is_empty() or PromotionService.reason(payload, hero_id, selected) != "": return
	submitted = true
	confirm_button.disabled = true
	stop_previews()
	confirmed.emit(hero_id, selected, revision)

func stop_previews() -> void:
	for visual in branch_previews.values():
		if visual.has_method("stop"): visual.stop()

func cancel() -> void:
	stop_previews()
	canceled.emit()

func update_occlusion() -> void:
	for visual in branch_previews.values():
		if visual.has_method("set_occluded"): visual.set_occluded(is_instance_valid(host_overlay) and host_overlay.visible)

func _exit_tree() -> void:
	stop_previews()
	if is_instance_valid(host_overlay) and host_overlay.visibility_changed.is_connected(update_occlusion): host_overlay.visibility_changed.disconnect(update_occlusion)
