extends AnimatedSprite2D
## Presentation adapter: animation uses game time, never its own playback clock.
var _elapsed: float = 0.0
const HitReaction=preload("res://presentation/hit_reaction.gd")
@export_range(0.1,0.6,0.01) var hurt_seconds:=0.34
@export_range(2.0,12.0,0.5) var hurt_distance:=7.0
var hurt_active:=false
var _reaction:=HitReaction.new()
func _present_hit(pose: Dictionary, seconds: float) -> bool:
	if not pose.has("hp"):return false
	_reaction.duration=hurt_seconds;_reaction.distance=hurt_distance
	var reaction=_reaction.observe(pose.hp,pose.get("shield",0),seconds,-float(pose.facing))
	hurt_active=reaction.active
	if not hurt_active:return false
	visible=true
	animation=&"idle";frame=0
	offset=reaction.offset
	rotation=reaction.rotation
	scale=reaction.scale
	modulate=Color(1.1,1.7,1.9) if reaction.kind=="shield" else Color(1.8,1.15,1.12).lerp(Color.WHITE,1-reaction.flash)
	if not pose.alive:
		rotation=-float(pose.facing)*0.65;scale=Vector2(1,0.65);offset.y=13
	return true

func reset_pose() -> void:
	_elapsed = 0.0
	_reaction.clear();hurt_active=false
	rotation=0;scale=Vector2.ONE
	offset = Vector2.ZERO
	animation = &"idle"
	frame = 0
	visible = true
	flip_h = false
	modulate = Color.WHITE

func present(pose: Dictionary, seconds: float) -> void:
	offset = Vector2.ZERO
	rotation=0;scale=Vector2.ONE
	if _present_hit(pose,seconds):return
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
