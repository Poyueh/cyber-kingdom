extends "res://presentation/frontier_view.gd"
const Ambient=preload("res://presentation/ambient_motion.gd")
@export var wanderer_idle: Texture2D=preload("res://art/ambient/v001/wanderer-idle.png")
@export var chest_open: Texture2D=preload("res://art/ambient/v001/chest-open.png")
var crystal_radius: float = 9.0
const Icons=preload("res://presentation/ui_icons.gd")
const SITE_ICONS={"hall":"camp","workshop":"hammer","armory":"sword","farm_tools":"hoe","hunt_tools":"bow","forge":"gear","beacon":"shield","wall":"wall","farm":"food","drill":"sword","trade":"trade","heal":"heal","outpost":"outpost","recruit":"person","chest":"chest","mark":"hammer"}
const EXTRA_ART := {"campfire":preload("res://art/campaign/v001/campfire.png"),"stone":preload("res://art/campaign/v001/stone.png"),"herbs":preload("res://art/campaign/v001/herbs.png"),"plot":preload("res://art/campaign/v001/plot.png")}

func _prop(name: String, at: Vector2, scale: float = 1.0, tint := Color.WHITE) -> void:
	var texture: Texture2D=EXTRA_ART.get(name,art.props.get(name))
	Ambient.prop(self,texture,name,at,scale,tint,_sim.workforce.elapsed)

func _draw_atmosphere(left: float) -> void:
	if _sim.clock.is_night:
		draw_rect(Rect2(left,0,get_viewport_rect().size.x,430),Color(0.03,0.07,0.18,0.32))

func _draw_structures() -> void:
	var world = _sim.world
	var map = _sim.frontier
	var hall: float = world.sites.hall
	if map.city_level>0: _prop("hall-%d" % map.city_level,Vector2(hall,430))
	_prop("campfire",Vector2(hall+(70 if map.city_level>0 else 0),430),0.7 if map.city_level>0 else 1.0)
	_text("營火 · 王國由此開始" if map.city_level==0 else "聚落 %d/3 · 收貨點" % map.city_level,hall,282,Color("f3d299"),15)
	# Before the first investment there is only a campfire and nearby wanderers.
	if map.city_level==0: return
	for site in world.sites:
		var x: float=world.sites[site]
		if site=="hall": continue
		_icon(SITE_ICONS.get(site,"hand"),Vector2(x,276 if _sim.built.get(site,false) else 343),23)
	for site in ["workshop","armory","farm_tools","hunt_tools","forge","beacon"]:
		var at := Vector2(world.sites[site],430)
		var asset: String = {"farm_tools":"workshop","hunt_tools":"armory"}.get(site,site)
		if _sim.built.get(site,false):
			_prop(asset,at,0.7 if site in ["farm_tools","hunt_tools"] else 1.0)
		else: _prop("plot",at)
		_text(_sim.NAMES[site],at.x,286 if _sim.built.get(site,false) else 352,Color("cce0cc"),14)
		if _sim.TOOL_KINDS.has(site):
			var kind: String = _sim.TOOL_KINDS[site]
			for index in range(world.tools[kind]): _tool(at+Vector2(-20+index*20,-22),kind)
		elif site=="beacon" and world.barrier>0: _text("防護 ×%d" % world.barrier,at.x,310,Color("8ce2dc"),13)
	var wall: float = world.sites.wall
	if world.wall.level>0:
		_prop("wall",Vector2(wall,430),1.0,Color.WHITE if world.wall.hp>0 else Color(0.4,0.35,0.38))
		draw_rect(Rect2(wall-28,316,56,4),Color("263940"))
		draw_rect(Rect2(wall-28,316,56.0*world.wall.hp/(world.wall.level*40),4),Color("8fdbbe"))
	else: _prop("plot",Vector2(wall,430))
	_text("防線 %d/2" % world.wall.level,wall,300)
	if world.wall.pending: _text("工匠施工中",wall,342,Color("f4d49d"),13)
	for site in ["farm","drill","trade","heal"]:
		var at := Vector2(world.sites[site],430)
		_prop("crops" if site=="farm" and map.farm_active else ("herbs" if site=="heal" else "plot"),at)
		_text(_sim.NAMES[site],at.x,345,Color("d0d9b8"),13)
		if site=="farm" and map.farm_active:
			draw_rect(Rect2(at.x-40,355,80*map.farm_progress/map.farm_cycle,3),Color("d8dd9f"))

func _person(person: Dictionary, protected: bool) -> void:
	if not _sim.person_visible(person): return
	if person.role=="wanderer" and not person.get("moving",false):
		var time: float=_sim.workforce.elapsed+_sim.world.people.find(person)*0.31
		var frame: int=[0,1,2,3,4,5,4,3,2,1][int(time*4)%10]
		var at:=Vector2(person.x,person.get("y",430))
		draw_set_transform(at,0,Vector2(person.get("direction",1.0),1))
		draw_texture_rect_region(wanderer_idle,Rect2(-32,-61,64,64),Rect2(frame*64,0,64,64),Color(1,0.65,0.65) if person.hurt>0 else Color.WHITE)
		draw_set_transform(Vector2.ZERO)
	else: super._person(person,protected)
	var key: String={"wanderer":"person","citizen":"person","engineer":"hammer","farmer":"hoe","hunter":"bow","guard":"sword"}[person.role]
	_icon(key,Vector2(person.x,person.get("y",430)-66),17,Color("b4e7df") if person.role!="wanderer" else Color("d4c3a7"))

