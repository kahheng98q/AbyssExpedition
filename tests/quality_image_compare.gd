extends SceneTree
func _initialize() -> void:
	var failures: int = 0
	var different_frames: int = 0
	for frame in ["aren-combat", "aren-moving", "lia-combat", "lia-moving", "milo-combat", "milo-moving", "boss-warning"]:
		var before = Image.load_from_file("res://screenshots/quality-20261018/after-uncached-%s.png" % frame)
		var after = Image.load_from_file("res://screenshots/quality-20261018/after-field-cache-%s.png" % frame)
		var changed: int = 0
		var max_delta: float = 0
		var examples: Array = []
		if before == null or after == null or before.get_size() != after.get_size():
			failures += 1
			continue
		for y in range(before.get_height()):
			for x in range(before.get_width()):
				var a = before.get_pixel(x, y)
				var b = after.get_pixel(x, y)
				if a != b:
					changed += 1
					max_delta = maxf(max_delta, maxf(absf(a.r-b.r), maxf(absf(a.g-b.g), absf(a.b-b.b))))
					if examples.size() < 4: examples.append([x, y, a.to_html(), b.to_html()])
		print("CACHE PIXEL COMPARE ", frame, " changed=", changed, "/", before.get_width()*before.get_height())
		print("CACHE COLOR DELTA max=", max_delta * 255, " examples=", examples)
		if changed > 0: different_frames += 1
		# Raster caching quantizes the intermediate surface to RGBA8. Permit only
		# one channel level (plus float epsilon), not geometry/color redesign.
		if max_delta * 255 > 1.01: failures += 1
	print("CACHE PIXEL DIFFERENT FRAMES ", different_frames, " RGBA8_TOLERANCE_FAILURES ", failures)
	quit(0 if failures == 0 else 1)
