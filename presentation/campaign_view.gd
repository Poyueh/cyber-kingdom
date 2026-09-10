extends "res://presentation/frontier_view.gd"
const EXTRA_ART := {"campfire":preload("res://art/campaign/v001/campfire.png"),"stone":preload("res://art/campaign/v001/stone.png"),"herbs":preload("res://art/campaign/v001/herbs.png"),"plot":preload("res://art/campaign/v001/plot.png")}

func _prop(name: String, at: Vector2, scale: float = 1.0, tint := Color.WHITE) -> void:
	if not EXTRA_ART.has(name):
		super._prop(name,at,scale,tint)
		return
	var texture: Texture2D = EXTRA_ART[name]
	var size := texture.get_size()*scale
	draw_texture_rect(texture,Rect2(at-Vector2(size.x*0.5,size.y),size),false,tint)

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
	if _sim.person_visible(person): super._person(person,protected)

func _draw_activity() -> void:
	for pile in _sim.pouch.drops:
		for index in range(mini(5,pile.amount)):
			_crystal(Vector2(pile.x+(index-2)*8,pile.y-8-(index%2)*4),true,4)
		_text("龍晶 ×%d" % pile.amount,pile.x,pile.y-70,Color("a6f2e0"),12)
	super._draw_activity()

func _crystal(at: Vector2, filled: bool, radius: float = 6.0) -> void:
	var points := PackedVector2Array([at+Vector2(0,-radius),at+Vector2(radius*0.7,0),at+Vector2(0,radius),at+Vector2(-radius*0.7,0)])
	draw_colored_polygon(points,Color("9ef1dd") if filled else Color("16313b"))
	points.append(points[0])
	draw_polyline(points,Color("b6f6df") if filled else Color("76989e"),1.0)

func _draw_interaction() -> void:
	if _context.id.is_empty(): return
	var left: float = (get_viewport().get_canvas_transform().affine_inverse()*Vector2.ZERO).x
	var x := clampf(_context.x,left+199,left+get_viewport_rect().size.x-199)
	draw_rect(Rect2(x-192,184,384,82),Color(0.035,0.09,0.13,0.94))
	draw_rect(Rect2(x-192,184,384,82),Color("527574"),false,1)
	_text(_context.text,x,207,Color("f0e6c8"),14)
	var hint := "E / 互動"
	if _context.cost>0: hint="E / 每次投入 1 龍晶 · %d/%d" % [_context.paid,_context.cost]
	if not _context.enabled: hint=_context.reason
	_text(hint,x,230,Color("98e4d4") if _context.enabled else Color("d1af93"),12)
	for index in range(_context.cost):
		_crystal(Vector2(x+(index-(_context.cost-1)*0.5)*19,250),index<_context.paid)
	if _context.cost==0: _text("直接開啟" if _context.id=="chest" else "不需龍晶",x,254,Color("a5bdba"),12)

func _resource(resource) -> void:
	if resource.kind=="cache" and resource.delivered:
		_prop("cache",Vector2(resource.x,resource.y),1.0,Color(0.5,0.6,0.6,0.55))
		_text("已開啟",resource.x,resource.y-42,Color("9bbdb8"),12)
		return
	super._resource(resource)
