extends RefCounted
const Campaign=preload("res://application/campaign_session.gd")
func setup(t, config: Dictionary={}):
	var sim=Campaign.new(config)
	t.truth(sim.get("ecology")!=null,"campaign exposes renewable frontier rules")
	return sim if sim.get("ecology")!=null else null
func dawn(sim) -> void:
	sim.clock.is_night=true
	sim.clock.remaining=0.01
	sim.advance(0.02,30)
func test_camps_replenish_once_per_real_dawn_and_remain_recruitable(t):
	var sim=setup(t)
	if sim==null:return
	var before: int=sim.world.people.size()
	dawn(sim)
	t.equal(sim.world.people.size(),before+6,"one newcomer reaches each of six camps at dawn")
	sim.advance(0.1,30)
	t.equal(sim.world.people.size(),before+6,"a second update cannot duplicate dawn arrivals")
	var newcomer: Dictionary=sim.world.people.back()
	sim.advance(0.01,newcomer.x)
	var wallet: int=sim.pouch.amount
	t.truth(sim.interact(newcomer.x,"recruit:%d" % (sim.world.people.size()-1)),"new arrival uses existing on-site recruitment")
	t.equal(newcomer.role,"citizen","newcomer becomes a real resident")
	t.equal(sim.pouch.amount,wallet-1,"new resident still costs a crystal")
	dawn(sim)
	t.equal(sim.world.people.size(),before+7,"only the camp with a vacant waiting place replenishes")

func test_camps_do_not_accumulate_infinite_people_or_remove_existing_ids(t):
	var sim=setup(t,{"population_limit":10})
	if sim==null:return
	var first: Dictionary=sim.world.people[0]
	dawn(sim);dawn(sim)
	t.equal(sim.world.people.size(),10,"population bound includes idle and recruited people")
	t.truth(is_same(sim.world.people[0],first),"population bounds preserve stable resident indices")
	var other=setup(t)
	if other==null:return
	dawn(other);dawn(other);dawn(other)
	t.equal(other.world.people.size(),14,"two waiting people per camp prevents endless unseen spawns")

func test_standing_forest_renews_hunted_prey_and_delivered_plants(t):
	var sim=setup(t)
	if sim==null:return
	var forest: int=sim.frontier.regions.find(sim.frontier.regions.filter(func(r):return r.kind=="forest")[0])
	var prey=sim.frontier.animals.filter(func(a):return a.region==forest)
	for animal in prey:animal.alive=false
	var berries=sim.frontier.nodes.filter(func(n):return n.region==forest and n.kind=="berries")[0]
	berries.collected=true;berries.delivered=true;berries.marked=true;berries.remaining_work=0;berries.work_elapsed=6
	var food: int=sim.frontier.food
	dawn(sim)
	t.truth(prey.all(func(a):return a.alive),"standing forest restores hunted animal slots")
	t.truth(not berries.collected and not berries.delivered and not berries.marked,"delivered berry patch regrows without an automatic work order")
	t.equal(berries.remaining_work,75,"renewed patch requires real work again")
	t.equal(sim.frontier.food,food,"dawn never credits free harvest food")

func test_carried_plants_never_duplicate_and_minerals_never_regrow(t):
	var sim=setup(t)
	if sim==null:return
	var herbs=sim.frontier.nodes.filter(func(n):return n.kind=="herbs")[0]
	herbs.collected=true;herbs.carried=true;herbs.worker=0
	sim.world.people[0].role="engineer"
	sim.world.people[0]["y"]=430.0
	sim.world.people[0].x=1000
	var mineral=sim.frontier.nodes.filter(func(n):return n.kind=="crystal")[0]
	mineral.collected=true;mineral.delivered=true
	dawn(sim)
	t.truth(herbs.collected and herbs.carried,"carried herb cargo cannot also regrow at its source")
	t.equal(herbs.worker,0,"dawn preserves the carrying worker")
	t.truth(mineral.collected and mineral.delivered,"mineral rewards remain finite")

func test_clearcut_forest_loses_future_camp_and_prey_without_erasing_survivors(t):
	var sim=setup(t)
	if sim==null:return
	var forest: int=sim.frontier.regions.find(sim.frontier.regions.filter(func(r):return r.kind=="forest")[0])
	var local=sim.world.people.filter(func(p):return p.region==forest)[0]
	for node in sim.frontier.nodes:
		if node.region==forest and node.kind=="tree":node.collected=true
	for animal in sim.frontier.animals:
		if animal.region==forest:animal.alive=false
	var before: int=sim.world.people.size()
	dawn(sim)
	t.equal(sim.world.people.size(),before+5,"cleared woodland no longer attracts a new wanderer")
	t.truth(sim.world.people.has(local) and local.role=="wanderer","existing wanderer is not deleted or punished by a formula")
	t.truth(sim.frontier.animals.filter(func(a):return a.region==forest).all(func(a):return not a.alive),"clearcut forest does not regenerate prey")

func test_last_tree_order_warns_about_habitat_loss(t):
	var sim=setup(t)
	if sim==null:return
	var trees=sim.frontier.nodes.filter(func(n):return n.kind=="tree")
	var node=trees[0]
	sim.advance(0.01,node.x)
	for other in trees:
		if other.region==node.region and other!=node:other.marked=true
	var key: String="node:%d" % sim.frontier.nodes.find(node)
	t.equal(sim.context_for_key(node.x,key).get("consequences",[]),["person","bow"],"last unmarked tree previews recruitment and hunting loss")
	t.truth(sim.interact(node.x,key),"player may still deliberately clear the last tree")
	t.truth(node.marked,"knight orders work instead of cutting with sword")

func test_preserving_one_tree_per_forest_still_allows_city_and_farm(t):
	var sim=Campaign.new({"capacity":20,"starting_crystals":20})
	sim.frontier.city_level=1
	for index in range(sim.frontier.regions.size()):
		if sim.frontier.regions[index].kind!="forest":continue
		sim.frontier.regions[index].discovered=true
		var trees=sim.frontier.nodes.filter(func(n):return n.region==index and n.kind=="tree")
		for node in trees.slice(0,3):
			sim.frontier.mark(node)
			node.advance_work(6,6)
			sim.frontier.collect(node)
			sim.frontier.deposit(node)
	for i in range(3):sim.interact(-350)
	for level in range(2):
		var cost: int=sim.context(30).cost
		for i in range(cost):sim.interact(30)
	t.truth(sim.frontier.farm_active and sim.frontier.city_level==3,"crystals build farm and full city without requiring habitat destruction")
	t.equal(sim.frontier.wood,0,"harvest never introduces timber inventory")
	t.equal(sim.pouch.amount,5,"farm and two town upgrades cost fifteen crystals")

func test_cleared_ground_still_supports_delivered_berry_and_herb_patches(t):
	var sim=setup(t)
	if sim==null:return
	for node in sim.frontier.nodes:
		if node.kind in ["tree","berries","herbs"]:
			node.collected=true
			node.delivered=true
	dawn(sim)
	t.truth(sim.frontier.nodes.filter(func(n):return n.kind in ["berries","herbs"]).all(func(n):return not n.collected),"berries and herbs renew on cleared ground as an alternative income source")
