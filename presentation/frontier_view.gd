extends "res://presentation/settlement_view.gd"
## Prototype biome silhouettes and resource feedback; all amounts come from the simulation.
func _draw() -> void:
	if _sim == null or _font == null: return
	var map = _sim.frontier
	_land(-700,700,"refuge",true)
	for region in map.regions:
		_land(region.x,region.width,region.kind,region.discovered)
	for resource in map.nodes:
		if not map.regions[resource.region].discovered: continue
		_resource(resource)
	for animal in map.animals:
		if not animal.alive or not map.regions[animal.region].discovered: continue
		var x: float = animal.x
		draw_rect(Rect2(x-13,409,27,12),Color("b6a68c"))
		draw_rect(Rect2(x+10,403,10,12),Color("c9b995"))
		for offset in [-9,8]: draw_rect(Rect2(x+offset,421,3,9),Color("796e6e"))
		draw_line(Vector2(x+13,406),Vector2(x+8,394),Color("c4b78b"),2)
		draw_line(Vector2(x+12,400),Vector2(x+20,394),Color("c4b78b"),2)
		_text("晶角鹿 · 食物",x,388,Color("c9be9d"),12)
	for kind in ["hoe","bow"]:
		var x: float = _sim.world.tool_location(kind)
		draw_rect(Rect2(x-48,378,96,52),Color("3b4548"))
		draw_rect(Rect2(x-56,364,112,12),Color("788371"))
		draw_rect(Rect2(x-40,383,80,35),Color("182d32"))
		for index in range(_sim.world.tools[kind]): _tool(Vector2(x-26+index*26,403),kind)
		_text("農具架" if kind=="hoe" else "獵具架",x,346)
	var farm: float = _sim.world.sites.farm
	draw_rect(Rect2(farm-68,422,136,8),Color("725848"))
	for i in range(8):
		var x := farm-56+i*16
		draw_line(Vector2(x,425),Vector2(x+10,425),Color("ad8e60"),2)
		if map.farm_active:
			var height: float = 7+map.farm_progress/map.farm_cycle*10
			draw_line(Vector2(x,422),Vector2(x,422-height),Color("9bae6e"),3)
			draw_rect(Rect2(x-4,420-height,8,4),Color("d9c883"))
	_text("農田 / 留種再收成" if map.farm_active else "可開墾農地",farm,358)
	if map.farm_active:
		draw_rect(Rect2(farm-44,370,88,4),Color("263b3f"))
		draw_rect(Rect2(farm-44,370,88*map.farm_progress/map.farm_cycle,4),Color("b7d68c"))
	var hall: float = _sim.world.sites.hall
	var height: float = 55+map.city_level*20
	draw_rect(Rect2(hall-65,430-height,130,height),Color("384955"))
	draw_rect(Rect2(hall-73,424-height,146,9),Color("92a6a2"))
	for i in [-1,1]:
		draw_rect(Rect2(hall+i*52-12,411-height,24,height+19),Color("536575"))
		draw_rect(Rect2(hall+i*52-16,405-height,32,8),Color("9ba992"))
		draw_rect(Rect2(hall+i*28-5,438-height,10,21),Color("80d9ce"))
	draw_rect(Rect2(hall-16,394,32,36),Color("132a33"))
	_text("王城" if map.city_level==3 else "聚落 / Lv.%d" % map.city_level,hall,350-height)
	if map.city_level>=2:
		draw_line(Vector2(hall,414-height),Vector2(hall,372-height),Color("c5ba94"),3)
		draw_rect(Rect2(hall,374-height,28,19),Color("5dacab"))
	var drill: float = _sim.world.sites.drill
	draw_line(Vector2(drill,430),Vector2(drill,368),Color("a88c6b"),6)
	draw_line(Vector2(drill-20,390),Vector2(drill+20,390),Color("9d886f"),6)
	draw_circle(Vector2(drill,372),9,Color("baac8b"))
	_text("騎士訓練 %d/%d" % [map.drill_level,map.training_limit],drill,343,Color("cebda0"),13)
	super._draw()

