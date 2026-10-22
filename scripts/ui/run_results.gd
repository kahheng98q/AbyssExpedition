extends "res://scripts/ui/screen.gd"

signal retry_requested
signal new_requested
signal selection_requested
var summary: Dictionary

func _ready() -> void:
	build(560)
	column.add_theme_constant_override("separation", 3)
	var color = Color(0.57, 0.93, 0.89) if summary.outcome == "victory" else Color(1, 0.67, 0.5)
	label(String(summary.outcome).to_upper(), 29, color)
	if summary.has("rewards") and summary.outcome == "victory": label("CHAPTER 1 / AETHERAN COAST · Completion saved", 12)
	label("%s  /  seed %d" % [summary.hero_name, summary.seed], 15)
	label("Active time %s    •    RUN Lv%d    •    %d kills" % [summary.time, summary.level, summary.kills])
	if summary.has("rewards"):
		label("Party: " + ", ".join(summary.participants.map(func(id): return String(id).capitalize())), 11)
		label("RUN level, upgrades and branches reset next expedition.", 11)
		label("Saved: +%d recruitment tickets%s" % [summary.rewards.get("tickets", 0), " · Sera recruited!" if summary.rewards.get("sera", false) else ""], 11)
		label("Collection changed. Retry starts BASE / RUN Lv1 with the same seed." if summary.get("starting_changed", false) else "Retry keeps the seed; matching starts and decisions repeat randomness.", 10)
	else:
		label("Run upgrades reset. Matching starts and decisions repeat randomness.", 11)
	button("Retry  /  same hero and seed", func(): retry_requested.emit()).grab_focus()
	button("New Expedition  /  new seed", func(): new_requested.emit())
	button("Return to guild", func(): selection_requested.emit())
