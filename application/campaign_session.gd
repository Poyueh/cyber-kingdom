extends "res://application/frontier_session.gd"
## Playable campaign orchestration. Wallet and calendar rules remain in domain.
const Mission=preload("res://domain/campaign_mission.gd")
var mission: Mission
const RiftWorkforce=preload("res://application/rift_workforce.gd")
var expedition: RiftWorkforce
const Schedule = preload("res://domain/resident_schedule.gd")
const Roaming = preload("res://domain/resident_roaming.gd")
var stroll_speed: float = 24.0
var return_margin: float = 15.0
var hunter_damage: int = 12
var hunter_range: float = 170.0
var hunter_interval: float = 1.2
var _hero_x: float = 0.0
var _night_spawn_index := 0
const Pouch = preload("res://domain/crystal_pouch.gd")
const Calendar = preload("res://domain/campaign_clock.gd")
const Harvest = preload("res://domain/harvest_node.gd")
var pouch: Pouch
var clock: Calendar
var opened_chests: Dictionary = {}
var investments: Dictionary = {}
var built: Dictionary = {}
var prices: Dictionary
var warden_health: int
var warden_damage: int
var enemy_health_growth: int
var enemy_damage_growth: int
const TOOL_KINDS := {"workshop":"hammer","armory":"blade","farm_tools":"hoe","hunt_tools":"bow"}
const NAMES := {"hall":"營火","workshop":"工匠器具","armory":"守備器具","farm_tools":"農具","hunt_tools":"獵弓","forge":"義肢爐","beacon":"護民塔","wall":"右防線","wall_left":"左防線","farm":"農田","drill":"劍術訓練","trade":"食物交易","heal":"藥草治療"}

func _init(config: Dictionary = {}, hero_stats: Stats = null) -> void:
	var resolved:=config.duplicate(true)
	var economy: Dictionary=config.get("economy",{}).duplicate(true)
	var left_post:=minf(-950.0,float(config.get("left_defense_x",-1100.0)))
	economy["settlement_left"]=left_post-200.0
	resolved["economy"]=economy
	super(resolved,hero_stats)
	world.add_wall("wall_left",left_post)
	mission=Mission.new(config)
	mission.add_rift(-1,frontier.left_boundary-180.0)
	mission.add_rift(1,frontier.right_boundary+180.0)
	frontier.left_boundary-=400.0
	frontier.right_boundary+=400.0
	expedition=RiftWorkforce.new(world,frontier,mission)
	return_margin = maxf(0.0,float(config.get("return_margin",15.0)))
	hunter_damage = maxi(1,int(config.get("hunter_damage",12)))
	hunter_range = maxf(30.0,float(config.get("hunter_range",170.0)))
	hunter_interval = maxf(0.2,float(config.get("hunter_interval",1.2)))
	stroll_speed=maxf(1.0,float(config.get("stroll_speed",24.0)))
	pouch = Pouch.new(config.get("capacity",12),config.get("starting_crystals",12))
	pouch.magnet_radius = maxf(32,config.get("magnet_radius",112.0))
	pouch.magnet_speed = maxf(32,config.get("magnet_speed",300.0))
	pouch.throw_grace = maxf(0.5,config.get("throw_grace",2.0))
	pouch.left_boundary=frontier.left_boundary
	pouch.right_boundary=frontier.right_boundary
	for node in frontier.nodes:
		if node.y<430: pouch.platforms.append({"left":node.x-70,"right":node.x+70,"y":node.y})
	clock = Calendar.new(config.get("day_seconds",180.0),config.get("night_seconds",60.0))
	prices = {"camp":2,"hall":5,"workshop":2,"armory":3,"farm_tools":2,"hunt_tools":3,"forge":2,"beacon":1,"wall":3,"wall_upgrade":4,"repair":2,"farm":3,"drill":2,"outpost":3,"mark":1,"recruit":1,"core_charge":2,"rift":4}
	prices.merge(config.get("prices",{}),true)
	for key in prices: prices[key]=clampi(int(prices[key]),1,12)
	warden_health=maxi(1,int(config.get("warden_health",90)))
	warden_damage=maxi(1,int(config.get("warden_damage",18)))
	enemy_health_growth = maxi(1,int(config.get("enemy_health_growth",12)))
	enemy_damage_growth = maxi(1,int(config.get("enemy_damage_growth",3)))
	world.crystals = 0
	world.scrap = 0
	world.sites.erase("horn")
	world.sites.merge({"trade":-700.0,"heal":-850.0})
	frontier.city_level = 0
	world.people.clear()
	for x in [180.0,245.0]: _add_person(x,-1)
	for index in range(frontier.regions.size()):
		var region: Dictionary = frontier.regions[index]
		_add_person(region.x+region.width*0.12,index)
		var node := Harvest.new()
		node.kind = "stone" if region.kind=="quarry" else "herbs"
		node.x = region.x+region.width*0.88
		node.pickup_x = node.x
		node.region = index
		if node.kind=="stone": node.stone=6
		else: node.herbs=3
		frontier.nodes.append(node)
	for node in frontier.nodes:
		if node.kind=="cache": node.crystals=6
		elif node.kind=="crystal": node.crystals=6
		elif node.kind=="tree": node.crystals=2
	time_to_raid = clock.remaining