func _land(x: float, width: float, kind: String, discovered: bool) -> void:
	draw_rect(Rect2(x,0,width,430),Color("11232c"))
	draw_rect(Rect2(x,430,width,110),Color("18252e"))
	draw_rect(Rect2(x,430,width,4),Color("718980"))
	for i in range(int(width/36)):
		draw_rect(Rect2(x+i*36+4,448+(i%3)*18,16,3),Color("293a40"))
	if not discovered:
		draw_rect(Rect2(x,90,width,340),Color("12202b"))
		_text("未探索的邊境",x+width*0.5,170,Color("718a94"),17)
		return
	if kind == "forest":
		for i in range(int(width/65)):
			var at := x+25+i*65
			draw_rect(Rect2(at-5,244,10,186),Color("273b40"))
			draw_colored_polygon(PackedVector2Array([Vector2(at,147+(i%3)*22),Vector2(at+58,322),Vector2(at-58,322)]),Color("28484b"))
	elif kind == "ruins":
		for i in range(int(width/110)):
			var at := x+30+i*110
			draw_rect(Rect2(at-15,220+(i%2)*35,30,210),Color("2f414e"))
			draw_rect(Rect2(at-23,210+(i%2)*35,46,14),Color("52616a"))
			draw_rect(Rect2(at-2,247+(i%2)*35,4,32),Color("467c85"))
	elif kind == "quarry":
		for i in range(int(width/95)):
			var at := x+30+i*95
			draw_colored_polygon(PackedVector2Array([Vector2(at-70,430),Vector2(at-25,245+(i%2)*55),Vector2(at+12,220+(i%2)*55),Vector2(at+78,430)]),Color("30404e"))
	var title: String = {"forest":"龍晶林 / 木材・野果・獵物","quarry":"晶脈 / 有限龍晶","ruins":"舊王朝遺跡 / 廢料","refuge":"避難所西境 / 生產區"}[kind]
	_text(title,x+width*0.5,143,Color("a7c0b9"),17)

func _resource(resource) -> void:
	var at := Vector2(resource.x,resource.y)
	if resource.collected:
		draw_rect(Rect2(at+Vector2(-12,-6),Vector2(24,6)),Color("5c665b"))
		return
	match resource.kind:
		"tree":
			draw_rect(Rect2(at+Vector2(-8,-90),Vector2(16,90)),Color("72634e"))
			for crown in range(3):
				var h := -112+crown*26
				var w := 25+crown*9
				draw_colored_polygon(PackedVector2Array([at+Vector2(0,h-25),at+Vector2(w,h+24),at+Vector2(-w,h+24)]),Color("4a7261") if crown%2==0 else Color("547b68"))
			if resource.crystals>0:
				draw_colored_polygon(PackedVector2Array([at+Vector2(-7,-37),at+Vector2(0,-51),at+Vector2(7,-37),at+Vector2(0,-20)]),Color("8de9d7"))
		"crystal":
			for offset in [-15,0,15]:
				var point := at+Vector2(offset,0)
				draw_colored_polygon(PackedVector2Array([point+Vector2(-10,0),point+Vector2(-8,-30),point+Vector2(2,-48+abs(offset)),point+Vector2(11,-9)]),Color("85cfc8") if offset==0 else Color("508f9b"))
		"berries":
			draw_rect(Rect2(at+Vector2(-21,-22),Vector2(42,22)),Color("51705b"))
			for i in range(4): draw_rect(Rect2(at+Vector2(-15+i*9,-17+(i%2)*7),Vector2(5,5)),Color("d39490"))
		"cache":
			draw_rect(Rect2(at+Vector2(-19,-27),Vector2(38,27)),Color("8a7359"))
			draw_rect(Rect2(at+Vector2(-21,-29),Vector2(42,6)),Color("b2a481"))
			draw_rect(Rect2(at+Vector2(-3,-24),Vector2(6,17)),Color("8ccbc3"))
	if resource.hp<75 and resource.kind!="berries":
		draw_rect(Rect2(at+Vector2(-18,5),Vector2(36,3)),Color("364e54"))
		draw_rect(Rect2(at+Vector2(-18,5),Vector2(36*resource.hp/75.0,3)),Color("c7d59f"))
