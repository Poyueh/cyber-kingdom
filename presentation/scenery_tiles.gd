extends RefCounted
## World-stable mirrored spans meet identical source edges, including at negative coordinates.
static func layout(bounds: Rect2, width: float, scroll: float=1.0) -> Array[Dictionary]:
 var result: Array[Dictionary]=[]
 var offset: float=bounds.position.x*(1-scroll)
 var first:=floori((bounds.position.x-offset)/width)-1
 var last:=ceili((bounds.end.x-offset)/width)+1
 for index in range(first,last):
  result.append({"x":index*width+offset,"flip":posmod(index,2)==1})
 return result
static func draw(view: Node2D, texture: Texture2D, bounds: Rect2, y: float, scroll: float=1.0) -> void:
 if texture==null:return
 for span in layout(bounds,texture.get_width(),scroll):
  var width:=float(texture.get_width())
  view.draw_set_transform(Vector2(span.x+width if span.flip else span.x,y),0,Vector2(-1 if span.flip else 1,1))
  view.draw_texture(texture,Vector2.ZERO)
 view.draw_set_transform(Vector2.ZERO)
