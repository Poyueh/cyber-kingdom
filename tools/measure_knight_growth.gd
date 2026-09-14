extends SceneTree
## Isolated, deterministic combat/economy probe. Not a complete campaign playthrough.
const Campaign=preload("res://application/campaign_session.gd")
const Mapper=preload("res://bootstrap/tuning_mapper.gd")
func _initialize() -> void:
	var results: Array=[]
	for day in [1,3,5]:
		for route in ["base","sword","capacitor"]:
			results.append(measure(day,route))
	print(JSON.stringify({"probe":"equal-nine-crystal-growth-comparison","dt":1.0/60,"results":results},"  "))
	quit()
func setup(day: int, route: String):
	var tuning=load("res://data/campaign.tres")
	var config: Dictionary=tuning.campaign_rules()
	config["economy"]=tuning.economy_rules()
	config["shield_value"]=tuning.shield_per_crystal
	var sim=Campaign.new(config,Mapper.knight_stats(load("res://data/knight.tres"),load("res://data/knight_combo.tres")))
	sim.frontier.city_level=3
	sim.world.people.clear()
	sim.world.scrap=30
	sim.frontier.food=30
	if route!="base":
		var at:=1230.0 if route=="sword" else 350.0
		for level in range(3):
			var choice: Dictionary=sim.context(at)
			assert(choice.enabled)
			for slot in range(choice.cost):assert(sim.interact(at,choice.key))
	sim.clock.day=day
	return sim
func measure(day: int, route: String) -> Dictionary:
	var sim=setup(day,route)
	var expense: Dictionary={"crystals":12-sim.pouch.amount,"food":30-sim.frontier.food,"scrap":30-sim.world.scrap}
	var enemy=sim._spawn_raider()
	var knight_x: float=-2200
	enemy.x=knight_x+30
	sim.raiders.append(enemy)
	var elapsed:=0.0
	var hits:=0
	var queued_step: int=-1
	while elapsed<20 and sim.is_running() and enemy.fighter.is_alive():
		var delta: float=enemy.x-knight_x
		sim.hero.facing=1 if delta>=0 else -1
		if sim.hero.attack_remaining<=0 and absf(delta)>50:
			knight_x=move_toward(knight_x,enemy.x,190.0/60)
		if sim.hero.combo_step==0:
			if sim.hero.start_attack():queued_step=-1
		elif sim.hero.combo_step<3 and sim.hero.attack_progress()>=0.6 and queued_step!=sim.hero.combo_step:
			queued_step=sim.hero.combo_step
			sim.hero.start_attack()
		sim.advance(1.0/60,knight_x)
		knight_x+=sim.hero.consume_attack_travel()
		var hp: int=enemy.fighter.hp
		sim.strike_from(knight_x,430)
		if enemy.fighter.hp<hp:hits+=1
		elapsed+=1.0/60
	var defense=setup(day,route)
	var attacker=defense._spawn_raider()
	attacker.x=-2170
	defense.raiders.append(attacker)
	var blows:=0
	for tick in range(3600):
		if not defense.is_running():break
		var effective: int=defense.hero.hp+defense.hero.shield
		defense.advance(1.0/60,-2200)
		if defense.hero.hp+defense.hero.shield<effective:blows+=1
	return {"day":day,"route":route,"spent":expense,"sword_damage":sim.hero.stats.damage,"shield_capacity":sim.growth.capacity(),
		"duel":{"won":not enemy.fighter.is_alive(),"seconds":snappedf(elapsed,0.01),"landed_slashes":hits,"hp_left":sim.hero.hp,"shield_left":sim.hero.shield},
		"standing_still":{"incoming_damage":attacker.fighter.stats.damage,"blow_causing_death":blows,"dead":not defense.hero.is_alive()}}