func _add_person(x: float, region: int) -> void:
	world.people.append({"x":x,"role":"wanderer","hurt":0.0,"cooldown":0.0,"region":region})

func person_visible(person: Dictionary) -> bool:
	var region: int = person.get("region",-1)
	return person.role!="wanderer" or region<0 or frontier.regions[region].discovered

func _choice(id: String, x: float, title: String, cost: int = 0, allowed: bool = true, reason: String = "") -> Dictionary:
	return {"id":id,"x":x,"text":title,"cost":cost,"currency":"龍晶" if cost>0 else "","enabled":allowed,"reason":reason,"key":id,"paid":0}

func context(x: float) -> Dictionary:
	var selected := _no_interaction(x)
	for candidate in _interaction_candidates(x):
		if selected.id.is_empty() or (candidate.enabled and not selected.enabled) or (candidate.enabled==selected.enabled and absf(candidate.x-x)<absf(selected.x-x)):
			selected=candidate
	return selected

func context_for_key(x: float, key: String) -> Dictionary:
	for candidate in _interaction_candidates(x):
		if candidate.key==key: return candidate
	return _no_interaction(x)

func _no_interaction(x: float) -> Dictionary:
	return _choice("",x,"探索邊境，尋找流浪者與寶箱",0,false,"靠近目標互動")

func _interaction_candidates(x: float) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	if not is_running():return candidates
	var choice: Dictionary
	for index in range(world.people.size()):
		var person: Dictionary = world.people[index]
		if person.role!="wanderer" or not person_visible(person) or absf(person.x-x)>=73.0 or absf(person.get("y",430)-_player_y)>42: continue
		choice = _choice("recruit",person.x,"招攬流浪者",prices.recruit,person.hurt<=0,"等待流浪者恢復")
		choice["person_index"] = index
		choice.key = "recruit:%d" % index
		candidates.append(choice)
	if absf(_player_y-430)<=42:
		for site in world.sites:
			if frontier.city_level==0 and site!="hall": continue
			if absf(world.sites[site]-x)>=73.0: continue
			choice = _campaign_site(site)
			candidates.append(choice)
	for index in range(frontier.nodes.size()):
		var node = frontier.nodes[index]
		if node.collected or not frontier.regions[node.region].discovered or absf(node.x-x)>=73.0 or absf(node.y-_player_y)>42: continue
		if node.kind=="cache":
			choice = _choice("chest",node.x,"開啟寶箱 · %d 龍晶 / %d 廢料" % [node.crystals,node.scrap])
		else:
			var label: String = {"tree":"伐木","crystal":"採晶","berries":"採果","stone":"採石","herbs":"採藥"}[node.kind]
			choice = _choice("mark",node.x,"委託工匠"+label,prices.mark,not node.marked,"已下令 · 等待工匠採集搬運")
		choice["node_index"] = index
		choice.key = "node:%d" % index
		candidates.append(choice)
	for index in range(frontier.regions.size()):
		var region: Dictionary = frontier.regions[index]
		if not region.outpost_ready or absf(region.outpost_x-x)>=73.0 or absf(_player_y-430)>42: continue
		choice = _choice("outpost",region.outpost_x,"建立拓荒站",prices.outpost,not region.outpost_pending and not region.outpost_built,"工匠施工中" if region.outpost_pending else "拓荒站已建成")
		choice["region_index"] = index
		choice.key = "outpost:%d" % index
		candidates.append(choice)
	for index in range(mission.rifts.size()):
		var rift: Dictionary=mission.rifts[index]
		if not rift.discovered or absf(rift.x-x)>=73 or absf(_player_y-430)>42:continue
		var prerequisites: Array=[]
		if frontier.city_level<2:prerequisites.append({"icon":"camp","value":2})
		if clock.survived<1:prerequisites.append({"icon":"survived","value":1})
		if not world.people.any(func(p):return p.role=="engineer"):prerequisites.append({"icon":"hammer","value":1})
		choice=_choice("rift",rift.x,"封印龍裂隙",prices.rift,prerequisites.is_empty() and not rift.ordered and not rift.sealed,"升級聚落、熬過一晚並招募工匠")
		choice.key="rift:%d" % index
		choice["rift_index"]=index
		choice["prerequisites"]=prerequisites
		if rift.ordered:
			choice.cost=0
			choice.reason="封印完成" if rift.sealed else "護送工匠、擊退守門者並留在裂隙附近"
		candidates.append(choice)
	for candidate in candidates:
		candidate.paid = int(investments.get(candidate.key,0))
		if candidate.enabled and candidate.cost>0 and pouch.amount<=0:
			candidate.enabled = false
			candidate.reason = "背包沒有龍晶 · 尋找寶箱、收貨點或交易食物"
	return candidates

