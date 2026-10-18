extends "res://scripts/ui/screen.gd"

signal draw_requested(count: int)
signal exchange_requested(hero: String)
signal acknowledged(draw: String)
signal back_requested
var payload: Dictionary = ProfileData.fresh()
var pool: GachaPoolDefinition = load("res://data/gacha/guild_pool.tres")
var mode: String = "pool"
var pending: Dictionary = {}
var consumed: bool = false

func _ready() -> void:
	rebuild()

func rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	consumed = false
	build_scroll(570)
	column.add_theme_constant_override("separation", 2)
	label("GUILD RECRUITMENT", 23, Color(0.57, 0.93, 0.89))
	label("%d earned tickets  ·  %d duplicate tokens" % [payload.tickets, payload.tokens], 12)
	var awaiting = RecruitmentHistory.awaiting(payload)
	if not awaiting.is_empty():
		label("SAVED DRAW  /  original ordered results", 12)
		show_receipt(awaiting)
		button("Continue / acknowledge saved results", func(): send_once(func(): acknowledged.emit(awaiting.operation_id))).grab_focus()
		return
	if mode == "confirm":
		label(pending.message, 13)
		button("Confirm", func(): send_once(func():
			if pending.has("count"): draw_requested.emit(pending.count)
			else: exchange_requested.emit(pending.hero))).grab_focus()
		button("Cancel (no spending)", func(): mode = "pool"; rebuild())
		return
	if mode == "history":
		label("SAVED HISTORY  /  viewing never spends tickets", 12)
		if payload.history.is_empty(): label("No draws yet.", 12)
		for receipt in payload.history:
			show_receipt(receipt)
		button("Back to recruitment", func(): mode = "pool"; rebuild()).grab_focus()
		return
	for entry in pool.entries:
		label("%s — %.0f%%" % [String(entry.character_id).capitalize(), entry.probability(pool.total_weight()) * 100.0], 15)
	label("Total 100% · each pull independent · ownership never changes odds", 10)
	label("Duplicate = 1 token. No pity or guaranteed ten-pull bonus.", 11)
	for count in [pool.single_cost, pool.batch_count]:
		var text = "%s — %d ticket%s" % ["Single pull" if count == 1 else "Ten pull", count, "" if count == 1 else "s"]
		if payload.tickets < count: text += " (need %d more)" % (count - payload.tickets)
		var action = button(text, func():
			pending = {"count": count, "message": "Spend %d earned tickets for %d independent draw(s)?" % [count, count]}
			mode = "confirm"
			rebuild())
		action.disabled = payload.tickets < count
	label("EXCHANGE  /  5 duplicate tokens for one unowned pool hero", 10)
	for id in ["brann", "nyra"]:
		if payload.owned.has(id): continue
		var why = TokenExchangeService.reason(payload, id)
		var action = button("Recruit " + id.capitalize() + " — 5 tokens" + (" (need %d more)" % (5 - payload.tokens) if why != "" else ""), func():
			pending = {"hero": id, "message": "Exchange 5 tokens for " + id.capitalize() + "?"}
			mode = "confirm"
			rebuild())
		action.disabled = why != ""
	if payload.owned.has("brann") and payload.owned.has("nyra"): label("Pool collection complete. Excess tokens remain saved.", 11)
	button("View saved history", func(): mode = "history"; rebuild())
	button("Back to guild", func(): back_requested.emit()).grab_focus()

func send_once(action: Callable) -> void:
	if consumed: return
	consumed = true
	for item in column.get_children():
		if item is Button: item.disabled = true
	action.call()

func show_receipt(receipt: Dictionary) -> void:
	label("Draws %d–%d · cost %d tickets" % [receipt.sequence_start + 1, receipt.sequence_end, receipt.cost], 11)
	for i in range(receipt.results.size()):
		var result = receipt.results[i]
		label("%d. %s — %s" % [i + 1, String(result.hero).capitalize(), "Duplicate → +1 token" if result.duplicate else "New hero recruited"], 11)
