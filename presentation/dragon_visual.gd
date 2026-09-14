extends RefCounted
## Original articulated pixel silhouette. Integer vertices preserve a readable low-resolution shape.
static func polygon(view: Node2D, points: Array, color: Color) -> void:
 var vertices=PackedVector2Array()
 for p in points:vertices.append(Vector2(p[0],p[1]).round())
 view.draw_colored_polygon(vertices,color)
 vertices.append(vertices[0]);view.draw_polyline(vertices,Color("172235"),2)
static func draw(view: Node2D, enemy: Dictionary, time: float) -> void:
 var t:=time*2.6
 var lift:=roundf(sin(t)*16)
 var direction: float=enemy.get("direction",-1.0)
 var hurt: bool=enemy.fighter.invulnerability_remaining>0
 view.draw_set_transform(Vector2(enemy.x,430),0,Vector2(direction*1.6,1.6))
 # Tail, far wing, torso, near wing, armored neck and horned jaw.
 polygon(view,[[-22,-35],[-57,-26],[-90,-38],[-103,-55],[-99,-32],[-65,-15],[-25,-19]],Color("35485b"))
 polygon(view,[[-12,-47],[-32,-85],[-68,-112-lift],[-43,-52],[-24,-30]],Color("38435f"))
 polygon(view,[[-36,-40],[-24,-62],[7,-65],[33,-48],[37,-29],[16,-17],[-20,-18]],Color("48586c") if not hurt else Color("d3f7e5"))
 polygon(view,[[-17,-53],[-43,-94-lift],[13,-111-lift],[61,-80-lift],[28,-75],[-1,-37]],Color("6b496a"))
 for tip in [Vector2(-43,-94-lift),Vector2(13,-111-lift),Vector2(61,-80-lift)]:
  view.draw_line(Vector2(-17,-53),tip,Color("bb8a9b"),2)
 polygon(view,[[10,-30],[29,-59],[34,-83],[53,-87],[61,-72],[54,-49],[42,-26]],Color("54687a"))
 polygon(view,[[36,-85],[41,-101],[49,-87],[58,-97],[58,-84],[78,-76],[79,-66],[54,-61],[40,-70]],Color("657b87") if not hurt else Color("d3f7e5"))
 polygon(view,[[51,-62],[79,-64],[71,-53],[53,-54]],Color("3b4255"))
 view.draw_rect(Rect2(57,-78,8,3),Color("ffcf89"))
 for x in [58,65,72]:polygon(view,[[x,-64],[x+3,-64],[x+1,-58]],Color("efd8bc"))
 for x in [-24,-7,9]:
  polygon(view,[[x,-21],[x+9,-21],[x+11,-6],[x+21,-3],[x+20,0],[x,0]],Color("364454"))
  view.draw_line(Vector2(x+3,-3),Vector2(x+19,-3),Color("9ba998"),2)
 for i in range(5):
  var x: float=-25+i*12
  view.draw_rect(Rect2(x,-40+sin(i)*4,7,4),Color("82ccb8"))
  view.draw_rect(Rect2(x,-31+sin(i)*4,5,2),Color("b4e7c5"))
 view.draw_set_transform(Vector2.ZERO)
 if enemy.windup>0:
  var aim: float=enemy.target.x
  var progress: float=1-enemy.windup/1.6
  view.draw_line(Vector2(aim-100,428),Vector2(aim+100,428),Color(1,0.53,0.3,0.5+progress*0.4),4)
  for i in range(12):
   var p: Vector2=Vector2(enemy.x+direction*100,325)+Vector2(cos(i*2.1+t*3),sin(i*2.1+t*3))*((1-progress)*25+4)
   view.draw_rect(Rect2(p.round(),Vector2(3,3)),Color("ffd694"))
