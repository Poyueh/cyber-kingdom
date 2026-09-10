extends "res://application/settlement_session.gd"
const Frontier = preload("res://domain/frontier.gd")
var frontier: Frontier
var map_seed: int
var _player_y := 430.0
const EXTRA_SITES := {"farm_tools":-150.0,"hunt_tools":-550.0,"farm":-350.0,"hall":30.0,"drill":1230.0}

func _init(config: Dictionary = {}, hero_stats: Stats = null) -> void:
	super(config,hero_stats)
	map_seed = int(config.get("seed",742601))
	frontier = Frontier.new(map_seed,config.get("economy",{}))
	world.sites.merge(EXTRA_SITES)
	world.tools.merge({"hoe":0,"bow":0})
	world.tool_sites.merge({"hoe":"farm_tools","bow":"hunt_tools"})
	world.tool_roles.merge({"hoe":"farmer","bow":"hunter"})
	for x in [315.0,400.0]:
		world.people.append({"x":x,"role":"wanderer","hurt":0.0,"cooldown":0.0})

func context(x: float) -> Dictionary:
	var choice := super.context(x)
	var nearest: float = absf(choice.x-x) if not choice.id.is_empty() else 73.0
	for site in EXTRA_SITES:
		var distance := absf(x-world.sites[site])
		if distance >= nearest: continue
		nearest = distance
		choice = _site_context(site)
	for index in range(frontier.nodes.size()):
		var node = frontier.nodes[index]
		var distance := absf(node.x-x)
		if node.collected or distance>=nearest or absf(node.y-_player_y)>42: continue
		nearest = distance
		var name: String = {"tree":"砍伐龍晶樹","crystal":"開採龍晶礦","cache":"打開遺跡箱","berries":"採集野果"}[node.kind]
		choice = {"id":"harvest","x":node.x,"text":name+" / J 劈砍或 E 採集", "cost":0,"currency":"",
			"enabled":distance<=hero.stats.attack_range and hero.attack_remaining<=0 and hero.cooldown_remaining<=0,"reason":"再靠近一些" if distance>hero.stats.attack_range else "採集中，等待收招"}
	return choice

func _site_context(site: String) -> Dictionary:
	var choice := {"id":site,"x":world.sites[site],"text":"","cost":0,"currency":"","enabled":true,"reason":""}
	match site:
		"farm_tools","hunt_tools":
			var kind := "hoe" if site == "farm_tools" else "bow"
			choice.text = ("農具架：鋤頭" if kind == "hoe" else "獵具架：獵弓")+"（庫存 %d）" % world.tools[kind]
			choice.cost = 2
			choice.currency = "廢料"
			choice.enabled = world.scrap>=2 and world.tools[kind]<3
			choice.reason = "廢料不足或器具庫存已滿"
		"farm":
			choice.text = "開墾與播種：2 木材 + 1 食物"
			choice.enabled = not frontier.farm_active and frontier.wood>=2 and frontier.food>=1
			choice.reason = "需要木材與種子食物"
			if frontier.farm_active:
				choice.text = "農田：已播種 / 農夫自動耕作留種"
				choice.reason = "農夫每季淨收 %d 食物，不需重複付款" % frontier.farm_yield
		"hall":
			var cost := frontier.city_cost()
			choice.text = "城鎮升級：%d 木 / %d 糧 / %d 廢料" % [cost.wood,cost.food,cost.scrap]
			choice.enabled = frontier.city_level<3 and frontier.wood>=cost.wood and frontier.food>=cost.food and world.scrap>=cost.scrap
			choice.reason = "先探索資源，種植與狩獵累積食物"
			if frontier.city_level>=3:
				choice.text = "王城已建成"
				choice.reason = "守過三波、保住二級防線與至少三名居民"
		"drill":
			choice.text = "訓練場：%d 食物 / 劍傷 +%d" % [frontier.training_food,frontier.training_damage]
			choice.enabled = frontier.food>=frontier.training_food and frontier.drill_level<frontier.training_limit
			choice.reason = "食物不足或訓練已滿"
	return choice

func interact(x: float) -> bool:
	if not hero.is_alive(): return false
	var choice := context(x)
	if not choice.enabled: return false
	var success := false
	match choice.id:
		"harvest":
			if choice.x != x: hero.facing = int(signf(choice.x-x))
			return hero.start_attack()
		"farm_tools": success = world.buy_tool("hoe")
		"hunt_tools": success = world.buy_tool("bow")
		"farm": success = frontier.plant()
		"hall":
			var paid := frontier.upgrade_city(world.scrap)
			world.scrap -= paid
			success = paid>0
		"drill":
			frontier.food -= frontier.training_food
			frontier.drill_level += 1
			hero.stats.damage += frontier.training_damage
			success = true
		_: return super.interact(x)
	if success: effects.append({"kind":"pay","x":x,"to":choice.x,"life":0.45})
	return success

func advance(seconds: float, hero_x: float, hero_y: float = 430.0) -> void:
	_player_y = hero_y
	if seconds<=0 or not is_finite(seconds) or not hero.is_alive(): return
	frontier.reveal(hero_x)
	super.advance(seconds,hero_x,hero_y)

func _advance_people(seconds: float) -> void:
	super._advance_people(seconds)
	var farmers := 0
	for person in world.people:
		if person.role == "farmer":
			person.x = move_toward(person.x,world.sites.farm,_person_speed*seconds)
			if absf(person.x-world.sites.farm)<20: farmers += 1
		elif person.role == "hunter":
			var prey: Dictionary = {}
			var distance := INF
			for animal in frontier.animals:
				if animal.alive and frontier.regions[animal.region].discovered and absf(animal.x-person.x)<distance:
					distance = absf(animal.x-person.x)
					prey = animal
			if prey.is_empty():
				person.x = move_toward(person.x,world.sites.hunt_tools,_person_speed*seconds)
			else:
				person.x = move_toward(person.x,prey.x,_person_speed*seconds)
				if absf(person.x-prey.x)<45 and person.cooldown<=0:
					prey.alive = false
					person.cooldown = 3.0
					frontier.food += 2
					effects.append({"kind":"bolt","x":person.x,"to":prey.x,"life":0.18})
	frontier.advance_farm(seconds,farmers)

func strike_from(x: float, y: float) -> void:
	super.strike_from(x,y)
	for node in frontier.nodes:
		if absf(node.y-y)<=hero.stats.vertical_range and hero.strike(node,node.x-x):
			effects.append({"kind":"hit","x":node.x,"to":node.x,"life":0.2})
			var reward := frontier.collect(node)
			if not reward.is_empty():
				world.scrap += reward.scrap
				world.crystals += reward.crystals
	for animal in frontier.animals:
		if animal.alive and hero.is_attack_active() and absf(y-430)<42 and (animal.x-x)*hero.attack_facing>=0 and absf(animal.x-x)<=hero.stats.attack_range:
			animal.alive = false
			frontier.food += 2

func kingdom_established() -> bool:
	var citizens := 0
	for person in world.people:
		if person.role != "wanderer": citizens += 1
	return hero.is_alive() and super.finished() and frontier.city_level>=3 and world.wall.level>=2 and world.wall.hp>0 and citizens>=3
