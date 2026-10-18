extends "res://scripts/ui/screen.gd"

signal new_expedition
signal quit_requested

func _ready() -> void:
	build()
	label("ABYSS EXPEDITION", 27, Color(0.57, 0.93, 0.89))
	label("RECRUITMENT AND GACHA   /   MILESTONE 3", 11, Color(1, 0.78, 0.43))
	label("Survive the coast. Build your hero. Defeat the Hierophant.")
	label("WASD / arrows: move    •    Attacks fire automatically")
	label("Collect cyan gems for random upgrades. Escape pauses.")
	label("Boss arrives at 9:00. Victory requires defeating it.")
	label("Original placeholder art  •  Offline  •  Earned tickets only", 10)
	button("New Expedition  →", func(): new_expedition.emit()).grab_focus()
	button("Quit", func(): quit_requested.emit())
