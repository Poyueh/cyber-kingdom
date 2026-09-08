extends AnimatedSprite2D
## Presentation adapter: animation uses game time, never its own playback clock.
const KnightFrames = preload("res://data/knight_animation_frames.tres")
var _elapsed: float = 0.0

func _init() -> void:
	sprite_frames = KnightFrames
	animation = &"idle"
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func reset_pose() -> void:
	_elapsed = 0.0
	animation = &"idle"
	frame = 0
	visible = true
	flip_h = false
	modulate = Color.WHITE

func present(pose: Dictionary, seconds: float) -> void:
	visible = pose.alive
	if not visible:
		return
	flip_h = pose.facing < 0
	modulate = Color(1.35, 1.35, 1.5) if pose.invulnerable else Color.WHITE
	var progress: float = float(pose.get("attack_progress", 1.0))
	if progress < 1.0:
		animation = &"attack"
		_elapsed = 0.0
		frame = clampi(int(progress * sprite_frames.get_frame_count(animation)), 0, sprite_frames.get_frame_count(animation) - 1)
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