func _draw_activity() -> void:
	# Render rewards after actors so the collection journey stays legible.
	super._draw_activity()
	for pile in _sim.pouch.drops:
		for index in range(mini(3,pile.amount)):
			var visible: Dictionary=pile.duplicate()
			visible.x+=index*11-(mini(3,pile.amount)-1)*5.5
			visible.id+=index
			Ambient.crystal(self,visible,crystal_radius,_sim.workforce.elapsed)
		if pile.amount>1: _number(str(pile.amount),Vector2(pile.x+12,pile.y-29))
	for effect in _sim.effects:
		if effect.kind not in ["crystal_pickup","chest_burst","recruited"]: continue
		var duration: float=0.25 if effect.kind=="crystal_pickup" else 0.7
		var progress:=1.0-float(effect.life)/duration
		var at:=Vector2(effect.x,effect.y-24)
		for index in range(8):
			var angle:=index*TAU/8
			var point:=at+Vector2(cos(angle),sin(angle))*(8+progress*28)
			draw_rect(Rect2(point.round(),Vector2.ONE*2),Color(0.65,1,0.83,1-progress))

func _crystal(at: Vector2, filled: bool, radius: float = 6.0) -> void:
	var points := PackedVector2Array([at+Vector2(0,-radius),at+Vector2(radius*0.7,0),at+Vector2(0,radius),at+Vector2(-radius*0.7,0)])
	draw_colored_polygon(points,Color("9ef1dd") if filled else Color("16313b"))
	points.append(points[0])
	draw_polyline(points,Color("b6f6df") if filled else Color("76989e"),1.0)

func _draw_interaction() -> void:
	if _context.id.is_empty(): return
	var requirements: Dictionary=_context.get("requirements",{})
	var width:=maxf(96,_context.cost*18+48)
	width=maxf(width,requirements.size()*52+28)
	var inverse:=get_viewport().get_canvas_transform().affine_inverse()
	var left: float=(inverse*Vector2.ZERO).x
	var right: float=(inverse*get_viewport_rect().size).x
	var x:=clampf(_context.x,left+width*0.5+8,right-width*0.5-8)
	var ground:=430.0
	if _context.has("node_index"): ground=_sim.frontier.nodes[_context.node_index].y
	var y:=ground-141
	var height:=82.0 if not requirements.is_empty() else 62.0
	draw_style_box(_bubble_style(),Rect2(x-width*0.5,y-20,width,height))
	var key: String=SITE_ICONS.get(_context.id,"hand")
	if _context.id=="mark":
		key={"tree":"tree","crystal":"pickaxe","berries":"food","stone":"stone","herbs":"herbs"}.get(_sim.frontier.nodes[_context.node_index].kind,"hammer")
	_icon(key,Vector2(x,y),28)
	if not _context.enabled: _icon("lock",Vector2(x+width*0.5-15,y-3),17,Color("d4a994"))
	for index in range(_context.cost):
		_crystal(Vector2(x+(index-(_context.cost-1)*0.5)*18,y+27),index<_context.paid)
	if _context.cost==0: _icon("hand" if _context.enabled else "check",Vector2(x,y+27),18)
	var index:=0
	for resource in requirements:
		var at:=Vector2(x+(index-(requirements.size()-1)*0.5)*52,y+48)
		_icon(resource,at-Vector2(10,0),17)
		_number(str(requirements[resource]),at+Vector2(3,5))
		index+=1

func _bubble_style() -> StyleBoxFlat:
	var style:=StyleBoxFlat.new()
	style.bg_color=Color(0.035,0.09,0.13,0.88)
	style.border_color=Color("668f88")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	return style

func _icon(key: String, at: Vector2, size: float=24, tint:=Color.WHITE) -> void:
	draw_texture_rect(Icons.get_icon(key),Rect2(at-Vector2.ONE*size*0.5,Vector2.ONE*size),false,tint)

func _number(value: String, at: Vector2) -> void:
	draw_string(_font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("e1e4d0"))

func _text(value: String, x: float, y: float, _color:=Color.WHITE, _size: int=15) -> void:
	# The campaign's world language is symbols; legacy scenes retain their labels.
	if value=="!": _icon("sword",Vector2(x,y-8),18,Color("ffbd7f"))

func _resource(resource) -> void:
	if resource.kind=="cache" and resource.delivered:
		var index: int=_sim.frontier.nodes.find(resource)
		var elapsed: float=_sim.workforce.elapsed-_sim.opened_chests.get(index,0.0)
		var size:=chest_open.get_size()
		size.y*=lerpf(0.72,1.0,clampf(elapsed/0.18,0,1))
		draw_texture_rect(chest_open,Rect2(Vector2(resource.x-size.x*0.5,resource.y-size.y),size),false,Color(0.8,0.9,0.9))
		return
	super._resource(resource)
