class_name PlayerController
extends RefCounted

static func movement(left: float, right: float, up: float, down: float) -> Vector2:
	return Vector2(right - left, down - up).limit_length(1.0)

static func read_movement_actions() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

static func simulate(actor, direction: Vector2) -> void:
	actor.velocity = direction.limit_length(1.0) * actor.stats.speed + actor.knockback
	actor.move_and_slide()
	actor.position = actor.position.clamp(Vector2(8, 8), Vector2(952, 532))
	actor.knockback = actor.knockback.move_toward(Vector2.ZERO, 9.0)
