extends RefCounted
const Session=preload("res://application/campaign_session.gd")
func test_guidance_follows_paid_camp_and_real_resident_jobs(t):
 var path="res://application/campaign_guide.gd"
 t.truth(ResourceLoader.exists(path),"first-day guidance exists")
 if not ResourceLoader.exists(path):return
 var guide=load(path)
 var sim=Session.new()
 t.equal(guide.next(sim,30.0).kind,"camp","start at campfire")
 sim.interact(0);sim.interact(0)
 t.equal(guide.next(sim,30.0).kind,"recruit","built camp asks for a real resident")
 var person=sim.world.people[0]
 sim.interact(person.x)
 t.equal(guide.next(sim,person.x).kind,"tool","resident needs a hammer")
 sim.world.tools.hammer=1
 t.equal(guide.next(sim,person.x).action,"wait","stocked hammer waits for autonomous collection")
 sim.world.tools.hammer=0
 person.role="engineer"
 for region in sim.frontier.regions:region.discovered=true
 t.equal(guide.next(sim,person.x).kind,"harvest","engineer enables commissioning wood")

func test_guidance_does_not_reveal_loot_or_keep_spending_stocked_tools(t):
 var guide=load("res://application/campaign_guide.gd")
 var sim=Session.new()
 sim.pouch.amount=0
 var before=sim.frontier.layout_signature()
 var hint=guide.next(sim,30.0)
 t.equal(hint.kind,"explore","empty pouch does not locate hidden treasure")
 t.equal(sim.frontier.discovered_count(),0,"advice does not reveal regions")
 var cache=sim.frontier.nodes.filter(func(n):return n.kind=="cache")[0]
 sim.frontier.regions[cache.region].discovered=true
 hint=guide.next(sim,cache.x)
 t.equal(hint.kind,"chest","known chest can refill an empty pouch")
 t.equal(hint.key,"node:%d"%sim.frontier.nodes.find(cache),"guide uses actual chest identity")
 t.equal(sim.frontier.layout_signature(),before,"reading advice does not mutate resources")
 t.equal(sim.pouch.amount,0,"guide never grants or spends crystals")
 sim.pouch.amount=12
 sim.frontier.city_level=1
 sim.world.people[0].role="engineer"
 sim.world.people[1].role="citizen"
 sim.frontier.nodes.filter(func(n):return n.kind=="tree")[0].marked=true
 sim.world.tools.bow=1
 t.equal(guide.next(sim,30.0).action,"wait","hunter takes stocked bow without repeat buying")
 sim.world.tools.bow=0
 sim.world.tools.blade=1
 t.equal(guide.next(sim,30.0).action,"wait","existing guard weapon also prevents redundant bow purchase")
 sim.world.tools.blade=0
 sim.world.people[1].role="hunter"
 sim.world.tools.bow=0
 var wall_hint=guide.next(sim,30.0)
 t.equal(wall_hint.kind,"wall","workers and income lead into defense")
 sim.world.walls[wall_hint.key].pending=true
 t.truth(guide.next(sim,30.0).key!=wall_hint.key,"pending construction is not ordered twice")
 for wall in sim.world.walls.values():wall.level=1
 t.equal(guide.next(sim,30.0),{},"opening advice finishes after basic preparations")
 sim.clock.is_night=true
 t.equal(guide.next(sim,900.0).kind,"defend","night prioritizes returning to defense")
 sim.clock.survived=1
 t.equal(guide.next(sim,30.0),{},"first-day hints do not repeat every later day")
