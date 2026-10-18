extends Logger

var mutex: Mutex = Mutex.new()
var errors: Array[String] = []

func _log_error(_function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
	if error_type == Logger.ERROR_TYPE_WARNING: return
	mutex.lock()
	errors.append("%s:%d %s %s" % [file, line, code, rationale])
	mutex.unlock()

func snapshot() -> Array[String]:
	mutex.lock()
	var result = errors.duplicate()
	mutex.unlock()
	return result
