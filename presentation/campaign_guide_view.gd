extends Node2D
const Icons=preload("res://presentation/ui_icons.gd")
const SYMBOLS={"upgrade":"camp","core":"camp","delivery":"hammer","escort":"hammer","join":"rift","fight":"rift","seal":"rift","clear_enemies":"sword","rift":"rift","camp":"camp","recruit":"person","tool":"hammer","harvest":"tree","hunter":"bow","guard":"sword","wall":"wall","defend":"shield","chest":"chest","trade":"trade","collect":"crystal","explore":"map"}
var hint: Dictionary={}
var safe:=Rect2()
var player_x:=0.0
var active_button:=Rect2()
var can_invest:=false
var touch_hint:=true
var pulse:=0.0
var _style: StyleBoxFlat
func present(advice: Dictionary,area: Rect2,x: float,button: Rect2,ready: bool) -> void:
 hint=advice
 safe=area
 player_x=x
 active_button=button
 can_invest=ready
 visible=not hint.is_empty()
 queue_redraw()
func _process(seconds: float) -> void:
 if not visible:return
 pulse=fmod(pulse+seconds,2.0)
 queue_redraw()
func _icon(key: String,at: Vector2,size: float=28,tint:=Color("dce9dc")) -> void:
 draw_texture_rect(Icons.get_icon(key),Rect2(at-Vector2.ONE*size/2,Vector2.ONE*size),false,tint)
func _draw() -> void:
 if hint.is_empty():return
 var origin:=safe.position+Vector2(safe.size.x*0.5-112,138 if safe.size.x>=832 else 178)
 var area:=Rect2(origin,Vector2(224,54))
 if _style==null:
  _style=StyleBoxFlat.new()
  _style.bg_color=Color(0.03,0.08,0.11,0.86)
  _style.set_corner_radius_all(9)
 draw_style_box(_style,area)
 var center:=origin+Vector2(112,24)
 var distance: float=hint.x-player_x
 var operation: String="hand" if can_invest else "sword" if hint.action=="fight" else "shield" if hint.action=="stay" else "left" if distance < -40 else "right" if distance>40 else "person" if hint.action=="follow" else "gear" if hint.action=="wait" else "shield" if hint.kind=="defend" else "map"
 _icon(operation,center-Vector2(65,0))
 _icon("right",center-Vector2(21,0),18)
 _icon(SYMBOLS.get(hint.kind,"map"),center+Vector2(18,0),30,Color("8fe2d4"))
 if hint.has("detail"):_icon(hint.detail,center+Vector2(69,0),20)
 elif hint.kind=="harvest":_icon("hammer",center+Vector2(69,0),20)
 elif hint.action=="invest":_icon("crystal",center+Vector2(69,0),20)
 elif hint.action=="wait":_icon("person",center+Vector2(69,0),20)
 elif hint.kind=="defend":_icon("moon",center+Vector2(69,0),20)
 if hint.has("seal_progress"):
  draw_rect(Rect2(origin+Vector2(48,44),Vector2(128,4)),Color("3c5258"))
  draw_rect(Rect2(origin+Vector2(48,44),Vector2(128*clampf(hint.seal_progress,0,1),4)),Color("80d7c5"))
 elif hint.stage>0 and hint.stage<=6:
  for i in range(6):draw_circle(origin+Vector2(82+i*12,46),2,Color("80d7c5") if i<hint.stage else Color("3c5258"))
 if hint.has("requirement_count"):
  draw_string(ThemeDB.fallback_font,origin+Vector2(198,37),str(hint.requirement_count),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("dce9dc"))
 if can_invest and touch_hint:
  var alpha:=0.35+0.35*sin(pulse*PI)
  draw_arc(active_button.get_center(),36,-PI/2,TAU-PI/2,40,Color(0.50,0.94,0.82,alpha),2)
  _icon("hand",active_button.position+Vector2(32,-19),24,Color(0.76,0.96,0.86,0.65+0.25*sin(pulse*PI)))