func _campaign_site(site: String) -> Dictionary:
	var at: float = world.sites[site]
	var choice := _choice(site,at,NAMES[site],int(prices.get(site,0)))
	if site=="hall":
		if frontier.city_level>0 and mission.core_hp<mission.core_max_hp:
			return _choice("core_charge",at,"核心充能",prices.core_charge)
		if frontier.city_level==0: return _choice("hall",at,"營火 · 建立第一座營地",prices.camp)
		var materials := frontier.city_cost()
		choice.text = "升級聚落 · %d 木 / %d 糧 / %d 石" % [materials.wood,materials.food,frontier.city_level*3]
		choice.key = "hall:%d" % frontier.city_level
		choice["requirements"]={"wood":materials.wood,"food":materials.food,"stone":frontier.city_level*3}
		choice.enabled = frontier.city_level<3 and frontier.wood>=materials.wood and frontier.food>=materials.food and frontier.stone>=frontier.city_level*3
		choice.reason = "先讓居民採木、採石與生產食物" if frontier.city_level<3 else "王城已完成 · 繼續守住居民"
		return choice
	if frontier.city_level==0:
		choice.enabled=false
		choice.reason="先回營火投入 2 顆龍晶建立營地"
		return choice
	if TOOL_KINDS.has(site):
		var kind: String = TOOL_KINDS[site]
		choice.text += " · 庫存 %d/3" % world.tools[kind]
		choice.enabled = world.tools[kind]<3
		choice.reason = "器具架已滿，等待居民領取"
	elif world.walls.has(site):
		var defense: Dictionary=world.walls[site]
		var repair: bool = defense.level>0 and defense.hp<defense.level*40
		choice.cost = prices.repair if repair else (prices.wall if defense.level==0 else prices.wall_upgrade)
		if not repair and defense.level>0: choice["requirements"]={"stone":3}
		choice.text = "修復防線" if repair else ("建立木防線" if defense.level==0 else "升級石防線 · 3 石材")
		choice.key = "%s:%d:%s" % [site,defense.level,repair]
		choice.enabled = not defense.pending and (repair or defense.level<2) and (repair or defense.level==0 or frontier.stone>=3)
		choice.reason = "施工中／防線已滿，升級需要 3 石材"
	elif site=="forge":
		choice["requirements"]={"scrap":2}
		choice.text="義肢爐 · 2 廢料 / 護盾 +%d" % world.shield_value
		choice.enabled=world.scrap>=2
		choice.reason="需要從寶箱或敵人回收 2 廢料"
	elif site=="farm":
		choice["requirements"]={"wood":2,"food":1}
		choice.text = "開墾農田 · 2 木材 / 1 食物"
		choice.enabled = not frontier.farm_active and frontier.wood>=2 and frontier.food>=1
		choice.reason = "已播種，或缺少木材與種子食物"
	elif site=="drill":
		choice["requirements"]={"food":frontier.training_food}
		choice.text = "劍術訓練 · %d 食物 / 劍傷 +%d" % [frontier.training_food,frontier.training_damage]
		choice.enabled = frontier.food>=frontier.training_food and frontier.drill_level<frontier.training_limit
		choice.reason = "食物不足或訓練已滿"
	elif site=="trade":
		choice["requirements"]={"food":4}
		choice.text = "交易 · 4 食物換 2 龍晶"
		choice.enabled = frontier.food>=4
		choice.reason = "需要 4 食物 · 農夫可持續留種生產"
	elif site=="heal":
		choice["requirements"]={"herbs":2}
		choice.text = "治療 · 2 藥草回復 30 生命"
		choice.enabled = frontier.herbs>=2 and hero.hp<hero.stats.max_hp
		choice.reason = "需要 2 藥草，或目前生命已滿"
	return choice

