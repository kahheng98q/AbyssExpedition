extends "res://scripts/ui/screen.gd"

signal resume_requested
signal abandon_requested
signal quit_requested
var confirmation: Button
var run

func _ready() -> void:
	build(350)
	label("EXPEDITION PAUSED", 23, Color(0.57, 0.93, 0.89))
	label("Combat and active time are frozen.")
	if run != null:
		label("Seed %d · Hero Lv %d · Run Lv %d" % [run.snapshot.seed_value,run.hero.permanent_level,run.progression.level],12)
		label("WASD / arrows move · Auto attack · C Abyss details",12)
	button("Resume", func(): resume_requested.emit()).grab_focus()
	confirmation = button("Abandon expedition…", confirm_abandon)
	button("Quit game", func(): quit_requested.emit())

func confirm_abandon() -> void:
	if confirmation.text == "Confirm abandonment": abandon_requested.emit()
	else:
		confirmation.text = "Confirm abandonment"
		armed_at = Time.get_ticks_msec() + 180
