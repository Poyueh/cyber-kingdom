extends RefCounted
const Campaign=preload("res://application/campaign_session.gd")
func camp():
	var sim=Campaign.new()
	sim.frontier.city_level=1
	sim.world.people.clear()
	return sim
func add_person(sim, role: String, x: float):
	var person={"role":role,"x":x,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1}
	sim.world.people.append(person)
	return person

func test_exploration_reveals_wall_plot_but_requires_local_preparation(t):
	var sim=camp()
	var id: String="frontier_wall:0"
	t.truth(sim.world.walls.has(id),"map has an outward construction plot per region")
	if not sim.world.walls.has(id):return
	var x: float=sim.world.sites[id]
	t.truth(sim.context(x).id.is_empty(),"unexplored plot is hidden")
	sim.frontier.regions[0].discovered=true
	var choice=sim.context(x)
	t.equal(choice.id,"wall","revealed expansion uses wall interaction icon")
	t.truth(not choice.enabled,"unprepared expansion cannot spend")
	t.truth(choice.prerequisites.any(func(p):return p.icon=="camp"),"city gate is shown")
	sim.frontier.city_level=2
	sim.frontier.regions[0].outpost_built=true
	sim.world.walls.wall_left.merge({"level":1,"hp":40},true)
	for node in sim.frontier.nodes:
		if node.kind=="tree" and absf(node.x-x)<80:node.collected=true
	choice=sim.context(x)
	t.truth(choice.enabled,"city, outpost, previous defense and clearing unlock local wall")
	t.equal(choice.cost,3,"wood wall price uses actual crystal slots")
	sim.interact(x);sim.interact(x)
	t.equal(sim.context(x).paid,2,"partial payment stays at outward plot")
	t.truth(not sim.world.walls[id].pending,"partial payment cannot move frontier")
	sim.interact(x)
	t.truth(sim.world.walls[id].pending,"full payment starts resident construction")
	add_person(sim,"engineer",x+12)
	for i in range(200):sim.advance(1.0/60,30)
	t.equal(sim.world.walls[id].hp,40,"engineer physically builds outer wall")
	t.equal(sim.world.walls.wall_left.hp,40,"construction preserves inner wall")

func prepared():
	var sim=camp()
	sim.frontier.city_level=2
	for region in sim.frontier.regions:
		region.discovered=true
		region.outpost_built=true
		region.outpost_x=region.x+region.width*0.5
	for node in sim.frontier.nodes:
		if node.kind=="tree":node.collected=true
	for id in ["wall","wall_left"]:sim.world.walls[id].merge({"level":1,"hp":40},true)
	return sim

func test_expansion_is_sequential_and_trees_must_be_actually_cleared(t):
	var sim=prepared()
	var next_x: float=sim.world.sites["frontier_wall:1"]
	t.truth(not sim.context_for_key(next_x,"frontier_wall:1:0:false").enabled,"cannot skip the previous outward wall")
	var first_x: float=sim.world.sites["frontier_wall:0"]
	var tree=load("res://domain/harvest_node.gd").new()
	tree.kind="tree";tree.x=first_x+45;tree.region=0;tree.marked=true
	sim.frontier.nodes.append(tree)
	t.truth(not sim.context_for_key(first_x,"frontier_wall:0:0:false").enabled,"marked standing tree still blocks construction")
	tree.collected=true
	t.truth(sim.context(first_x).enabled,"finished felling opens wall footprint")
	sim.world.walls["frontier_wall:0"].merge({"level":1,"hp":40},true)
	t.truth(sim.context(next_x).enabled,"finished inner expansion opens next outward segment")