func interact(x: float, target_key: String = "") -> bool:
	if not is_running(): return false
	var choice := context(x) if target_key.is_empty() else context_for_key(x,target_key)
	if not choice.enabled: return false
	if choice.cost>0:
		if not pouch.spend(): return false
		investments[choice.key] = choice.paid+1
		effects.append({"kind":"pay","x":x,"to":choice.x,"life":0.45})
		if investments[choice.key]<choice.cost: return true
		investments.erase(choice.key)
	_execute(choice)
	return true

func _execute(choice: Dictionary) -> void:
	match choice.id:
		"rift": mission.order(choice.rift_index)
		"core_charge": mission.recharge_core()
		"recruit": world.people[choice.person_index].role="citizen"
		"chest":
			var node = frontier.nodes[choice.node_index]
			node.collected=true
			node.delivered=true
			world.scrap+=node.scrap
			pouch.burst(node.crystals,node.x,node.y)
			opened_chests[choice.node_index]=workforce.elapsed
			effects.append({"kind":"chest_burst","x":node.x,"y":node.y,"life":0.7})
		"mark": frontier.mark(frontier.nodes[choice.node_index])
		"hall":
			if frontier.city_level>0:
				var materials := frontier.city_cost()
				frontier.wood-=materials.wood
				frontier.food-=materials.food
				frontier.stone-=frontier.city_level*3
			frontier.city_level+=1
		"workshop","armory","farm_tools","hunt_tools":
			world.tools[TOOL_KINDS[choice.id]]+=1
			built[choice.id]=true
		"wall","wall_left":
			var defense: Dictionary=world.walls[choice.id]
			var repair: bool=defense.level>0 and defense.hp<defense.level*40
			if not repair and defense.level>0: frontier.stone-=3
			defense.merge({"pending":true,"repair":repair,"progress":0.0},true)
		"outpost": frontier.regions[choice.region_index].outpost_pending=true
		"farm": frontier.plant()
		"forge": world.scrap-=2; hero.shield+=world.shield_value; built.forge=true
		"beacon": world.barrier+=1; built.beacon=true
		"drill":
			frontier.food-=frontier.training_food
			frontier.drill_level+=1
			hero.stats.damage+=frontier.training_damage
		"trade": frontier.food-=4; pouch.receive(2,choice.x)
		"heal": frontier.herbs-=2; hero.hp=mini(hero.stats.max_hp,hero.hp+30)

func advance(seconds: float, hero_x: float, hero_y: float = 430.0) -> void:
	if seconds<=0 or not is_finite(seconds):return
	mission.resolve(hero.is_alive(),raiders.is_empty())
	if not is_running():return
	_hero_x=hero_x
	mission.reveal(hero_x)
	super.advance(seconds,hero_x,hero_y)
	mission.resolve(hero.is_alive(),raiders.is_empty())
	if not is_running(): return
	_advance_expeditions(seconds,hero_x,hero_y)
	mission.resolve(hero.is_alive(),raiders.is_empty())
	if not is_running():return
	# Offered currency can recruit; ordinary treasure and delivered pay cannot.
	for person in world.people:
		if person.role=="wanderer" and person.hurt<=0 and person_visible(person) and pouch.consume_offering(person.x,person.get("y",430)):
			var key := "recruit:%d" % world.people.find(person)
			investments[key]=int(investments.get(key,0))+1
			if investments[key]<prices.recruit: continue
			investments.erase(key)
			person.role="citizen"
			effects.append({"kind":"recruited","x":person.x,"y":person.get("y",430),"life":0.7})
	pouch.advance(seconds,hero_x,hero_y)
	for pickup in pouch.pickups:
		effects.append({"kind":"crystal_pickup","x":pickup.x,"y":pickup.y,"life":0.25})
	pouch.pickups.clear()

