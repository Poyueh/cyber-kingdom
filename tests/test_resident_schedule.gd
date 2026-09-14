extends RefCounted
const Campaign=preload("res://application/campaign_session.gd")

func person(sim, role: String, x: float) -> Dictionary:
	var value={"role":role,"x":x,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1}
	sim.world.people.append(value)
	return value

func settled() -> RefCounted:
	var sim=Campaign.new({"day_seconds":180.0,"night_seconds":60.0})
	sim.world.people.clear()
	sim.frontier.city_level=1
	return sim

func test_distant_worker_leaves_before_sunset_and_preserves_work(t) -> void:
	var sim=settled()
	var job=sim.frontier.nodes.filter(func(node): return node.kind=="tree")[0]
	sim.frontier.regions[job.region].discovered=true
	job.marked=true
	job.worker=0
	var worker=person(sim,"engineer",job.x-22)
	sim.clock.remaining=20.0
	var before: float=worker.x
	var work: float=job.remaining_work
	sim.advance(0.5,30)
	t.truth(absf(worker.x-30)<absf(before-30),"distant worker starts home before dark")
	t.equal(job.remaining_work,work,"returning worker stops harvesting without discarding progress")
	t.equal(job.worker,0,"returning worker keeps the claim for dawn")
	t.equal(worker.role,"engineer","sunset never removes a profession")

func test_night_pauses_farming_and_dawn_resumes_work(t) -> void:
	var sim=settled()
	var farmer=person(sim,"farmer",sim.world.sites.farm)
	sim.frontier.farm_active=true
	sim.frontier.farm_progress=5.0
	sim.clock.is_night=true
	sim.clock.remaining=60
	var before: float=farmer.x
	sim.advance(1.0,30)
	t.truth(absf(farmer.x-30)<absf(before-30),"farmer returns to camp instead of staying at field")
	t.equal(sim.frontier.farm_progress,5.0,"unattended farm cannot produce during shelter")
	sim.clock.is_night=false
	sim.clock.remaining=180
	farmer.x=sim.world.sites.farm
	sim.advance(1.0,30)
	t.truth(sim.frontier.farm_progress>5.0,"farmer resumes production at dawn")

func test_hunter_hunts_by_day_and_defends_at_night(t) -> void:
	var sim=settled()
	var prey: Dictionary=sim.frontier.animals[0]
	sim.frontier.regions[prey.region].discovered=true
	var hunter=person(sim,"hunter",prey.x)
	var before_crystals: int=sim.pouch.ground_total()
	sim.advance(0.1,30)
	t.truth(not prey.alive and sim.pouch.ground_total()==before_crystals+2,"hunter leaves dragon crystals at prey during daytime")
	prey.alive=true
	hunter.cooldown=0.0
	sim.clock.is_night=true
	sim.clock.remaining=60
	var enemy=sim._spawn_raider()
	enemy.x=hunter.x+100
	sim.raiders.append(enemy)
	var before_hp: int=enemy.fighter.hp
	sim.advance(0.1,30)
	t.truth(enemy.fighter.hp<before_hp,"hunter fires at raider while retreating at night")
	t.truth(prey.alive,"hunter stops chasing prey during night defense")
	var after_shot: int=enemy.fighter.hp
	sim.advance(0.1,30)
	t.equal(enemy.fighter.hp,after_shot,"hunter cannot shoot every frame")

func test_carried_resource_returns_with_worker_then_deposits_at_dawn(t) -> void:
	var sim=settled()
	var job=sim.frontier.nodes.filter(func(node): return node.kind=="tree")[0]
	sim.frontier.regions[job.region].discovered=true
	job.marked=true
	job.remaining_work=0
	sim.frontier.collect(job)
	job.carried=true
	job.worker=0
	var worker=person(sim,"engineer",job.x)
	sim.clock.is_night=true
	sim.clock.remaining=120
	var wood: int=sim.frontier.wood
	for tick in range(500):sim.advance(0.1,30)
	t.truth(absf(worker.x-30)<90,"hauling engineer reaches shelter")
	t.truth(job.carried and not job.delivered,"cargo is preserved through shelter")
	t.equal(sim.frontier.wood,wood,"sheltering does not duplicate cargo")
	sim.clock.is_night=false
	sim.clock.remaining=180
	for tick in range(20):sim.advance(0.1,30)
	t.truth(job.delivered,"worker delivers the same cargo on resuming work")

func test_unrecruited_wanderer_does_not_join_shelter_and_farmer_stops_at_home(t) -> void:
	var sim=settled()
	var wanderer=person(sim,"wanderer",-900)
	var farmer=person(sim,"farmer",sim.world.sites.farm)
	sim.clock.is_night=true
	sim.clock.remaining=60
	for tick in range(120):sim.advance(0.1,30)
	t.truth(absf(wanderer.x+900)<100,"unrecruited wanderer remains near their discovery site")
	var home: float=farmer.x
	for tick in range(30):sim.advance(0.1,30)
	t.equal(farmer.x,home,"sheltered farmer does not oscillate towards farm every frame")
