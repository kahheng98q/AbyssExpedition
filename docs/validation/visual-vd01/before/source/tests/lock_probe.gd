extends SceneTree

var lock: ProfileLock
var location: String

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var args = OS.get_cmdline_user_args()
	if args.size() < 2 or args[0] != "--root" or not args[1].begins_with("user://tests/"):
		quit(2)
		return
	location = args[1]
	lock = ProfileLock.new()
	var error = lock.recover_stale(location, args.has("--confirmed")) if args.has("--recover") else lock.acquire(location)
	if error != "":
		print("LOCK REFUSED: " + error)
		quit(4)
		return
	print("LOCK ACQUIRED")
	if args.has("--hold"):
		await create_timer(30).timeout
	lock.release()
	print("LOCK RELEASED")
	quit(0)
