extends Node2D
const Icons=preload("res://presentation/ui_icons.gd")
var values: Dictionary={}
var health_ratio:=1.0
var phase_ratio:=1.0
var is_night:=false
var is_paused:=false
var dead:=false
var victory:=false
var _font:=ThemeDB.fallback_font
var _panel_cache: StyleBoxFlat
func icon(key: String, at: Vector2, size: float=24, color:=Color.WHITE) -> void:
	draw_texture_rect(Icons.get_icon(key),Rect2(at-Vector2.ONE*size*0.5,Vector2.ONE*size),false,color)
func number(value: String, at: Vector2, color:=Color("e6e7d2"), size: int=15) -> void:
	draw_string(_font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
func _draw() -> void:
	var width:=get_viewport_rect().size.x
	draw_style_box(_panel(),Rect2(16,14,212,38))
	icon("heart",Vector2(36,33),24)
	draw_rect(Rect2(55,23,80,6),Color("303f48"))
	draw_rect(Rect2(55,23,80*health_ratio,6),Color("dd8899"))
	number(str(values.get("hp",0)),Vector2(56,46),Color("e9cdcf"),13)
	icon("shield",Vector2(153,33),20)
	number("%d/%d" % [values.get("shield",0),values.get("shield_capacity",0)],Vector2(167,39),Color("a7e6dc"),13)
	var index:=0
	for key in ["crystal","wood","food","stone","herbs","scrap"]:
		if not values.has(key): continue
		var x:=243.0+index*65+(16 if index>0 else 0)
		draw_style_box(_panel(),Rect2(x-3,14,78 if key=="crystal" else 62,38))
		icon(key,Vector2(x+12,32),23)
		number(str(values[key]),Vector2(x+28,38),Color("a8eddc") if key=="crystal" else Color("e3dfcc"),13)
		index+=1
	draw_style_box(_panel(),Rect2(659,14,72,38))
	icon("sword",Vector2(677,33),23)
	number(str(values.get("damage",0)),Vector2(695,39),Color("e9d5a7"),13)
	var center:=width*0.5
	draw_style_box(_panel(),Rect2(center-88,62,176,34))
	icon("moon" if is_night else "sun",Vector2(center-64,79),22)
	draw_arc(Vector2(center-64,79),14,-PI/2,-PI/2+TAU*phase_ratio,40,Color("c5daab"),1.5)
	number(str(values.get("day",1)),Vector2(center-44,85))
	icon("survived",Vector2(center+13,79),21)
	number(str(values.get("survived",0)),Vector2(center+32,85))
	for side in ["left","right"]:
		var count: int=values.get("raid_"+side,0)
		if count<=0: continue
		var x: float=center-172 if side=="left" else center+104
		draw_style_box(_panel(),Rect2(x,62,68,34))
		icon(side,Vector2(x+14,79),18,Color("ffbe89"))
		icon("sword",Vector2(x+33,79),18,Color("ffbe89"))
		number(str(count),Vector2(x+47,85),Color("ffd5a0"))
	_draw_mission(center)
	if values.get("full",false):
		icon("bag",Vector2(252,68),22,Color("f5b87c"))
	if is_paused or dead or victory:
		var at:=Vector2(center,get_viewport_rect().size.y*0.45)
		draw_style_box(_panel(),Rect2(at-Vector2(52,48),Vector2(104,96)))
		icon("skull" if dead else ("crown" if victory else "pause"),at-Vector2(0,9) if dead or victory else at,44)
		if dead: icon("camp" if values.get("defeat_reason","")=="core" else "heart",at+Vector2(0,27),22,Color("efb1a0"))
		elif victory:
			icon("rift",at+Vector2(-13,27),20,Color("a4e5be"))
			number("2/2",at+Vector2(2,32),Color("a4e5be"),13)
func _draw_mission(center: float) -> void:
	if not values.has("core_hp"):return
	draw_style_box(_panel(),Rect2(center-88,102,176,34))
	icon("camp",Vector2(center-64,119),22)
	var ratio:=clampf(float(values.core_hp)/values.core_max_hp,0,1)
	var tint:=Color("f29594") if ratio<0.35 else Color("9fe1d7")
	draw_rect(Rect2(center-45,111,64,5),Color("303f48"))
	draw_rect(Rect2(center-45,111,64*ratio,5),tint)
	number(str(values.core_hp),Vector2(center-44,131),tint,12)
	var index:=0
	for rift in values.get("rifts",[]):
		var color:=Color("52626b")
		if rift.discovered:color=Color("bc98d4")
		if rift.ordered:color=Color("efc98b")
		if rift.sealed:color=Color("8ee2bb")
		var at:=Vector2(center+35+index*30,119)
		icon("check" if rift.sealed else "rift",at,20,color)
		index+=1

func _panel() -> StyleBoxFlat:
	if _panel_cache==null:
		_panel_cache=StyleBoxFlat.new()
		_panel_cache.bg_color=Color(0.035,0.075,0.10,0.78)
		_panel_cache.set_corner_radius_all(8)
	return _panel_cache
