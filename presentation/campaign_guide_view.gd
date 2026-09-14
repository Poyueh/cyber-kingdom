extends Node2D
const Icons=preload("res://presentation/ui_icons.gd")
const SYMBOLS={"dragon":"dragon","upgrade":"camp","core":"camp","delivery":"hammer","escort":"hammer","join":"rift","fight":"rift","seal":"rift","clear_enemies":"sword","rift":"rift","camp":"camp","recruit":"person","tool":"hammer","harvest":"tree","hunter":"bow","guard":"sword","wall":"wall","defend":"shield","chest":"chest","trade":"trade","collect":"crystal","explore":"map"}
var hint: Dictionary={}
var safe:=Rect2()
var player_x:=0.0
var active_button:=Rect2()
var can_invest:=false
var touch_hint:=true
var pulse:=0.0
const Motion=preload("res://presentation/spirit_motion.gd")
@export_range(40.0,100.0,2.0) var spirit_distance:=68.0
@export_range(80.0,150.0,2.0) var spirit_height:=104.0
var spirit_pose: Dictionary={"visible":false}
var _motion:=Motion.new()
# Original pixel silhouette: broken mechanical halo, hood, crystal heart and trailing cloak.
const GHOST=[
 ".....gg...gg.....",
 "....g.......g....",
 "......aaaa.......",
 "....aaabbbaa.....",
 "...aabbbbbbaa....",
 "...abdddddbba....",
 "..abbdeeeddba....",
 "..abbdeeedbba....",
 "...abbdddbbaa....",
 "....abbbbbaa.....",
 "...aaaccccaaa....",
 "..aabccggccbaa...",
 "..abbccggccbba...",
 "..abbccccccbba...",
 "...abbccccbba....",
 "...aabbbbbbaa....",
 "....aabbbbaa.....",
 "....aabbbba......",
 ".....aabba.......",
 ".....aabba.......",
 "......aab........",
 ".......aa........"]
const PALETTE={"a":Color("306b78"),"b":Color("5ab5b3"),"c":Color("9cdfca"),"d":Color("16333e"),"e":Color("d9fff0"),"g":Color("e5c997")}
func present(advice: Dictionary,area: Rect2,x: float,button: Rect2,ready: bool) -> void:
 hint=advice;safe=area;player_x=x;active_button=button;can_invest=ready
 visible=not hint.is_empty()
 queue_redraw()
func track(hero_screen: Vector2, game_time: float) -> void:
 _motion.follow_distance=spirit_distance;_motion.follow_height=spirit_height
 spirit_pose=_motion.sample(hint,hero_screen,player_x,safe,game_time)
 pulse=fposmod(game_time,2)
 queue_redraw()
func _icon(key: String,at: Vector2,size: float=24,tint:=Color("dce9dc")) -> void:
 draw_texture_rect(Icons.get_icon(key),Rect2(at-Vector2.ONE*size/2,Vector2.ONE*size),false,tint)
func _draw() -> void:
 if hint.is_empty() or not spirit_pose.visible:return
 var at: Vector2=spirit_pose.position
 var direction: float=spirit_pose.direction
 var phase: float=spirit_pose.phase
 # Distant motes drift back toward the knight; no collision or interaction target.
 for i in range(4):
  var travel:=fposmod(phase*0.6+i*0.25,1.0)
  var point:=at+Vector2(-direction*(12+travel*21),12+travel*23)
  draw_rect(Rect2(point.round(),Vector2(2,2)),Color(0.42,0.86,0.83,(1-travel)*0.65))
 draw_set_transform(at,0,Vector2(direction,1))
 for y in range(GHOST.size()):
  var sway: float=roundf(sin(phase*3-y*0.25)*maxf(0,y-12)*0.2)
  for x in range(GHOST[y].length()):
   var ink: String=GHOST[y][x]
   if PALETTE.has(ink):
    var color: Color=PALETTE[ink];color.a=0.90 if y<15 else 0.76
    draw_rect(Rect2(Vector2(x*2-17+sway,y*2-29),Vector2(2,2)),color)
 # Alternate beckoning and pointing; the free hand and halo answer the motion.
 var beckon:=sin(phase*3.4)
 var elbow:=Vector2(18,-10-beckon*4)
 var hand:=Vector2(28,-12-maxf(0,beckon)*13)
 draw_line(Vector2(9,-5),elbow,Color("5ab5b3"),5)
 draw_line(elbow,hand,Color("9cdfca"),4)
 draw_rect(Rect2(hand.round()-Vector2(2,2),Vector2(7,4)),Color("d9fff0"))
 draw_line(Vector2(-10,-5),Vector2(-18,-2+sin(phase*3.4+1)*6),Color("9cdfca"),4)
 draw_arc(Vector2(0,-35),19+sin(phase*2)*2,0.2,PI-0.2,12,Color(0.8,0.91,0.74,0.55),2)
 if not spirit_pose.near:
  for i in range(2):
   var x:=39+i*9
   var color:=Color(0.68,0.94,0.85,0.4+0.4*sin(phase*4-i))
   draw_line(Vector2(x,-12),Vector2(x+4,-8),color,2)
   draw_line(Vector2(x+4,-8),Vector2(x,-4),color,2)
 draw_set_transform(Vector2.ZERO)
 _icon(SYMBOLS.get(hint.kind,"map"),at+Vector2(0,-46),22,Color("abe6d3"))
 if can_invest:_icon("crystal",at+Vector2(25,-43),15)
 if hint.has("seal_progress"):
  draw_rect(Rect2(at+Vector2(-18,26),Vector2(36,3)),Color("294650"))
  draw_rect(Rect2(at+Vector2(-18,26),Vector2(36*clampf(hint.seal_progress,0,1),3)),Color("9cdfca"))
 if false and can_invest and touch_hint:
  draw_arc(active_button.get_center(),36,-PI/2,TAU-PI/2,32,Color(0.50,0.94,0.82,0.35+0.25*sin(pulse*PI)),2)
