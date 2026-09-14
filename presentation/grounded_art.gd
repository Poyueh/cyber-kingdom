extends RefCounted
## Transparent bottom padding must not lift the visible feet/root off the ground.
static var _padding: Dictionary={}
static func anchor(texture: Texture2D, at: Vector2, scale: float=1.0) -> Vector2:
 var key:=texture.get_instance_id()
 if not _padding.has(key):
  var image:=texture.get_image()
  var bounds:=image.get_used_rect() if image!=null else Rect2i()
  _padding[key]=texture.get_height()-bounds.end.y if bounds.has_area() else 0
 return at+Vector2(0,_padding[key]*scale)
