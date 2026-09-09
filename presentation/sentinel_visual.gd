extends "res://presentation/fighter_visual.gd"
## Sentinel artwork binding; its windup clip makes the attack warning visible.
func _init() -> void:
	sprite_frames = preload("res://data/sentinel_animation_frames.tres")
	animation = &"idle"
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
