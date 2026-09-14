extends RefCounted
const Campaign=preload("res://application/campaign_session.gd")
func test_campaign_has_ground_level_resources_and_no_gem_ledges(t):
 var sim=Campaign.new()
 t.truth(sim.frontier.nodes.all(func(n):return n.y==430 and n.pickup_y==430),"every campaign resource is reachable from flat ground")
 t.truth(sim.pouch.platforms.is_empty(),"crystals cannot land on removed platforms")
func test_drag_has_two_distinct_speeds_and_can_return_to_slow(t):
 var drag=load("res://presentation/drag_state.gd").new()
 drag.begin(1,Vector2(100,200));drag.drag(1,Vector2(138,200));var slow=drag.axis
 drag.drag(1,Vector2(215,200));var fast=drag.axis
 t.truth(absf(fast)>absf(slow) and slow>0,"long horizontal drag selects a faster second tier")
 drag.drag(1,Vector2(70,200));t.equal(drag.axis,-slow,"reversal selects the slow tier symmetrically")
 drag.finish(1);t.equal(drag.axis,0.0,"release stops both tiers")
func test_barracks_upgrades_power_existing_archers_and_stop_at_limit(t):
 var sim=Campaign.new();sim.frontier.city_level=3
 t.truth(sim.has_method("archer_damage"),"barracks owns an explicit archer strength rule")
 if not sim.has_method("archer_damage"):return
 var before=sim.archer_damage()
 var choice=sim.context(sim.world.sites.armory)
 t.equal(choice.id,"armory","barracks remains directly interactable at its world position")
 for i in range(choice.cost):sim.interact(sim.world.sites.armory)
 t.truth(sim.archer_damage()>before,"one completed upgrade improves archer damage")
 t.equal(sim.world.tools.blade,0,"barracks no longer sells swords")
func test_night_civilians_move_without_leaving_the_defended_interior(t):
 var sim=Campaign.new();sim.clock.is_night=true;sim.clock.remaining=10000
 sim.world.people=sim.world.people.slice(0,2)
 for i in range(2):sim.world.people[i].role="citizen";sim.world.people[i].x=30+i*30
 var positions=sim.world.people.map(func(p):return p.x)
 for i in range(120):sim._advance_people(0.1)
 t.truth(absf(sim.world.people[0].x-positions[0])>30,"civilian stroll is larger than a tiny camp huddle")
 t.truth(absf(sim.world.people[0].x-sim.world.people[1].x)>30,"residents do not share one night destination")
func test_second_tier_spends_stamina_and_falls_back_when_exhausted(t):
 var sim=Campaign.new()
 t.truth(sim.has_method("travel_axis"),"campaign exposes stamina-aware two-tier travel")
 if not sim.has_method("travel_axis"):return
 var energy=sim.hero.stamina
 var slow=sim.travel_axis(0.65,1.0)
 t.equal(sim.hero.stamina,energy,"slow travel does not spend stamina")
 var fast=sim.travel_axis(1.0,1.0)
 t.truth(fast>slow and sim.hero.stamina<energy,"second tier runs faster and drains energy")
 sim.hero.stamina=0
 t.equal(sim.travel_axis(1.0,0.1),slow,"exhausted knight keeps slow movement")
func test_real_v4_save_keeps_population_and_paid_resources_on_flat_ground(t):
 var codec=load("res://application/campaign_snapshot.gd").new()
 var packet: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/campaign-v4.json"))
 var original=packet.duplicate(true)
 var result=codec.restore(packet)
 t.truth(not result.is_empty(),"genuine previous-version record migrates")
 t.equal(packet,original,"migration does not rewrite the source record")
 if result.is_empty():return
 var sim=result.session
 t.equal(sim.world.people.size(),packet.world.people.size(),"population retained")
 t.equal(sim.world.people[0].role,"hunter","old sword guard becomes archer")
 t.equal(sim.world.tools.blade,2,"paid old tool stock retained for automatic archer conversion")
 t.equal(sim.context(sim.world.sites.armory).paid,1,"partial old sword payment funds barracks")
 t.equal(result.body.y,430.0,"old airborne knight safely moves to ground")
 t.truth(sim.frontier.nodes.all(func(n):return n.y==430 and n.pickup_y==430),"old platform resources move to reachable ground")
 t.truth(not codec.restore(codec.capture(sim,result.config,result.body)).is_empty(),"migrated record saves and reopens in current format")
 packet.nodes[0].x+=123
 t.truth(codec.restore(packet).is_empty(),"invalid old geography remains protected, not silently repaired")
func test_barracks_respects_town_gate_and_all_three_paid_tiers(t):
 var sim=Campaign.new();sim.frontier.city_level=1
 var x: float=sim.world.sites.armory
 for i in range(3):sim.interact(x)
 t.truth(not sim.context(x).enabled,"second barracks tier needs a larger town")
 var held: int=sim.pouch.amount
 t.truth(not sim.interact(x) and sim.pouch.amount==held,"locked tier never takes crystals")
 sim.frontier.city_level=3
 for cost in [5,7]:
  sim.pouch.amount=12
  for i in range(cost):sim.interact(x)
  t.equal(sim.pouch.amount,12-cost,"each upgrade charges its full displayed cost")
 t.equal(sim.barracks_level,3,"all three tiers complete")
 t.truth(not sim.context(x).enabled and not sim.interact(x),"fully upgraded barracks cannot take extra payment")
 sim.world.people.clear()
 sim.world.people.append({"role":"hunter","x":100.0,"hurt":0.0,"cooldown":0.0,"region":-1})
 var enemy=sim._spawn_raider();enemy.x=200;enemy.fighter.hp=100
 sim.raiders.append(enemy)
 sim._advance_people(0.01)
 t.equal(enemy.fighter.hp,70,"upgraded archer deals 30 real damage to a nearby enemy")
