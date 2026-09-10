extends "res://presentation/fighter_visual.gd"
## New locomotion drawings are isolated from the editable combat animation resource.
const MotionFrames=preload("res://data/knight_motion_frames.tres")
var _motion_time:=0.0
var _was_grounded:=true
var _landing:=0.0
func _init() -> void:
	sprite_frames=preload("res://data/knight_animation_frames.tres")
	_bind_motion()
	animation=&"idle"
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
func _ready() -> void:
	_bind_motion() # PackedScene may assign its own frames after _init.
func _bind_motion() -> void:
	sprite_frames=sprite_frames.duplicate()
	for clip in [&"run",&"jump"]:
		if sprite_frames.has_animation(clip): sprite_frames.remove_animation(clip)
		sprite_frames.add_animation(clip)
		sprite_frames.set_animation_speed(clip,MotionFrames.get_animation_speed(clip))
		for index in range(MotionFrames.get_frame_count(clip)):
			sprite_frames.add_frame(clip,MotionFrames.get_frame_texture(clip,index))
func reset_pose() -> void:
	super.reset_pose()
	_motion_time=0
	_landing=0
	_was_grounded=true
	rotation=0
	scale=Vector2.ONE
func present(pose: Dictionary, seconds: float) -> void:
	super.present(pose,seconds)
	if not pose.alive: return
	if seconds>0 and is_finite(seconds):
		_motion_time+=seconds
		_landing=maxf(0,_landing-seconds)
	var grounded: bool=pose.get("grounded",true)
	if grounded and not _was_grounded: _landing=0.12
	_was_grounded=grounded
	rotation=0
	scale=Vector2.ONE
	if not grounded and not pose.get("dashing",false) and float(pose.get("attack_progress",1.0))>=1:
		animation=&"jump"
		var vy: float=pose.get("vertical_speed",0.0)
		frame=0 if vy < -450 else (1 if vy < -80 else (2 if vy<80 else 3))
		offset=Vector2.ZERO
	elif animation==&"idle":
		offset=Vector2(0,sin(_motion_time*2.8)*0.7)
	elif animation==&"run":
		offset=Vector2(0,-absf(sin(_motion_time*TAU*3))*0.7)
	elif animation==&"attack":
		var p: float=pose.get("attack_progress",0.0)
		offset=Vector2(sin(p*PI)*3*pose.facing,0)
	if _landing>0 and grounded:
		var amount:=sin(_landing/0.12*PI)*0.055
		scale=Vector2(1+amount,1-amount)
		offset.y+=amount*24
