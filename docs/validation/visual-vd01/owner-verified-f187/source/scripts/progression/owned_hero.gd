class_name OwnedHero
extends RefCounted

static func level(total_xp: int) -> int:
	return mini(30, 1 + total_xp / 100)

static func record(id: String, xp: int = 0, promotion: String = "") -> Dictionary:
	xp = clampi(xp, 0, 2900)
	return {"character_id": id, "total_xp": xp, "level": level(xp), "progress_to_next": xp % 100 if xp < 2900 else 0, "promotion_id": promotion}
