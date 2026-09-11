extends "res://presentation/fighter_visual.gd"
## New locomotion drawings are isolated from the editable combat animation resource.
const MotionFrames=preload("res://data/knight_motion_frames.tres")
@export var texture_overrides: Dictionary = {}
@export var moving_attack_atlas: Texture2D
var _gait_time:=0.0
var _moving_attack: Sprite2D
var _moving_region:=AtlasTexture.new()
var _motion_time:=0.0
var _was_grounded:=true
var _landing:=0.0
func _init() -> void:
	_moving_attack=Sprite2D.new()
	_moving_attack.name="MovingAttack"
	_moving_attack.visible=false
	add_child(_moving_attack)
	sprite_frames=preload("res://data/knight_animation_frames.tres")
	_bind_motion()
	animation=&"idle"
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
func _ready() -> void:
	_bind_motion() # PackedScene may assign its own frames after _init.
	_apply_art_overrides()
func _bind_motion() -> void:
	sprite_frames=sprite_frames.duplicate()
	for clip in [&"run",&"jump"]:
		if sprite_frames.has_animation(clip): sprite_frames.remove_animation(clip)
		sprite_frames.add_animation(clip)
		sprite_frames.set_animation_speed(clip,MotionFrames.get_animation_speed(clip))
		for index in range(MotionFrames.get_frame_count(clip)):
			sprite_frames.add_frame(clip,MotionFrames.get_frame_texture(clip,index))
func _apply_art_overrides() -> void:
	# Swap atlas pixels only; preserve user-edited frame duration, region and speed.
	for clip in sprite_frames.get_animation_names():
		for index in range(sprite_frames.get_frame_count(clip)):
			var source:=sprite_frames.get_frame_texture(clip,index)
			if source is AtlasTexture and source.atlas!=null and texture_overrides.has(source.atlas.resource_path):
				var replacement: AtlasTexture=source.duplicate()
				replacement.atlas=texture_overrides[source.atlas.resource_path]
				sprite_frames.set_frame(clip,index,replacement,sprite_frames.get_frame_duration(clip,index))

func reset_pose() -> void:
	super.reset_pose()
	_gait_time=0
	self_modulate=Color.WHITE
	_moving_attack.visible=false
	_motion_time=0
	_landing=0
	_was_grounded=true
	rotation=0
	scale=Vector2.ONE
func present(pose: Dictionary, seconds: float) -> void:
	var striding: bool=pose.get("moving",false) and pose.get("grounded",true) and not pose.get("dashing",false)
	if striding and seconds>0 and is_finite(seconds):
		_gait_time+=seconds*float(pose.get("locomotion_rate",1.0))
	elif not striding and not pose.get("dashing",false):
		_gait_time=0
	super.present(pose,seconds)
	self_modulate=Color.WHITE
	_moving_attack.visible=false
	if not pose.alive: return
	var gait:=int(fposmod(_gait_time*sprite_frames.get_animation_speed(&"run"),sprite_frames.get_frame_count(&"run")))
	if animation==&"run": frame=gait
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
		offset=Vector2.ZERO
	if _landing>0 and grounded:
		var amount:=sin(_landing/0.12*PI)*0.055
		scale=Vector2(1+amount,1-amount)
		offset.y+=amount*24

	if striding and animation==&"attack" and moving_attack_atlas!=null:
		# Offline-composited torso + gait keeps runtime work to one texture region.
		_moving_region.atlas=moving_attack_atlas
		_moving_region.region=Rect2(frame*128,gait*96,128,96)
		_moving_attack.texture=_moving_region
		_moving_attack.flip_h=flip_h
		_moving_attack.visible=true
		self_modulate=Color(1,1,1,0)
		offset=Vector2.ZERO
