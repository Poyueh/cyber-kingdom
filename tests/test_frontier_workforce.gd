extends RefCounted
const Sim = preload("res://application/frontier_session.gd")
func tree_in(sim):
	for node in sim.frontier.nodes:
		if node.kind=="tree": return node
	return null
func settle(sim, count: int, at: float = 150) -> void:
	for tick in range(count): sim.advance(0.1,at)

func test_knight_marks_work_and_sword_never_harvests(t) -> void:
	var sim = Sim.new({"first_raid":10000.0})
	var node = tree_in(sim)
	sim.advance(0.1,node.x)
	t.truth(sim.interact(node.x),"E marks a tree for resident work")
	t.equal(sim.hero.attack_remaining,0.0,"marking never starts knight sword animation")
	t.equal(sim.interact(node.x),false,"already marked job cannot be ordered twice")
	for swing in range(3):
		sim.hero.start_attack()
		sim.hero.advance(0.18)
		sim.strike_from(node.x-20,430)
		sim.hero.advance(0.5)
	t.equal(node.remaining_work,75,"knight sword cannot damage trees")
	settle(sim,100,node.x)
	t.equal(sim.frontier.wood,0,"mark without worker yields no instant resources")

func test_worker_walks_chops_and_hauls_before_bank_receives_resources(t) -> void:
	var sim = Sim.new({"first_raid":10000.0})
	var node = tree_in(sim)
	var worker = sim.world.people[0]
	sim.interact(worker.x)
	settle(sim,2)
	sim.interact(sim.world.sites.workshop)
	settle(sim,100)
	t.equal(worker.role,"engineer","citizen takes real stocked kit for construction and harvesting")
	sim.advance(0.1,node.x)
	sim.interact(node.x)
	settle(sim,5)
	t.equal(node.remaining_work,75,"distant worker must travel before cutting")
	for tick in range(1000):
		sim.advance(0.1,150)
		if node.collected: break
	t.truth(node.collected,"worker reaches and finishes ordered tree")
	t.equal(sim.frontier.wood,0,"felled timber is still carried until delivery")
	t.truth(absf(worker.x-node.x)<40,"cut occurs at resource rather than at workshop")
	for tick in range(1000):
		sim.advance(0.1,150)
		if sim.frontier.wood>0: break
	t.equal(sim.frontier.wood,node.wood,"delivery banks exact timber amount")
	t.equal(sim.world.crystals,3+node.crystals,"embedded crystal enters shared reserve only on delivery")
	settle(sim,200)
	t.equal(sim.frontier.wood,node.wood,"completed work cannot duplicate cargo")

func test_hit_worker_drops_cargo_and_another_worker_recovers_it(t) -> void:
	var sim = Sim.new({"first_raid":10000.0})
	var node = tree_in(sim)
	for i in range(2):
		sim.world.people[i].role="engineer"
		sim.world.people[i].x=node.x-22
	sim.advance(0.1,node.x)
	sim.interact(node.x)
	for tick in range(100):
		sim.advance(0.1,150)
		if node.collected: break
	var carrier: int = node.get("worker") if node.get("worker")!=null else -1
	t.truth(carrier>=0,"one worker owns completed cargo")
	if carrier<0: return
	sim.world.hit_person(carrier)
	settle(sim,1000)
	t.equal(sim.world.people[carrier].role,"wanderer","hit worker loses occupation")
	t.equal(sim.frontier.wood,node.wood,"other worker recovers dropped load exactly once")
	t.equal(node.get("delivered"),true,"recovered job reaches completed state")

func test_raised_salvage_is_reached_by_worker_ladder_before_harvest(t) -> void:
	var sim = Sim.new({"first_raid":10000.0})
	var node
	for candidate in sim.frontier.nodes:
		if candidate.y==366: node=candidate; break
	var worker = sim.world.people[0]
	worker.role="engineer"
	worker.x=node.x-22
	sim.advance(0.1,node.x,node.y)
	sim.interact(node.x)
	settle(sim,5)
	t.equal(node.remaining_work,75,"worker does not harvest raised cache while standing below")
	t.truth(worker.get("y",430)<430,"worker starts climbing visible access ladder")
	settle(sim,90)
	t.truth(node.collected,"worker reaches cache height and completes work")

func test_outpost_needs_cleared_site_payment_and_engineer_then_shortens_delivery(t) -> void:
	var sim = Sim.new({"first_raid":10000.0})
	var node = tree_in(sim)
	sim.advance(0.1,node.x)
	var region = sim.frontier.regions[node.region]
	var at: float = region.x+region.width*0.5
	t.equal(sim.context(at).get("id"),"mark","uncleared forest offers work, not a free outpost")
	var worker=sim.world.people[0]
	worker.role="engineer"
	worker.x=node.x-22
	sim.interact(node.x)
	for tick in range(1600):
		sim.advance(0.1,150)
		if node.get("delivered"): break
	# The cleared resource position becomes this region's first build site.
	t.equal(sim.context(node.x).id,"outpost","delivered clearing unlocks an expansion site")
	var scrap: int=sim.world.scrap
	t.truth(sim.interact(node.x),"player pays for expansion in the world")
	t.equal(sim.world.scrap,scrap-3,"outpost order pays salvage once")
	t.equal(sim.interact(node.x),false,"pending construction cannot be double paid")
	t.equal(region.get("outpost_built",false),false,"payment does not instantly finish construction")
	settle(sim,1600)
	t.equal(region.get("outpost_built",false),true,"engineer physically builds new frontier depot")
	t.truth(absf(sim.workforce.delivery_point(node.x)-node.x)<1,"built outpost provides a nearby delivery point")
	var next_job
	for candidate in sim.frontier.nodes:
		if candidate.region==node.region and candidate!=node and not candidate.collected:
			next_job=candidate
			break
	sim.advance(0.1,next_job.x,next_job.y)
	sim.interact(next_job.x)
	for tick in range(2200):
		sim.advance(0.1,150)
		if next_job.delivered: break
	t.truth(next_job.delivered,"next harvest reaches completed delivery")
	t.truth(absf(worker.x-node.x)<20,"next load is actually banked at the outpost instead of walking back to town")

func test_work_duration_is_tunable_and_invalid_time_cannot_finish_a_job(t) -> void:
	var sim=Sim.new({"first_raid":10000.0,"economy":{"work_seconds":2.0}})
	var node=tree_in(sim)
	sim.world.people[0].role="engineer"
	sim.world.people[0].x=node.x-22
	sim.advance(0.1,node.x)
	sim.interact(node.x)
	t.equal(node.advance_work(NAN,2),false,"invalid duration cannot advance resident work")
	settle(sim,10)
	t.equal(node.collected,false,"configured job still needs its complete work duration")
	settle(sim,12)
	t.truth(node.collected,"configured work duration changes real harvesting time")

func test_ground_raider_cannot_hit_a_worker_on_an_elevated_site(t) -> void:
	var sim=Sim.new({"first_raid":10000.0})
	sim.world.people[0].role="engineer"
	sim.world.people[0].x=1580
	sim.world.people[0]["y"]=366.0
	sim.begin_raid()
	sim.advance(0.1,-1000)
	# Simulate a telegraph selected before the worker climbed out of reach.
	var raider=sim.raiders[0]
	raider.target={"kind":"person","x":1580.0,"index":0}
	raider.windup=0.1
	sim.advance(0.1,-1000)
	t.equal(sim.world.people[0].role,"engineer","vertical distance prevents a ground hit through the platform")
