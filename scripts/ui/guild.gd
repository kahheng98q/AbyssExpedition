extends "res://scripts/ui/screen.gd"

signal expedition_requested
signal roster_requested
signal recruitment_requested
signal quit_requested
var catalog: ContentCatalog
var payload: Dictionary = ProfileData.fresh()

func _ready() -> void:
	build_scroll(590)
	column.add_theme_constant_override("separation", 4)
	label("THE TIDEWATCH GUILD", 23, Color(0.57, 0.93, 0.89))
	label("CHAPTER 1 / AETHERAN COAST · " + ("Completed · replay anytime" if payload.chapters.coast else "Confront the Tidebound Hierophant"), 12)
	label("The ocean cult calls from beneath the tide. Bargain for power; survive its price.", 10)
	label("%d / 6 heroes  ·  %d items  ·  %d tickets  ·  %d duplicate tokens" % [payload.owned.size(), payload.promotion_items, payload.tickets, payload.tokens], 12)
	var navigation = HBoxContainer.new()
	column.add_child(navigation)
	for entry in [["Expedition", func(): expedition_requested.emit()], ["Roster / party / promote", func(): roster_requested.emit()], ["Recruit / exchange / history", func(): recruitment_requested.emit()]]:
		var action = button(entry[0], entry[1])
		column.remove_child(action)
		action.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		navigation.add_child(action)
	navigation.get_child(0).grab_focus()
	label("CHARACTER COLLECTION  /  all three starting classes are always owned", 10)
	for id in ContentCatalog.CHARACTERS:
		var hero = catalog.characters[StringName(id)]
		var route = "Starter · always available" if id in ProfileData.STARTERS else ("Story · minute-4 rescue" if id == "sera" else "Draw 50% · or exchange 5 tokens")
		label("%s · %s · %s · %s" % [hero.display_name, String(hero.base_profession.id).capitalize(), "Owned" if payload.owned.has(id) else "Locked", route], 11)
	label("Sera: stay in the rescue circle for 30 active seconds. Repeats earn 1 ticket.", 10)
	label("Earn tickets: +1 at 5:00; +2 for victory. Abandonment grants no rewards.", 10)
	button("Quit", func(): quit_requested.emit())
