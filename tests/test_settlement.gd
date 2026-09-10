extends RefCounted
const World = preload("res://domain/settlement.gd")

func test_supplies_recruit_only_on_pickup_and_tools_are_not_duplicated(t) -> void:
	var world = World.new({"scrap": 10, "crystals": 3})
	t.truth(world.drop_supply(150), "one scrap creates physical supplies")
	t.equal(world.people[0].role, "wanderer", "throwing alone does not remotely recruit")
	t.equal(world.scrap, 9, "supply spends exactly one scrap")
	t.truth(world.collect_supply(0,0), "nearby wanderer picks up supplies")
	t.equal(world.people[0].role, "citizen", "pickup recruits the wanderer")
	t.equal(world.collect_supply(1,0), false, "one supply cannot recruit twice")
	t.truth(world.buy_tool("hammer"), "player stocks a hammer")
	t.equal(world.people[0].role, "citizen", "buying does not remotely assign a profession")
	world.people[0].x = world.sites.workshop
	t.truth(world.claim_tool(0,"hammer"), "arriving citizen takes available hammer")
	t.equal(world.people[0].role, "engineer", "hammer makes engineer")
	t.equal(world.tools.hammer, 0, "claimed tool leaves rack")
	t.equal(world.claim_tool(0,"hammer"), false, "employed person cannot consume another tool")

func test_paid_construction_needs_engineer_and_cannot_charge_twice(t) -> void:
	var world = World.new({"scrap":10})
	t.truth(world.order_wall(), "wall order reserves construction")
	t.equal(world.scrap,7,"wall costs three scrap")
	t.equal(world.wall.level,0,"paying does not instantly build")
	t.equal(world.order_wall(),false,"pending order cannot double charge")
	t.equal(world.work_wall(0,10.0),false,"wanderer cannot construct")
	world.people[0].role = "engineer"
	world.people[0].x = world.sites.wall
	t.truth(world.work_wall(0,3.0),"engineer at site completes work")
	t.equal(world.wall.level,1,"wall is built")
	t.truth(world.order_wall(),"built wall accepts an upgrade")
	world.work_wall(0,3.0)
	t.equal(world.wall.level,2,"upgrade changes level")
	t.equal(world.order_wall(),false,"max level cannot spend resources")

func test_only_a_real_unblocked_hit_demotes_a_resident(t) -> void:
	var world = World.new({"crystals":2})
	world.people[0].role = "guard"
	t.truth(world.power_refuge(),"crystal charges resident barrier")
	t.equal(world.hit_person(0),false,"barrier prevents status loss")
	t.equal(world.people[0].role,"guard","protected guard keeps profession")
	t.truth(world.hit_person(0),"unblocked hit lands")
	t.equal(world.people[0].role,"wanderer","hit person becomes wanderer")
	t.equal(world.hit_person(0),false,"wanderer is not repeatedly demoted")
	t.equal(world.tools.blade,0,"lost equipment is not duplicated on rack")

func test_people_walk_to_supplies_tools_and_build_without_direct_orders(t) -> void:
	var Sim = load("res://application/settlement_session.gd")
	var sim = Sim.new({"first_raid":1000.0})
	sim.interact(150)
	for tick in range(20):
		sim.advance(0.1,50)
	t.equal(sim.world.people[0].role,"citizen","wanderer independently collects nearby supplies")
	sim.interact(sim.world.sites.workshop)
	for tick in range(100):
		sim.advance(0.1,50)
	t.equal(sim.world.people[0].role,"engineer","citizen walks to stocked tool and equips it")
	sim.interact(sim.world.sites.wall)
	for tick in range(160):
		sim.advance(0.1,50)
	t.equal(sim.world.wall.level,1,"engineer walks to paid construction and builds")
	t.equal(sim.world.people[0].role,"engineer","elapsed time alone never removes residency")

func test_context_interaction_checks_distance_and_shared_crystal_reserve(t) -> void:
	var Sim = load("res://application/settlement_session.gd")
	var sim = Sim.new({"first_raid":1000.0,"crystals":1})
	t.equal(sim.interact(1700),false,"cannot pay a distant building")
	t.truth(sim.interact(sim.world.sites.forge),"nearby forge powers knight")
	t.equal(sim.hero.shield,20,"forge changes real combat shield")
	t.equal(sim.interact(sim.world.sites.beacon),false,"same crystal cannot power residents as well")
	t.equal(sim.world.barrier,0,"insufficient crystals cannot create protection")

