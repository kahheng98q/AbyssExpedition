extends Button

func set_state(caption: String, reason: String="", pending: bool=false) -> void:
	disabled=not reason.is_empty() or pending
	text=caption+("\n"+reason if not reason.is_empty() else "")+(" · Saving" if pending else "")
	tooltip_text=reason

func _make_custom_tooltip(for_text: String) -> Object:
	var tip=load("res://scenes/ui/components/tooltip.tscn").instantiate()
	tip.message=for_text
	return tip