func test_guards_advance_only_after_completion_and_fall_back_without_switching_sides(t):
	var sim=prepared()
	var right=add_person(sim,"guard",1035)
	var left=add_person(sim,"guard",-1035)
	sim.advance(0.01,30)
	sim.world.walls["frontier_wall:0"].pending=true
	sim.advance(0.1,30)
	t.truth(left.x>= -1040,"paid but unfinished wall does not pull guards outward")
	sim.world.walls["frontier_wall:0"].merge({"level":1,"hp":40,"pending":false},true)
	for i in range(600):sim.advance(1.0/60,30)
	t.truth(left.x< -1500,"left guard walks to newly completed frontier")
	t.truth(right.x>1000 and right.x<1100,"other side assignment stays put")
	var previous: float=left.x
	sim.world.walls["frontier_wall:0"].hp=0
	sim.advance(0.2,30)
	t.truth(left.x>previous,"broken outer wall sends guard back toward inner wall")
	t.equal(left.defense_post,"wall_left","fallback preserves strategic side")

func test_night_spawn_is_outside_expanded_territory(t):
	var sim=prepared()
	sim.world.walls["frontier_wall:3"].merge({"level":1,"hp":40},true)
	sim.clock.remaining=0.01
	sim.advance(0.02,30)
	t.truth(sim.raiders[0].x>sim.world.sites["frontier_wall:3"],"raider cannot appear inside completed outward wall")

func test_safe_outpost_shortens_worker_return_but_lost_wall_forces_core_retreat(t):
	var sim=prepared()
	var x: float=sim.world.sites["frontier_wall:0"]
	sim.world.walls["frontier_wall:0"].merge({"level":1,"hp":40},true)
	var home: float=sim.frontier.regions[0].outpost_x
	var worker=add_person(sim,"engineer",home)
	sim.clock.is_night=true;sim.clock.remaining=50
	sim.advance(0.1,30)
	t.truth(absf(worker.x-home)<0.1,"worker shelters at protected outpost instead of crossing the whole island")
	sim.world.walls["frontier_wall:0"].hp=0
	sim.advance(0.1,30)
	t.truth(worker.x>home,"loss of protection makes worker retreat inward")

func test_outer_wall_intercepts_then_inner_wall_remains_a_second_defense(t):
	var sim=prepared()
	var id: String="frontier_wall:3"
	var x: float=sim.world.sites[id]
	sim.world.walls[id].merge({"level":1,"hp":40},true)
	var enemy=sim._spawn_raider()
	enemy.x=x+25
	sim.raiders.append(enemy)
	sim.advance(0.02,30);sim.advance(0.61,30)
	t.equal(sim.world.walls[id].hp,20,"first strike lands on outer wall")
	t.equal(sim.world.wall.hp,40,"outer siege leaves inner wall intact")
	sim.world.walls[id].hp=0
	enemy.x=1125;enemy.windup=0;enemy.cooldown=0
	sim.advance(0.02,30);sim.advance(0.61,30)
	t.equal(sim.world.wall.hp,20,"inner wall blocks invasion after outer wall loss")
	t.equal(sim.mission.core_hp,180,"second line protects core")
	var before: int=sim.pouch.amount
	t.truth(sim.interact(x),"destroyed outer wall accepts repair payment")
	t.truth(sim.interact(x),"second crystal completes repair order")
	t.equal(sim.pouch.amount,before-2,"repair uses two real crystals")
	add_person(sim,"engineer",x-12)
	sim.raiders.clear()
	for i in range(200):sim.advance(1.0/60,30)
	t.equal(sim.world.walls[id].hp,40,"worker restores outer wall without rebuilding tier")

func test_seeded_expansion_spawns_stay_on_map_and_beyond_both_fronts(t):
	for seed_value in [1,7,42]:
		var sim=Campaign.new({"seed":seed_value})
		for id in sim.defenses.plots:sim.world.walls[id].merge({"level":1,"hp":40},true)
		for side in [-1,1]:
			var x: float=sim.defenses.spawn_x(side)
			var front: float=sim.world.sites[sim.defenses.active_post(side)]
			t.truth(side*x>side*front and x>sim.frontier.left_boundary and x<sim.frontier.right_boundary,"spawn remains outside furthest completed wall inside seeded map")
