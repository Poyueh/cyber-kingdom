extends RefCounted
## Soft overlapping cloud particles fade on discovery and share the paused world clock.
var _cloud: GradientTexture2D
var _revealed: Dictionary={}
func draw(view: Node2D, regions: Array, time: float, player_x: float, area: Rect2) -> void:
 if _cloud==null:
  _cloud=GradientTexture2D.new();_cloud.width=128;_cloud.height=64
  _cloud.fill=GradientTexture2D.FILL_RADIAL
  _cloud.fill_from=Vector2(0.5,0.5);_cloud.fill_to=Vector2(1,0.5)
  var gradient=Gradient.new()
  gradient.set_color(0,Color(0.46,0.64,0.69,0.28))
  gradient.set_color(1,Color(0.46,0.64,0.69,0))
  _cloud.gradient=gradient
 for i in range(regions.size()):
  var r: Dictionary=regions[i]
  if r.discovered and not _revealed.has(i):_revealed[i]=time
  var fade: float=maxf(0,1-(time-float(_revealed.get(i,time)))/2.2) if r.discovered else 1.0
  if fade<=0 or r.x>area.end.x+250 or r.x+r.width<area.position.x-250:continue
  for layer in range(3):
   for n in range(ceili(r.width/90.0)+2):
    var x: float=r.x-80+n*90+sin(time*0.17+n*2.3+i)*52
    var y: float=175+layer*90+sin(time*0.26+n+i)*24
    var near:=smoothstep(90,320,absf(x-player_x))
    view.draw_texture_rect(_cloud,Rect2(x-170,y-65,340,150),false,Color(1,1,1,fade*near))
