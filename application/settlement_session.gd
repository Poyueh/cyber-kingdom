extends RefCounted
const World = preload("res://domain/settlement.gd")
const Fighter = preload("res://domain/combatant.gd")
const Stats = preload("res://domain/combat_stats.gd")
var world: World
var hero: Fighter
var raiders: Array[Dictionary] = []
var loot: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var wave: int = 0
var time_to_raid: float
var _raid_gap: float
var _person_speed: float
var _spawn_remaining := 0
var _spawn_timer := 0.0

func _init(config: Dictionary = {}, hero_stats: Stats = null) -> void:
	world = World.new(config)
	hero = Fighter.new(hero_stats if hero_stats != null else Stats.new())
	time_to_raid = maxf(1.0,float(config.get("first_raid",55.0)))
	_raid_gap = maxf(1.0,float(config.get("raid_gap",30.0)))
	_person_speed = maxf(1.0,float(config.get("person_speed",60.0)))

func finished() -> bool:
	return wave >= 3 and raiders.is_empty() and _spawn_remaining == 0

func context(x: float) -> Dictionary:
	var result := {"id":"", "x":x, "text":"靠近流浪者或建築，投入資源", "cost":0, "currency":"", "enabled":false,"reason":"靠近目標才能投入"}
	var nearest := 73.0
	for person in world.people:
		var distance := absf(person.x-x)
		if person.role == "wanderer" and distance < nearest:
			nearest = distance
			result = {"id":"recruit", "x":person.x, "text":"投放補給，招攬流浪者", "cost":1,"currency":"廢料","enabled":world.scrap>0,"reason":"廢料不足"}
	for site in world.sites:
		var distance := absf(world.sites[site]-x)
		if distance >= nearest:
			continue
		nearest = distance
		var cost := 2
		var currency := "廢料"
		var label := ""
		var enabled := true
		var reason := ""
		match site:
			"forge":
				cost = 1
				currency = "龍晶"
				label = "義肢爐：騎士護盾 +%d" % world.shield_value
			"workshop":
				label = "工坊：補充工程錘（庫存 %d）" % world.tools.hammer
				enabled = world.tools.hammer < 3
				reason = "工程錘庫存已滿"
			"armory":
				label = "武器坊：補充守備器具（庫存 %d）" % world.tools.blade
				enabled = world.tools.blade < 3
				reason = "守備器具庫存已滿"
			"beacon":
				cost = 1
				currency = "龍晶"
				label = "護民塔：抵擋一次居民受擊"
			"wall":
				cost = world.wall_cost()
				label = "防線：建造" if world.wall.level == 0 else "防線：升級"
				if world.wall.hp < world.wall.level*40:
					label = "防線：修復"
				if world.wall.pending:
					label = "防線施工  %d%%" % mini(100,int(world.wall.progress/3.0*100))
					reason = "等待工程師到場"
					for person in world.people:
						if person.role == "engineer" and absf(person.x-world.sites.wall)<20:
							reason = "工程師正在施工，不需再次付款"
					cost = 0
					enabled = false
				elif world.wall.level >= 2 and world.wall.hp == 80:
					label = "防線已達最高等級"
					cost = 0
					reason = "防線完整，暫不需要施工"
					enabled = false
			"horn":
				cost = 0
				currency = ""
				label = "警鐘：提前迎戰下一波"
				enabled = raiders.is_empty() and _spawn_remaining == 0 and not finished()
				reason = "三波試煉已結束" if finished() else "夜襲進行中"
		if enabled and currency == "廢料" and world.scrap < cost:
			enabled = false
			reason = "廢料不足"
		elif enabled and currency == "龍晶" and world.crystals < cost:
			enabled = false
			reason = "龍晶不足"
		result = {"id":site,"x":world.sites[site],"text":label,"cost":cost,"currency":currency,"enabled":enabled,"reason":reason}
	return result

func interact(x: float) -> bool:
	if not hero.is_alive():
		return false
	var choice := context(x)
	if not choice.enabled:
		return false
	var success := false
	match choice.id:
		"recruit": success = world.drop_supply(x + hero.facing*8)
		"forge":
			hero.shield += world.take_knight_crystal()
			success = true
		"workshop": success = world.buy_tool("hammer")
		"armory": success = world.buy_tool("blade")
		"beacon": success = world.power_refuge()
		"wall": success = world.order_wall()
		"horn": success = begin_raid()
	if success:
		effects.append({"kind":"pay","x":x,"to":choice.x,"life":0.45})
	return success

func begin_raid() -> bool:
	if not raiders.is_empty() or _spawn_remaining > 0 or finished():
		return false
	time_to_raid = _raid_gap
	wave += 1
	_spawn_remaining = 2 + wave
	_spawn_timer = 0.0
	return true

