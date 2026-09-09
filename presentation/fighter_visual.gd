extends AnimatedSprite2D
## Presentation adapter: animation uses game time, never its own playback clock.
var _elapsed: float = 0.0

func reset_pose() -> void:
	_elapsed = 0.0
	offset = Vector2.ZERO
	animation = &"idle"
	frame = 0
	visible = true
	flip_h = false
	modulate = Color.WHITE

func present(pose: Dictionary, seconds: float) -> void:
	offset = Vector2.ZERO
	visible = pose.alive
	if not visible:
		return
	flip_h = pose.facing < 0
	modulate = Color(1.35, 1.35, 1.5) if pose.invulnerable else Color.WHITE
	var progress: float = float(pose.get("attack_progress", 1.0))
	if progress < 1.0:
		animation = &"attack"
		_elapsed = 0.0
		frame = _attack_frame(progress)
		if progress < 0.4:
			offset = Vector2(-pose.facing, 0)
		elif progress < 0.75:
			offset = Vector2(pose.facing * 2, 1)
		return
	if pose.get("telegraph", false) and sprite_frames.has_animation(&"windup"):
		animation = &"windup"
		_elapsed = 0.0
		frame = 0
		return
	if not pose.get("grounded", true) or pose.get("dashing", false):
		animation = &"idle"
		_elapsed = 0.0
		frame = 0
		return
	var clip: StringName = &"run" if pose.moving else &"idle"
	if animation != clip:
		animation = clip
		_elapsed = 0.0
		frame = 0
	if seconds > 0.0 and is_finite(seconds):
		var count := sprite_frames.get_frame_count(animation)
		var speed := sprite_frames.get_animation_speed(animation)
		if count > 0 and speed > 0.0:
			_elapsed = fmod(_elapsed + seconds, float(count) / speed)
			frame = int(_elapsed * speed) % count

func _attack_frame(progress: float) -> int:
	var count := sprite_frames.get_frame_count(&"attack")
	var total := 0.0
	for index in range(count):
		total += sprite_frames.get_frame_duration(&"attack", index)
	var remaining := clampf(progress, 0.0, 1.0) * total
	for index in range(count):
		remaining -= sprite_frames.get_frame_duration(&"attack", index)
		if remaining < 0.0:
			return index
	return maxi(0, count - 1)
