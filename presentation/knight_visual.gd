extends AnimatedSprite2D
## Presentation-only pose adapter. Game time drives animation so pause stays exact.
const IdleFrames = preload("res://data/knight_idle_frames.tres")
var _elapsed: float = 0.0

func _init() -> void:
	sprite_frames = IdleFrames
	animation = &"idle"
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func reset_pose() -> void:
	_elapsed = 0.0
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
	if pose.moving:
		_elapsed = 0.0
		frame = 0
	elif seconds > 0.0 and is_finite(seconds):
		var count := sprite_frames.get_frame_count(animation)
		var speed := sprite_frames.get_animation_speed(animation)
		_elapsed = fmod(_elapsed + seconds, float(count) / speed)
		frame = int(_elapsed * speed) % count