func advance(seconds: float, hero_x: float, hero_y: float = 430.0) -> void:
	if seconds <= 0 or not is_finite(seconds) or not hero.is_alive():
		return
	hero.advance(seconds)
	for effect in effects:
		effect.life -= seconds
	effects = effects.filter(func(effect): return effect.life > 0)
	for supply in world.supplies:
		supply.age += seconds
	_advance_people(seconds)
	if _spawn_remaining > 0:
		_spawn_timer -= seconds
		if _spawn_timer <= 0:
			var stats := Stats.new()
			stats.max_hp = 60
			raiders.append({"x":1580.0,"fighter":Fighter.new(stats),"windup":0.0,"cooldown":0.0,"target":{}})
			_spawn_remaining -= 1
			_spawn_timer = 2.5
	elif raiders.is_empty() and not finished():
		time_to_raid -= seconds
		if time_to_raid <= 0:
			begin_raid()
	for raider in raiders:
		_advance_raider(raider,seconds,hero_x,hero_y)
	for raider in raiders:
		if not raider.fighter.is_alive() and not raider.get("escaped", false):
			loot.append({"x":raider.x,"taken":false})
	raiders = raiders.filter(func(raider): return raider.fighter.is_alive())
	for drop in loot:
		if not drop.taken and absf(drop.x-hero_x)<28 and absf(hero_y-430)<45:
			drop.taken = true
			world.scrap += 2

func _advance_people(seconds: float) -> void:
	for index in range(world.people.size()):
		var person: Dictionary = world.people[index]
		person.hurt = maxf(0,person.hurt-seconds)
		person.cooldown = maxf(0,person.cooldown-seconds)
		var target: float = person.x
		match person.role:
			"wanderer":
				var nearest := INF
				for supply_index in range(world.supplies.size()):
					var supply: Dictionary = world.supplies[supply_index]
					if not supply.taken and absf(supply.x-person.x)<nearest:
						nearest = absf(supply.x-person.x)
						target = supply.x
						world.collect_supply(index,supply_index)
			"citizen":
				var nearest := INF
				for kind in world.tools:
					var rack: float = world.sites.workshop if kind == "hammer" else world.sites.armory
					if world.tools[kind]>0 and absf(rack-person.x)<nearest:
						nearest = absf(rack-person.x)
						target = rack
						world.claim_tool(index,kind)
			"engineer":
				if world.wall.pending:
					target = world.sites.wall-12
					world.work_wall(index,seconds)
			"guard":
				target = world.sites.wall-65-index*18
				for raider in raiders:
					if raider.fighter.is_alive() and absf(raider.x-person.x)<190 and person.cooldown <= 0:
						raider.fighter.take_damage(20)
						person.cooldown = 0.85
						effects.append({"kind":"bolt","x":person.x,"to":raider.x,"life":0.18})
		person.x = move_toward(person.x,target,_person_speed*seconds)

func _target(raider: Dictionary, hero_x: float, hero_y: float) -> Dictionary:
	if absf(hero_x-raider.x)<65 and absf(hero_y-430)<42:
		return {"kind":"hero","x":hero_x}
	if world.wall.hp>0 and raider.x>=world.sites.wall-25:
		return {"kind":"wall","x":world.sites.wall}
	var result := {"kind":"leave","x":1650.0}
	var nearest := INF
	for index in range(world.people.size()):
		var person: Dictionary = world.people[index]
		if person.role != "wanderer" and absf(person.x-raider.x)<nearest:
			nearest = absf(person.x-raider.x)
			result = {"kind":"person","x":person.x,"index":index}
	return result

func _advance_raider(raider: Dictionary, seconds: float, hero_x: float, hero_y: float) -> void:
	raider.fighter.advance(seconds)
	if not raider.fighter.is_alive():
		return
	raider.cooldown = maxf(0,raider.cooldown-seconds)
	if raider.windup > 0:
		raider.windup = maxf(0,raider.windup-seconds)
		if raider.windup == 0:
			var target: Dictionary = raider.target
			var at: float = target.x
			if target.kind == "person": at = world.people[target.index].x
			if target.kind == "hero": at = hero_x
			if absf(at-raider.x)<38:
				match target.kind:
					"hero":
						if absf(hero_y-430)<42: hero.take_damage(15)
					"wall": world.hit_wall(20)
					"person": world.hit_person(target.index)
				effects.append({"kind":"hit","x":at,"to":at,"life":0.25})
		return
	var target := _target(raider,hero_x,hero_y)
	if target.kind == "leave":
		# Leaving has no melee stopping distance or attack windup.
		raider.x = move_toward(raider.x,target.x,70*seconds)
		if raider.x>=1640:
			raider.fighter.hp = 0
			raider["escaped"] = true
		return
	if absf(target.x-raider.x)>26:
		raider.x = move_toward(raider.x,target.x,70*seconds)
	elif raider.cooldown <= 0:
		raider.target = target
		raider.windup = 0.6
		raider.cooldown = 1.5

func strike_from(x: float, y: float) -> void:
	if absf(y-430)>hero.stats.vertical_range:
		return
	for raider in raiders:
		if hero.strike(raider.fighter,raider.x-x):
			effects.append({"kind":"hit","x":raider.x,"to":raider.x,"life":0.2})
