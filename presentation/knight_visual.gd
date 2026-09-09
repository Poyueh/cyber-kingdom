extends "res://presentation/fighter_visual.gd"
## Knight artwork binding; playback behavior is shared with the sentinel.
func _init() -> void:
	sprite_frames = preload("res://data/knight_animation_frames.tres")
	animation = &"idle"
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