func throw_crystal(x: float, y: float, facing: int) -> bool:
	return is_running() and pouch.toss(x,y,facing)

func _receive_delivery(delivery: Dictionary) -> void:
	super._receive_delivery(delivery)
	var crystals: int = delivery.get("crystals",0)
	world.crystals-=crystals
	pouch.drop(crystals,delivery.x)

func _advance_people(seconds: float) -> void:
	expedition.prepare()
	_assign_defense_posts()
	var previous: Array=[]
	for person in world.people: previous.append(float(person.x))
	super._advance_people(seconds)
	for index in range(world.people.size()):
		var person: Dictionary=world.people[index]
		# Supplies, tools and occupations have already chosen their real destinations.
		if person.role not in ["wanderer","citizen"] or person.get("moving",false) or person.get("sheltering",false): continue
		if person.role=="wanderer" and absf(person.x-_hero_x)<=72: continue
		var before: float=person.x
		var radius:=64.0 if person.role=="wanderer" else 100.0
		var target:=Roaming.destination(person,index,world.sites.hall,radius,seconds,frontier.left_boundary+16,frontier.right_boundary-16)
		person.x=move_toward(person.x,target,stroll_speed*seconds)
		person.moving=absf(person.x-before)>0.01
		if person.moving: person.direction=signf(person.x-before)

	for index in range(world.people.size()):
		var person: Dictionary=world.people[index]
		person["walk_distance"]=float(person.get("walk_distance",0.0))+absf(person.x-previous[index])

func _override_resident_target(index: int, seconds: float) -> float:
	var person: Dictionary = world.people[index]
	var expedition_target:=expedition.target(index,seconds)
	if is_finite(expedition_target):return expedition_target
	if person.role=="guard":
		_shoot_nearest_raider(person,190.0,20,0.85)
		person["direction"]=1.0 if person.defense_post=="wall" else -1.0
		return _defense_position(index,65.0)
	if person.role not in ["citizen","engineer","farmer","hunter"]: return NAN
	var home: float = world.sites.hall + (index%5-2)*22.0
	if person.role=="hunter" and world.walls[person.defense_post].hp>0:
		home = _defense_position(index,90.0)
	if not Schedule.should_return(clock.is_night,clock.remaining,person.x,home,_person_speed,return_margin):
		return NAN
	person["sheltering"] = true
	person["work_state"] = "walk"
	if person.role=="engineer":
		for job in frontier.nodes:
			if job.worker==index and job.carried:
				person.work_state = "haul"
				break
		if absf(person.get("y",430.0)-430.0)>0.1:
			person["y"] = move_toward(person.get("y",430.0),430.0,70.0*seconds)
			person.work_state = "climb"
			return person.x
	if person.role=="hunter":
		_shoot_nearest_raider(person,hunter_range,hunter_damage,hunter_interval)
	return home

func _assign_defense_posts() -> void:
	var counts: Dictionary={"wall":0,"wall_left":0}
	for person in world.people:
		if person.role not in ["guard","hunter"]:
			person.erase("defense_post")
		elif person.has("defense_post"):
			counts[person.defense_post]+=1
	for person in world.people:
		if person.role in ["guard","hunter"] and not person.has("defense_post"):
			var post: String="wall" if counts.wall<=counts.wall_left else "wall_left"
			person["defense_post"]=post
			counts[post]+=1

func _defense_position(index: int, inset: float) -> float:
	var post: String=world.people[index].defense_post
	var rank:=0
	for i in range(index):
		if world.people[i].get("defense_post","")==post: rank+=1
	var side:=1.0 if post=="wall" else -1.0
	return world.sites[post]-side*(inset+mini(rank,4)*18.0)

