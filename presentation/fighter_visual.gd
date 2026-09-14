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
	if pose.get("dashing", false) and sprite_frames.has_animation(&"dash"):
		animation = &"dash"
		_elapsed = 0.0
		frame = _action_frame(&"dash", float(pose.get("dash_progress", 0.0)))
		return
	var progress: float = float(pose.get("attack_progress", 1.0))
	if progress < 1.0:
		animation = &"attack"
		_elapsed = 0.0
		frame = _action_frame(&"attack", progress)
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

func _action_frame(clip: StringName, progress: float) -> int:
	var count := sprite_frames.get_frame_count(clip)
	var total := 0.0
	for index in range(count):
		total += sprite_frames.get_frame_duration(clip, index)
	var remaining := clampf(progress, 0.0, 1.0) * total
	for index in range(count):
		remaining -= sprite_frames.get_frame_duration(clip, index)
		if remaining < 0.0:
			return index
	return maxi(0, count - 1)