func test_raiders_must_reach_and_hit_residents_not_just_start_a_wave(t) -> void:
	var Sim = load("res://application/settlement_session.gd")
	var sim = Sim.new({"first_raid":1000.0})
	sim.world.people[0].role = "citizen"
	sim.begin_raid()
	sim.advance(0.1,50)
	t.equal(sim.world.people[0].role,"citizen","wave start causes no remote injury")
	for tick in range(300):
		sim.advance(0.1,50)
	t.equal(sim.world.people[0].role,"wanderer","enemy reaching resident eventually lands a hit")

func test_countdown_reaches_first_wave_and_cannot_duplicate_an_active_wave(t) -> void:
	var Sim = load("res://application/settlement_session.gd")
	var sim = Sim.new({"first_raid":2.0})
	sim.world.people[0].role = "citizen"
	for tick in range(25):
		sim.advance(0.1,50)
	t.equal(sim.wave,1,"countdown reaches its deadline")
	t.equal(sim.begin_raid(),false,"ringing again cannot duplicate active attackers")

func test_attacked_worker_can_be_recruited_and_equipped_again(t) -> void:
	var Sim = load("res://application/settlement_session.gd")
	var sim = Sim.new({"first_raid":1000.0})
	sim.world.people[0].role = "engineer"
	sim.world.people[0].x = sim.world.sites.workshop
	sim.world.hit_person(0)
	t.truth(sim.interact(sim.world.people[0].x),"supplies can be offered to displaced worker")
	for tick in range(30): sim.advance(0.1,50)
	t.equal(sim.world.people[0].role,"citizen","displaced worker becomes resident again by collecting supplies")
	sim.interact(sim.world.sites.workshop)
	for tick in range(5): sim.advance(0.1,50)
	t.equal(sim.world.people[0].role,"engineer","new tool restores profession through normal pickup")

func test_guard_defends_and_salvage_requires_pickup_once(t) -> void:
	var Sim = load("res://application/settlement_session.gd")
	var sim = Sim.new({"first_raid":1000.0})
	sim.world.people[0].role = "guard"
	sim.world.people[0].x = 1035.0
	sim.world.wall.level = 1
	sim.world.wall.hp = 40
	sim.begin_raid()
	for tick in range(200): sim.advance(0.1,50)
	t.equal(sim.loot.size(),3,"autonomous guard can defeat the first three attackers")
	t.equal(sim.world.scrap,14,"defeated enemies do not credit distant player automatically")
	t.equal(sim.world.people[0].role,"guard","defender remains employed when not hit")
	var location: float = sim.loot[0].x
	sim.advance(0.1,location)
	t.truth(sim.world.scrap>14,"walking to salvage collects it")
	var collected: int = sim.world.scrap
	sim.advance(0.1,location)
	t.equal(sim.world.scrap,collected,"same salvage cannot be collected twice")

func test_destroyed_wall_can_be_repaired_without_exceeding_level_cap(t) -> void:
	var world = World.new()
	world.people[0].role = "engineer"
	world.people[0].x = world.sites.wall
	world.wall.level = 2
	world.wall.hp = 0
	t.truth(world.order_wall(),"destroyed upgraded wall accepts repair")
	t.equal(world.scrap,12,"repair uses repair price rather than upgrade price")
	world.work_wall(0,3.0)
	t.equal(world.wall.level,2,"repair preserves building tier")
	t.equal(world.wall.hp,80,"engineer restores full upgraded wall health")

func test_three_completed_waves_stop_and_escaped_enemies_drop_nothing(t) -> void:
	var Sim = load("res://application/settlement_session.gd")
	var sim = Sim.new({"first_raid":1000.0})
	for wave in range(3):
		t.truth(sim.begin_raid(),"next wave starts only after previous attackers leave")
		for tick in range(200): sim.advance(0.1,50)
	t.truth(sim.finished(),"three waves end the prototype even if everyone remains a wanderer")
	t.equal(sim.begin_raid(),false,"completed prototype cannot spawn a fourth wave")
	t.equal(sim.loot.size(),0,"escaped attackers do not create defeat loot")