func raid_pressure() -> Dictionary:
	var pressure: Dictionary={"left":0,"right":0}
	if not clock.is_night and clock.remaining>30 and raiders.is_empty(): return pressure
	for enemy in raiders:
		if enemy.fighter.is_alive(): pressure["right" if enemy.get("side",1)>0 else "left"]+=1
	var start: int=_night_spawn_index if clock.is_night else 0
	var pending: int=_spawn_remaining if clock.is_night else (mini(12,2+clock.day) if clock.remaining<=30 else 0)
	for i in range(start,start+pending):
		if mission.side_open(1 if i%2==0 else -1):pressure["right" if i%2==0 else "left"]+=1
	return pressure

func is_running() -> bool:
	return hero.is_alive() and mission.outcome=="active"

func finished() -> bool:return mission.outcome!="active"

func _strategic_target(_raider: Dictionary) -> Dictionary:
	return {"kind":"core","x":world.sites.hall}

func _hit_structure(target: Dictionary, amount: int) -> void:
	if target.kind=="core":
		mission.damage_core(amount)
		mission.resolve(hero.is_alive(),false)
	else:super._hit_structure(target,amount)
func begin_raid() -> bool: return false # The calendar alone starts a night.

func _advance_invasion(seconds: float) -> void:
	var transition := clock.advance(seconds,raiders.is_empty() and _spawn_remaining==0)
	if transition=="night":
		wave=clock.day
		_spawn_remaining=mini(12,2+clock.day)
		_spawn_timer=0.0
		_night_spawn_index=0
	if _spawn_remaining>0:
		_spawn_timer-=seconds
		while _spawn_timer<=0 and _spawn_remaining>0:
			var side:=1 if _night_spawn_index%2==0 else -1
			_night_spawn_index+=1
			_spawn_remaining-=1
			if not mission.side_open(side):continue
			var enemy:=_spawn_raider()
			enemy["side"]=side
			enemy.x=world.sites.wall+480.0 if side>0 else world.sites.wall_left-480.0
			enemy["exit_x"]=enemy.x+side*70.0
			enemy["direction"]=-float(side)
			raiders.append(enemy)
			_spawn_timer=2.5
	time_to_raid=clock.remaining

func _spawn_raider() -> Dictionary:
	var raider := super._spawn_raider()
	var stats := Stats.new()
	stats.hurt_invulnerability = raider.fighter.stats.hurt_invulnerability
	stats.max_hp=60+(clock.day-1)*enemy_health_growth
	stats.damage=15+(clock.day-1)*enemy_damage_growth
	raider.fighter=Fighter.new(stats)
	raider["wall_damage"]=20+(clock.day-1)*enemy_damage_growth
	return raider

func _advance_expeditions(seconds: float, hero_x: float, hero_y: float) -> void:
	for index in range(mission.rifts.size()):
		var rift: Dictionary=mission.rifts[index]
		if not rift.ordered or rift.sealed:continue
		var ready:=expedition.worker_ready(rift)
		var knight_near:=absf(hero_x-rift.x)<160 and absf(hero_y-430)<80
		if ready and knight_near and not rift.wardens_spawned:
			rift.wardens_spawned=true
			for offset in [-120.0,120.0]:
				var enemy:=_spawn_raider()
				enemy.fighter.stats.max_hp=maxi(warden_health,enemy.fighter.stats.max_hp)
				enemy.fighter.hp=enemy.fighter.stats.max_hp
				enemy.fighter.stats.damage=maxi(warden_damage,enemy.fighter.stats.damage)
				enemy.x=rift.x+offset
				enemy["side"]=rift.side
				enemy["kind"]="warden"
				enemy["direction"]=-signf(offset)
				raiders.append(enemy)
		var contested:=raiders.any(func(r):return r.fighter.is_alive() and absf(r.x-rift.x)<180)
		mission.advance_seal(index,seconds,ready,knight_near,contested)

func _collect_loot(drop: Dictionary) -> void:
	super._collect_loot(drop)
	pouch.receive(1,drop.x)

func kingdom_established() -> bool:
	var citizens := 0
	for person in world.people:
		if person.role!="wanderer": citizens+=1
	return hero.is_alive() and clock.survived>=3 and frontier.city_level>=3 and world.walls.values().all(func(w):return w.level>=2 and w.hp>0) and citizens>=3
