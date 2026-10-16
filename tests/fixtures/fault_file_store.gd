extends RefCounted

var stage: String = ""
var remaining: int = 1

func fail(point: String) -> bool:
	if point != stage or remaining <= 0: return false
	remaining -= 1
	return true
