extends RefCounted
const Frontier = preload("res://domain/frontier.gd")

func test_seed_reproduces_exploration_and_guarantees_reachable_resources(t) -> void:
	var a = Frontier.new(1234)
	var b = Frontier.new(1234)
	var other = Frontier.new(5678)
	t.equal(a.layout_signature(),b.layout_signature(),"same seed reproduces regions and resources")
	t.truth(a.layout_signature()!=other.layout_signature(),"different seeds change exploration layout")
	t.equal(a.regions.size(),6,"six regions surround the refuge")
	var wood := 0
	var food := 0
	for node in a.nodes:
		wood += node.wood
		food += node.food
		t.truth(node.y>=366 and node.y<=430,"resource elevations stay within tested jump envelope")
	t.truth(wood>=22,"map guarantees enough wood for crops and city upgrades")
	t.truth(food>=2,"map guarantees starter food before farming")
	t.equal(a.discovered_count(),0,"exploration begins unknown")
	a.reveal(a.regions[0].x+50)
	t.truth(a.discovered_count()>0,"walking into a region reveals it")

func test_harvest_is_finite_and_rewards_only_once(t) -> void:
	var map = Frontier.new(10)
	var node = map.nodes[0]
	map.reveal(node.x)
	map.mark(node)
	t.equal(node.advance_work(2,6),false,"partial resident work does not finish resource")
	t.equal(map.collect(node),{},"unfinished resource yields nothing")
	node.advance_work(4,6)
	t.truth(not map.collect(node).is_empty(),"completed harvest yields authored resources")
	t.equal(map.collect(node),{},"harvest cannot grant resources twice")
	t.equal(node.advance_work(2,6),false,"completed resource cannot be worked again")

func test_crop_requires_worker_and_hunter_collects_discovered_animals(t) -> void:
	var Sim = load("res://application/frontier_session.gd")
	var sim = Sim.new({"first_raid":1000.0,"seed":42})
	sim.frontier.wood = 2
	sim.frontier.food = 1
	t.truth(sim.interact(sim.world.sites.farm),"field can be opened with wood and seed food")
	for tick in range(130): sim.advance(0.1,150)
	t.equal(sim.frontier.food,0,"unattended field produces no food")
	sim.world.people[0].role = "farmer"
	sim.world.people[0].x = sim.world.sites.farm
	for tick in range(125): sim.advance(0.1,150)
	t.equal(sim.frontier.food,2,"farmer harvests and reserves seed for next crop")
	var animal: Dictionary = sim.frontier.animals[0]
	sim.frontier.reveal(animal.x)
	sim.world.people[1].role = "hunter"
	sim.world.people[1].x = animal.x
	sim.advance(0.1,150)
	t.equal(animal.alive,false,"hunter takes nearby discovered prey")
	t.equal(sim.frontier.food,4,"one animal adds food once")

func test_tools_assign_new_jobs_and_city_requires_real_progress(t) -> void:
	var Sim = load("res://application/frontier_session.gd")
	var sim = Sim.new({"first_raid":1000.0})
	sim.world.people[0].role = "citizen"
	sim.world.people[0].x = sim.world.sites.farm_tools
	t.truth(sim.interact(sim.world.sites.farm_tools),"player stocks farming implement in world")
	sim.advance(0.1,150)
	t.equal(sim.world.people[0].role,"farmer","citizen automatically takes farming profession")
	t.equal(sim.interact(sim.world.sites.hall),false,"empty supplies cannot upgrade city")
	sim.frontier.wood = 20
	sim.frontier.food = 10
	sim.world.scrap = 20
	t.truth(sim.interact(sim.world.sites.hall),"supplies upgrade settlement to town")
	t.truth(sim.interact(sim.world.sites.hall),"more supplies upgrade town to royal city")
	t.equal(sim.world.scrap,8,"city upgrades deduct their actual salvage cost")
	t.equal(sim.frontier.wood,0,"city consumes construction timber")
	t.equal(sim.kingdom_established(),false,"city appearance alone is not a kingdom victory")
	sim.wave = 3
	sim.world.wall.level = 2
	sim.world.wall.hp = 80
	for index in range(3): sim.world.people[index].role = "citizen"
	t.truth(sim.kingdom_established(),"royal city, defended walls and residents complete the loop")

func test_economy_tuning_changes_crop_output_and_training(t) -> void:
	var Sim = load("res://application/frontier_session.gd")
	var sim = Sim.new({"first_raid":1000.0,"economy":{"farm_cycle":6.0,"farm_yield":4,"training_food":3,"training_damage":7}})
	sim.frontier.wood = 2
	sim.frontier.food = 1
	sim.interact(sim.world.sites.farm)
	sim.world.people[0].role = "farmer"
	sim.world.people[0].x = sim.world.sites.farm
	for tick in range(61): sim.advance(0.1,150)
	t.equal(sim.frontier.food,4,"configured cycle and yield drive real production")
	t.truth(sim.interact(sim.world.sites.drill),"configured training can be paid from crop")
	t.equal(sim.frontier.food,1,"configured training cost deducted")
	t.equal(sim.hero.stats.damage,32,"configured training gain affects real sword")

func test_generated_resources_can_fund_the_complete_kingdom_loop(t) -> void:
	var Sim = load("res://application/frontier_session.gd")
	var sim = Sim.new({"first_raid":100000.0,"seed":742601})
	for person in sim.world.people:
		sim.interact(person.x)
		sim.advance(0.1,person.x)
	for tool in range(2): sim.interact(sim.world.sites.workshop)
	for node in sim.frontier.nodes:
		sim.advance(0.01,node.x,node.y)
		sim.interact(node.x)
	for tick in range(12000):
		sim.advance(0.25,150)
		var done := true
		for node in sim.frontier.nodes:
			if not node.get("delivered"): done = false
		if done: break
	t.truth(sim.frontier.wood>=22 and sim.world.scrap>=20,"real workers deliver map resources without invented inventory")
	for site in ["farm_tools","hunt_tools","armory"]: sim.interact(sim.world.sites[site])
	t.truth(sim.interact(sim.world.sites.farm),"delivered timber and berries pay for planting")
	for tick in range(350): sim.advance(0.1,150)
	var roles: Array = []
	for person in sim.world.people: roles.append(person.role)
	t.truth(roles.has("farmer") and roles.has("hunter") and roles.has("engineer") and roles.has("guard"),"citizens autonomously fill production and defence jobs")
	for level in range(2):
		t.truth(sim.interact(sim.world.sites.wall),"delivered salvage funds wall construction")
		for tick in range(150): sim.advance(0.1,150)
	t.truth(sim.interact(sim.world.sites.hall),"resident production funds town")
	t.truth(sim.interact(sim.world.sites.drill),"produced food strengthens knight")
	for charge in range(4): sim.interact(sim.world.sites.forge)
	for wave in range(3):
		sim.begin_raid()
		for tick in range(260):
			var x := 1450.0
			if not sim.raiders.is_empty(): x = sim.raiders[0].x-25
			sim.hero.facing = 1
			sim.hero.start_attack()
			sim.advance(0.1,x)
			sim.strike_from(x,430)
			if sim.raiders.is_empty() and tick>110: break
	t.truth(sim.interact(sim.world.sites.hall),"resident economy and defended raids fund royal city")
	t.truth(sim.kingdom_established(),"worker-led expansion still completes the kingdom loop")
