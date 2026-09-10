extends RefCounted

func test_crystal_pouch_conserves_overflow_and_ground_pickups(t) -> void:
	var script = load("res://domain/crystal_pouch.gd")
	if script == null:
		t.truth(false,"crystal pouch is implemented")
		return
	var bag = script.new(4,3)
	bag.receive(5,100.0,366.0)
	t.equal(bag.amount,4,"backpack capacity limits received treasure")
	t.equal(bag.ground_total(),4,"every excess crystal spills into scene")
	bag.pick_up(100,430)
	t.equal(bag.ground_total(),4,"ground pickup respects vertical distance")
	t.truth(bag.spend(),"one investment removes one crystal")
	bag.pick_up(100,366)
	t.equal(bag.amount,4,"walking back collects only available space")
	t.equal(bag.ground_total(),3,"remaining crystals stay in scene")
	bag.receive(-3,0,430)
	t.equal(bag.amount,4,"invalid rewards cannot remove crystals")

func campaign(t, config: Dictionary = {}):
	var script = load("res://application/campaign_session.gd")
	if script == null:
		t.truth(false,"campfire campaign is implemented")
		return null
	return script.new(config)

func test_campfire_investments_persist_and_never_double_charge(t) -> void:
	var sim = campaign(t)
	if sim == null: return
	t.equal(sim.frontier.city_level,0,"kingdom starts at a campfire")
	t.equal(sim.context(30).cost,2,"campfire shows two crystal slots")
	var before: int = sim.pouch.amount
	t.truth(sim.interact(30),"first crystal can be invested")
	t.equal(sim.frontier.city_level,0,"one slot does not finish a two-crystal project")
	sim.advance(0.1,-200)
	t.equal(sim.context(30).paid,1,"leaving preserves invested slot")
	t.truth(sim.interact(30),"second crystal establishes camp")
	t.equal(sim.frontier.city_level,1,"filled campfire becomes a settlement")
	t.equal(sim.pouch.amount,before-2,"construction charges exactly the displayed amount")
	t.truth(not sim.interact(30),"missing upgrade materials cannot consume another crystal")
	t.equal(sim.pouch.amount,before-2,"invalid repeat leaves backpack unchanged")

func test_knight_opens_chest_once_and_full_bag_spills(t) -> void:
	var sim = campaign(t,{"capacity":2,"starting_crystals":2})
	if sim == null: return
	var chest
	for node in sim.frontier.nodes:
		if node.kind=="cache" and node.y==430: chest=node; break
	sim.advance(0.1,chest.x,chest.y)
	t.equal(sim.context(chest.x).id,"chest","treasure is a direct knight interaction")
	var before: int = sim.world.scrap
	t.truth(sim.interact(chest.x),"knight opens treasure without a worker")
	t.truth(chest.delivered and sim.world.scrap>before,"treasure contents arrive once")
	t.equal(sim.pouch.amount,2,"chest cannot overfill backpack")
	t.equal(sim.pouch.ground_total(),chest.crystals,"excess chest crystals remain at chest height")
	sim.interact(chest.x)
	t.equal(sim.world.scrap,before+chest.scrap,"opened chest never pays twice")

func test_discovered_wanderer_recruits_with_crystal_and_keeps_role_until_hit(t) -> void:
	var sim = campaign(t)
	if sim == null: return
	var person: Dictionary = sim.world.people[2]
	t.truth(not sim.person_visible(person),"distant wanderer is hidden until explored")
	sim.advance(0.1,person.x)
	t.truth(sim.person_visible(person),"exploring reveals the actual wanderer")
	var before: int = sim.pouch.amount
	t.truth(sim.interact(person.x),"one crystal recruits the discovered wanderer")
	t.equal(person.role,"citizen","recruitment creates a resident")
	t.equal(sim.pouch.amount,before-1,"recruitment uses the knight backpack")
	sim.advance(1,person.x)
	t.equal(person.role,"citizen","elapsed time never demotes resident")
	sim.world.hit_person(2)
	t.equal(person.role,"wanderer","actual unprotected hit returns resident to wanderer")

func test_nights_continue_after_three_and_raise_actual_enemy_stats(t) -> void:
	var sim = campaign(t,{"day_seconds":1.0,"night_seconds":1.0})
	if sim == null: return
	sim.advance(1.1,1560)
	t.truth(sim.clock.is_night,"first day transitions into night")
	var first = sim.raiders[0].fighter
	t.equal(sim.clock.survived,0,"starting night is not yet survived")
	for night in range(4):
		for tick in range(150):
			for raider in sim.raiders: raider.fighter.hp=0
			sim.advance(0.1,1560)
			if not sim.clock.is_night: break
		t.equal(sim.clock.survived,night+1,"only a completed night increments survival")
		if night<3: sim.advance(1.1,1560)
	sim.advance(1.1,1560)
	t.equal(sim.clock.day,5,"campaign continues into day five")
	t.truth(sim.raiders[0].fighter.stats.max_hp>first.stats.max_hp,"later monsters have more actual health")
	t.truth(sim.raiders[0].fighter.stats.damage>first.stats.damage,"later monsters hit harder")
	t.truth(not sim.finished(),"three waves no longer stop campaign")

