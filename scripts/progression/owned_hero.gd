class_name OwnedHero
extends RefCounted

# Legacy derived value is used only while validating schema 1-3 saves.
static func level(total_xp: int) -> int:
	return mini(30, 1 + total_xp / 100)

# Optional legacy fixture arguments are ignored: ownership carries no growth.
static func record(id: String, _xp: int = 0, _promotion: String = "") -> Dictionary:
	return {"character_id": id}
