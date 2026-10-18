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
	label("Active time %s    •    Level %d    •    %d kills" % [summary.time, summary.level, summary.kills])
	if summary.has("rewards"):
		label("Party: " + ", ".join(summary.participants.map(func(id): return String(id).capitalize())), 11)
		if summary.has("participant_gains"):
			for gain in summary.participant_gains:
				label("%s: +%d XP · Lv %d → %d%s" % [gain.id.capitalize(), gain.xp, gain.from_level, gain.level, " · CAP 30 (overflow discarded)" if gain.capped else ""], 11)
			label("Saved: +%d promotion items" % summary.rewards.items, 11)
		else:
			label("Saved: +%d permanent XP per participant  /  +%d promotion items" % [summary.rewards.xp, summary.rewards.items], 11)
		label("Saved: +%d recruitment tickets%s" % [summary.rewards.get("tickets", 0), " · Sera recruited!" if summary.rewards.get("sera", false) else ""], 11)
		label("Starting progression changed. Retry keeps the seed and earned progress." if summary.get("starting_changed", false) else "Retry keeps the seed; matching starts and decisions repeat randomness.", 10)
	else:
		label("Run upgrades reset. Matching starts and decisions repeat randomness.", 11)
	button("Retry  /  same hero and seed", func(): retry_requested.emit()).grab_focus()
	button("New Expedition  /  new seed", func(): new_requested.emit())
	button("Return to guild", func(): selection_requested.emit())