func test_resident_delivery_leaves_crystals_at_depot_and_banks_stone(t) -> void:
	var sim = campaign(t,{"day_seconds":10000.0})
	if sim == null: return
	sim.interact(30); sim.interact(30)
	sim.interact(180)
	sim.interact(520); sim.interact(520)
	for tick in range(100): sim.advance(0.1,520)
	t.equal(sim.world.people[0].role,"engineer","purchased tool is autonomously taken by recruited citizen")
	var node
	for candidate in sim.frontier.nodes:
		if candidate.kind=="crystal": node=candidate; break
	sim.advance(0.1,node.x)
	sim.interact(node.x)
	var before: int = sim.pouch.amount
	for tick in range(2500):
		sim.advance(0.1,node.x)
		if node.delivered: break
	t.truth(node.delivered,"real worker completes mining and returns to depot")
	t.equal(sim.pouch.amount,before,"remote delivery never teleports into knight backpack")
	t.equal(sim.world.crystals,0,"world treasury does not duplicate dropped crystals")
	t.equal(sim.pouch.ground_total(),node.crystals,"delivery leaves all crystals at the physical depot")
	sim.advance(0.1,30)
	t.equal(sim.pouch.amount,mini(sim.pouch.capacity,before+node.crystals),"knight collects at the depot")
	for candidate in sim.frontier.nodes:
		if candidate.kind=="stone": node=candidate; break
	sim.advance(0.1,node.x)
	sim.interact(node.x)
	for tick in range(2500):
		sim.advance(0.1,node.x)
		if node.delivered: break
	t.equal(sim.frontier.stone,6,"stone is physically collected and banked by worker")

func test_resources_have_distinct_uses_and_renewable_crystal_trade(t) -> void:
	var sim = campaign(t)
	if sim == null: return
	sim.interact(30); sim.interact(30)
	sim.frontier.herbs=2
	sim.hero.hp=40
	t.truth(sim.interact(-850),"herbs treat an injured knight")
	t.equal(sim.hero.hp,70,"herbal treatment restores actual health")
	t.equal(sim.frontier.herbs,0,"herbs are consumed")
	sim.frontier.wood=2; sim.frontier.food=1
	for slot in range(3): sim.interact(-350)
	sim.world.people[0].role="farmer"
	sim.world.people[0].x=-350
	sim.advance(24,-350)
	t.equal(sim.frontier.food,4,"farmer produces two net harvests while retaining seed")
	var before: int=sim.pouch.amount
	t.truth(sim.interact(-700),"surplus harvest trades into crystals")
	t.equal(sim.frontier.food,0,"trade consumes food exactly once")
	t.equal(sim.pouch.amount,before+2,"renewable farming replenishes investment currency")
	t.truth(not sim.interact(-700),"empty trade cannot generate free crystals")
	var shield: int=sim.hero.shield
	t.truth(not sim.interact(350),"forge also requires recovered scrap")
	sim.world.scrap=2
	sim.interact(350); sim.interact(350)
	t.equal(sim.world.scrap,0,"forging consumes salvaged scrap")
	t.equal(sim.hero.shield,shield+sim.world.shield_value,"scrap and crystals power an actual knight shield")

func test_later_night_damage_reaches_knight_and_wall(t) -> void:
	var sim = campaign(t)
	if sim == null: return
	sim.clock.day=3
	sim.clock.remaining=0.01
	sim.advance(0.02,1560)
	var raider: Dictionary=sim.raiders[0]
	var hp: int=sim.hero.hp
	sim.advance(0.61,1560)
	t.equal(sim.hero.hp,hp-21,"day-three windup lands increased damage on the real knight")
	sim.world.wall.level=1
	sim.world.wall.hp=40
	raider.x=1120
	raider.cooldown=0.0
	sim.advance(0.02,30)
	sim.advance(0.61,30)
	t.equal(sim.world.wall.hp,14,"day-three attacker also deals increased damage to a real wall")

func test_insufficient_crystals_preserve_partial_project_and_target_independence(t) -> void:
	var sim = campaign(t,{"starting_crystals":1})
	if sim == null: return
	sim.interact(30)
	t.truth(not sim.interact(30),"empty backpack cannot fill the last slot")
	t.equal(sim.context(30).paid,1,"unfinished investment survives insufficient funds")
	sim.pouch.receive(2,30)
	sim.interact(180)
	t.equal(sim.context(30).paid,1,"recruiting elsewhere does not overwrite building slots")
	sim.interact(30)
	t.equal(sim.frontier.city_level,1,"returning with one remaining crystal completes the camp")
	t.equal(sim.pouch.amount,0,"independent transactions conserve every crystal")
