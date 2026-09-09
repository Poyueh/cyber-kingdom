extends Node2D
## Short, deterministic pixel bursts driven by gameplay time. No damage rules.
const LIFETIME := 0.18
var _bursts: Array[Dictionary] = []

func trigger(point: Vector2, facing: int, color: Color) -> void:
	_bursts.append({"point": point, "facing": facing, "color": color, "age": 0.0})
	if _bursts.size() > 8:
		_bursts.pop_front()
	queue_redraw()

func advance(seconds: float) -> void:
	if seconds <= 0.0 or not is_finite(seconds):
		return
	for burst in _bursts:
		burst.age += seconds
	_bursts = _bursts.filter(func(burst): return burst.age < LIFETIME)
	queue_redraw()

func clear() -> void:
	_bursts.clear()
	queue_redraw()

func has_impacts() -> bool:
	return not _bursts.is_empty()

func camera_offset(strength: float) -> Vector2:
	if _bursts.is_empty() or strength <= 0.0:
		return Vector2.ZERO
	var burst: Dictionary = _bursts.back()
	var fade := maxf(0.0, 1.0 - float(burst.age) / 0.1)
	var direction := 1.0 if int(float(burst.age) * 60.0) % 2 == 0 else -1.0
	return Vector2(roundf(direction * strength * fade), 0.0)

func _draw() -> void:
	for burst in _bursts:
		var age: float = burst.age
		var origin: Vector2 = burst.point
		var fade := 1.0 - age / LIFETIME
		var color: Color = burst.color
		color.a = fade
		if age < 0.06:
			var core := PackedVector2Array([Vector2(-6, 0), Vector2(0, -8), Vector2(6, 0), Vector2(0, 8)])
			for index in range(core.size()):
				core[index] += origin
			draw_colored_polygon(core, Color(1.0, 0.97, 0.82, fade))
		for index in range(7):
			var angle := -1.35 + index * 0.45
			var ray := Vector2(cos(angle) * float(burst.facing), sin(angle))
			var start := origin + ray * (5.0 + age * 100.0)
			var end := start + ray * (3.0 + 6.0 * fade)
			draw_line(start.round(), end.round(), color, 2.0)
