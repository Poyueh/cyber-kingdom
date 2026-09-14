extends RefCounted
## Preserve the authored face, clothing and motion while shortening torso/legs at a fixed foot anchor.
static func draw(view: Node2D, texture: Texture2D, source: Rect2, tint: Color, head_end: float=28, foot: float=62) -> void:
 var torso: float=(foot-head_end)*0.62
 var head: float=head_end*1.15
 view.draw_texture_rect_region(texture,Rect2(-source.size.x*0.56,-torso-head,source.size.x*1.12,head),Rect2(source.position,Vector2(source.size.x,head_end)),tint)
 view.draw_texture_rect_region(texture,Rect2(-source.size.x*0.45,-torso,source.size.x*0.9,torso),Rect2(source.position+Vector2(0,head_end),Vector2(source.size.x,foot-head_end)),tint)
