extends RefCounted
const Session=preload("res://application/campaign_session.gd")
func test_expedition_advice_uses_unlocks_and_preserves_hidden_rifts(t):
 var path="res://application/expedition_guide.gd"
 t.truth(ResourceLoader.exists(path),"expedition guidance exists")
 if not ResourceLoader.exists(path):return
 var guide=load(path)
 var sim=Session.new()
 t.equal(guide.next(sim,30),{},"opening guide retains the first day")
 sim.clock.survived=1
 sim.frontier.city_level=1
 t.equal(guide.next(sim,30).kind,"upgrade","surviving a night still requires camp level two")
 sim.frontier.city_level=2
 t.equal(guide.next(sim,30).kind,"recruit","expedition requires a real engineer")
 sim.world.people[0].role="engineer"
 var advice=guide.next(sim,30)
 t.equal(advice.kind,"explore","unseen rift receives general exploration advice")
 t.truth(sim.mission.rifts.all(func(r):return not r.discovered),"guidance does not reveal rifts")
 var rift: Dictionary=sim.mission.rifts[0]
 rift.discovered=true
 t.equal(guide.next(sim,rift.x).key,"rift:0","known rift can be funded")
 t.equal(sim.pouch.amount,12,"advice never pays")

func test_paid_expedition_reports_worker_combat_and_sealing_state(t):
 var guide=load("res://application/expedition_guide.gd")
 var sim=Session.new()
 sim.frontier.city_level=2
 sim.clock.survived=1
 var r: Dictionary=sim.mission.rifts[0]
 r.discovered=true;r.ordered=true
 var worker: Dictionary=sim.world.people[0]
 worker.role="engineer"
 var cargo=sim.frontier.nodes[0]
 cargo.worker=0;cargo.marked=true;cargo.collected=true;cargo.carried=true
 t.equal(guide.next(sim,r.x).kind,"delivery","unassigned engineer finishes existing cargo before departure")
 cargo.carried=false
 t.equal(guide.next(sim,r.x).kind,"escort","free engineer is not falsely described as hauling cargo")
 r.worker=0
 worker.x=r.x+500
 t.equal(guide.next(sim,r.x).kind,"escort","follow the actual travelling worker")
 worker.x=r.x-r.side*28
 t.equal(guide.next(sim,r.x+200).kind,"join","knight must return to sealing range")
 t.equal(guide.next(sim,r.x,300).kind,"join","knight airborne too high cannot be told sealing is active")
 t.equal(guide.next(sim,r.x).kind,"fight","unspawned wardens are not described as safe sealing")
 r.wardens_spawned=true
 r.progress=2
 t.equal(guide.next(sim,r.x).kind,"seal","clear area and both participants allow sealing")
 t.equal(guide.next(sim,r.x).seal_progress,0.25,"progress reads actual accumulated work")
 var enemy=sim._spawn_raider()
 enemy.x=r.x+50
 sim.raiders.append(enemy)
 t.equal(guide.next(sim,r.x).kind,"fight","living enemy blocks sealing")
 enemy.fighter.hp=0
 t.equal(guide.next(sim,r.x).kind,"seal","defeated enemy does not block advice")
 worker.role="wanderer"
 t.equal(guide.next(sim,r.x).kind,"recruit","lost worker prompts replacement, never another payment")
 t.truth(r.ordered and r.progress==2 and sim.pouch.amount==12,"advice preserves paid order and partial seal")
 r.sealed=true
 sim.mission.rifts[1].sealed=true
 enemy.fighter.hp=enemy.fighter.stats.max_hp
 t.equal(guide.next(sim,r.x).kind,"clear_enemies","two seals still require clearing surviving enemies")
 sim.mission.resolve(false,false)
 t.equal(guide.next(sim,r.x),{},"defeat hides expedition advice")

func test_assigned_expedition_takes_priority_over_a_second_waiting_order(t):
 var guide=load("res://application/expedition_guide.gd")
 var sim=Session.new()
 for r in sim.mission.rifts:r.discovered=true;r.ordered=true
 sim.world.people[0].role="engineer"
 sim.world.people[0].x=100
 sim.mission.rifts[1].worker=0
 var advice=guide.next(sim,sim.mission.rifts[0].x)
 t.equal(advice.kind,"escort","guide follows active worker rather than waiting forever at unassigned gate")
 t.equal(advice.x,100.0,"escort points at worker position")

func test_recovery_after_skipping_camp_or_losing_worker_with_empty_pouch(t):
 var guide=load("res://application/expedition_guide.gd")
 var sim=Session.new()
 sim.clock.survived=1
 t.equal(guide.next(sim,30).key,"hall","late first construction still targets real camp interaction")
 sim.frontier.city_level=2
 var r: Dictionary=sim.mission.rifts[0]
 r.discovered=true;r.ordered=true
 sim.pouch.amount=0
 t.truth(guide.next(sim,r.x).kind in ["explore","chest","collect","trade"],"lost worker with empty pouch first seeks available funding")
