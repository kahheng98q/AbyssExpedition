extends SceneTree

var errors = preload("res://tests/error_capture.gd").new()
var scripts: int = 0
var scenes: int = 0
var resources: int = 0
var failures: int = 0

func _initialize() -> void:
	OS.add_logger(errors)
	call_deferred("run")

func scan(directory: String) -> void:
	for folder in DirAccess.get_directories_at(directory):
		scan(directory.path_join(folder))
	for file in DirAccess.get_files_at(directory):
		var path = directory.path_join(file)
		if file.get_extension() not in ["gd", "tscn", "tres"]: continue
		var resource = load(path)
		if resource == null:
			failures += 1
			printerr("FAIL: cannot load " + path)
		elif file.get_extension() == "gd":
			scripts += 1
			if not resource.can_instantiate():
				failures += 1
				printerr("FAIL: cannot instantiate script " + path)
		elif file.get_extension() == "tscn":
			scenes += 1
			if not resource.can_instantiate():
				failures += 1
				printerr("FAIL: invalid PackedScene " + path)
		else:
			resources += 1

func run() -> void:
	for directory in ["res://scripts", "res://tests", "res://scenes", "res://data"]:
		scan(directory)
	for error in errors.snapshot():
		failures += 1
		printerr("FAIL: " + error)
	OS.remove_logger(errors)
	print("PROJECT AUDIT: %d scripts; %d scenes; %d Resources; %d failures" % [scripts, scenes, resources, failures])
	quit(0 if failures == 0 else 1)
