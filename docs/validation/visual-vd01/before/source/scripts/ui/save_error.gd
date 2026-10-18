extends "res://scripts/ui/screen.gd"

signal retry_requested
signal recovery_requested(fresh: bool)
signal stale_lock_requested
signal close_requested
var writer: SaveCoordinator

func _ready() -> void:
	build(550)
	label("PROGRESS NEEDS ATTENTION", 20, Color(1, 0.67, 0.5))
	label(writer.error if writer != null else "Storage unavailable.", 12).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if writer != null:
		label("Save location: " + ProjectSettings.globalize_path(writer.store.root), 10).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if writer.state == "save-blocked":
			label("This action is pending. Retry saves the same result once.", 11)
			button("Retry pending action", func(): retry_requested.emit()).grab_focus()
		elif writer.state == "locked":
			label("Recovery is safe only after ALL other game instances are closed.", 11)
			button("I closed other instances — recover stale lock", func(): stale_lock_requested.emit()).grab_focus()
		elif writer.state == "load-blocked":
			button("Retry loading directory", func(): retry_requested.emit()).grab_focus()
		elif writer.state == "recovery-required":
			button("Retry loading", func(): retry_requested.emit()).grab_focus()
			if not writer.recovery.is_empty():
				label("Recovery saved at " + writer.recovery.envelope.saved_at_utc + " UTC", 11)
				label("Restoring may lose progress after this recovery save.", 11)
				button("Confirm restore this recovery state", func(): recovery_requested.emit(false))
			else:
				label("A new profile loses existing progress. Damaged files are kept.", 11)
				button("Confirm create a new starter profile", func(): recovery_requested.emit(true))
	button("Close game", func(): close_requested.emit())
