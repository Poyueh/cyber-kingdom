extends RefCounted
const Campaign=preload("res://application/campaign_session.gd")
func ready_campaign(t, config: Dictionary = {}):
	var sim=Campaign.new(config)
	t.truth(sim.get("mission")!=null,"campaign has a real core and objective state")
	return sim if sim.get("mission")!=null else null

func test_core_breach_loses_without_killing_knight_and_stops_simulation(t):
	var sim=ready_campaign(t,{"core_max_hp":20})
	if sim==null:return
	sim.world.people.clear()
	var enemy=sim._spawn_raider()
	enemy.x=sim.world.sites.hall+20
	sim.raiders.append(enemy)
	sim.advance(0.02,5000)
	sim.advance(0.61,5000)
	t.equal(sim.mission.core_hp,0,"a real siege attack destroys exposed core")
	t.truth(sim.hero.is_alive(),"core defeat is distinct from knight death")
	t.equal(sim.mission.outcome,"defeat","breach ends the run")
	t.equal(sim.mission.defeat_reason,"core","loss identifies the destroyed core")
	var remaining: float=sim.clock.remaining
	var wallet: int=sim.pouch.amount
	var enemy_x: float=enemy.x
	sim.advance(30,30)
	t.equal(sim.clock.remaining,remaining,"calendar freezes after breach")
	t.equal(enemy.x,enemy_x,"attackers freeze after breach")
	t.truth(not sim.interact(30),"cannot buy a new camp after defeat")
	t.truth(not sim.throw_crystal(30,430,1),"cannot throw currency after defeat")
	t.equal(sim.pouch.amount,wallet,"post-defeat commands preserve wallet")

func test_intact_wall_protects_core_then_breach_exposes_it(t):
	var sim=ready_campaign(t)
	if sim==null:return
	sim.world.people.clear()
	sim.world.wall.merge({"level":1,"hp":40},true)
	var enemy=sim._spawn_raider()
	enemy.x=1120
	sim.raiders.append(enemy)
	var hp: int=sim.mission.core_hp
	sim.advance(0.02,5000);sim.advance(0.61,5000)
	t.equal(sim.world.wall.hp,20,"invader first attacks the intervening wall")
	t.equal(sim.mission.core_hp,hp,"core is not hit through its defense")
	sim.world.wall.hp=0
	enemy.x=sim.world.sites.hall+20
	enemy.cooldown=0
	sim.advance(0.02,5000);sim.advance(0.61,5000)
	t.equal(sim.mission.core_hp,hp-20,"unprotected core receives actual siege damage")

func test_core_charge_uses_slots_and_cannot_exceed_capacity(t):
	var sim=ready_campaign(t)
	if sim==null:return
	sim.frontier.city_level=1
	sim.world.people.clear()
	sim.mission.core_hp-=20
	var before: int=sim.pouch.amount
	t.equal(sim.context(30).id,"core_charge","damaged core offers emergency energy recharge")
	sim.interact(30)
	t.equal(sim.mission.core_hp,sim.mission.core_max_hp-20,"partial payment does not refill core")
	sim.interact(30)
	t.equal(sim.pouch.amount,before-2,"core refill spends two crystals")
	t.equal(sim.mission.core_hp,sim.mission.core_max_hp,"refill clamps to actual core capacity")
	t.equal(sim.context(30).id,"hall","healthy core returns to normal city upgrade")

func test_knight_death_and_city_milestone_are_not_victory(t):
	var sim=ready_campaign(t)
	if sim==null:return
	sim.frontier.city_level=3
	sim.clock.survived=3
	for w in sim.world.walls.values():w.merge({"level":2,"hp":80},true)
	for i in range(3):sim.world.people.append({"role":"citizen","x":30.0,"hurt":0.0,"cooldown":0.0,"region":-1})
	sim.advance(0.02,30)
	t.equal(sim.mission.outcome,"active","building a city alone cannot complete the expedition")
	sim.hero.hp=0
	sim.advance(0.02,30)
	t.equal(sim.mission.outcome,"defeat","knight death also ends run")
	t.equal(sim.mission.defeat_reason,"knight","knight defeat has a distinct cause")

func expedition(t):
	var sim=ready_campaign(t,{"rift_seal_seconds":1.0})
	if sim==null:return null
	t.equal(sim.mission.rifts.size(),2,"each island has two discoverable enemy sources")
	return sim if sim.mission.rifts.size()==2 else null

func engineer(sim, x: float):
	var person={"role":"engineer","x":x,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1}
	sim.world.people.append(person)
	return person

func order_rift(sim, index: int):
	var rift: Dictionary=sim.mission.rifts[index]
	sim.advance(0.01,rift.x)
	for i in range(4):sim.interact(rift.x)

func clear_wardens_with_sword(sim, at: float):
	# A strong test sword shortens this integration fixture, not production tuning.
	sim.hero.stats.damage=200
	for enemy in sim.raiders.duplicate():
		sim.hero.attack_remaining=0
		sim.hero.cooldown_remaining=0
		sim.hero.facing=1
		sim.hero.start_attack()
		sim.hero.advance(sim.hero.stats.attack_duration*0.5)
		sim.strike_from(enemy.x-30,430)
	sim.advance(0.01,at)

func test_rift_requires_exploration_city_and_an_engineer(t):
	var sim=expedition(t)
	if sim==null:return
	var rift: Dictionary=sim.mission.rifts[0]
	t.truth(not rift.discovered,"rift starts beyond explored land")
	t.equal(sim.context(rift.x).id,"","unseen rift cannot receive remote investment")
	sim.advance(0.01,rift.x)
	t.truth(rift.discovered,"approaching discovers the rift")
	t.truth(not sim.context(rift.x).enabled,"campfire alone cannot launch expedition")
	sim.frontier.city_level=2
	sim.clock.survived=1
	t.truth(not sim.context(rift.x).enabled,"expedition needs an actual recruited engineer")
	engineer(sim,30)
	var before: int=sim.pouch.amount
	for i in range(4):sim.interact(rift.x)
	t.truth(rift.ordered,"four local crystal slots schedule the expedition")
	t.equal(sim.pouch.amount,before-4,"rift order has a real resource cost")
	t.truth(not sim.interact(rift.x),"ordered rift cannot charge duplicate payment")

func test_engineer_travels_and_waits_for_knight_before_guardians(t):
	var sim=expedition(t)
	if sim==null:return
	sim.frontier.city_level=2
	sim.clock.survived=1
	sim.world.people.clear()
	var rift: Dictionary=sim.mission.rifts[0]
	var worker=engineer(sim,rift.x+220)
	order_rift(sim,0)
	var start: float=worker.x
	for i in range(180):sim.advance(1.0/60,30)
	t.truth(worker.x<start-100,"paid expedition makes the resident walk toward the site")
	t.truth(not rift.wardens_spawned,"guardians wait until knight and engineer both arrive")
	t.equal(rift.progress,0.0,"worker cannot seal remotely without knight protection")
	for i in range(150):sim.advance(1.0/60,rift.x)
	t.truth(rift.wardens_spawned,"meeting at rift triggers an actual defending force")
	t.equal(sim.raiders.size(),2,"each expedition summons its two wardens once")
	t.equal(rift.progress,0.0,"nearby live wardens block sealing work")

func test_fighting_unlocks_sealing_and_closed_side_stops_night_spawns(t):
	var sim=expedition(t)
	if sim==null:return
	sim.frontier.city_level=2
	sim.clock.survived=1
	sim.world.people.clear()
	var rift: Dictionary=sim.mission.rifts[0]
	engineer(sim,rift.x+28)
	order_rift(sim,0)
	sim.advance(0.02,rift.x)
	t.truth(sim.raiders.size()==2,"defenders are present before seal can progress")
	clear_wardens_with_sword(sim,rift.x)
	for i in range(65):sim.advance(1.0/60,rift.x)
	t.truth(rift.sealed,"engineer seals the rift after knight defeats its guardians")
	t.equal(sim.mission.outcome,"active","one sealed source is not a full victory")
	sim.clock.remaining=29
	t.equal(sim.raid_pressure().left,0,"closed left source disappears from night preview")
	sim.clock.remaining=0.01
	for i in range(320):sim.advance(1.0/60,30)
	t.truth(sim.raiders.all(func(r):return r.get("side",1)>0),"later night actually spawns only from the open source")

func test_both_seals_and_cleared_enemies_finish_run_once(t):
	var sim=expedition(t)
	if sim==null:return
	sim.frontier.city_level=2
	sim.clock.survived=1
	sim.world.people.clear()
	var worker=engineer(sim,30)
	for index in range(2):
		var rift: Dictionary=sim.mission.rifts[index]
		worker.x=rift.x-rift.side*28
		order_rift(sim,index)
		sim.advance(0.02,rift.x)
		clear_wardens_with_sword(sim,rift.x)
		for i in range(65):sim.advance(1.0/60,rift.x)
	t.equal(sim.mission.outcome,"victory","both sealed sources and defeated wardens win the run")
	var time: float=sim.clock.remaining
	var wallet: int=sim.pouch.amount
	sim.advance(300,30)
	t.equal(sim.clock.remaining,time,"winning run stops the calendar")
	t.equal(sim.pouch.amount,wallet,"winning run cannot accrue automatic rewards")
	t.truth(not sim.interact(30),"victory blocks further investment")

func test_lost_engineer_is_replaced_without_reset_or_duplicate_wardens(t):
	var sim=expedition(t)
	if sim==null:return
	sim.frontier.city_level=2
	sim.clock.survived=1
	sim.world.people.clear()
	var rift: Dictionary=sim.mission.rifts[0]
	var worker=engineer(sim,rift.x+28)
	order_rift(sim,0)
	sim.advance(0.02,rift.x)
	clear_wardens_with_sword(sim,rift.x)
	sim.advance(0.3,rift.x)
	var progress: float=rift.progress
	worker.role="wanderer"
	sim.advance(0.1,rift.x)
	t.equal(rift.worker,-1,"lost engineer releases paid expedition")
	t.equal(rift.progress,progress,"lost worker preserves completed seal work")
	t.truth(not sim.interact(rift.x,"rift:0"),"replacement does not need another payment")
	var replacement=engineer(sim,rift.x+28)
	sim.advance(0.1,rift.x)
	t.equal(rift.worker,sim.world.people.find(replacement),"new engineer claims abandoned expedition")
	t.equal(sim.raiders.size(),0,"replacement cannot spawn duplicate guardians")
	for tick in range(50):sim.advance(1.0/60,rift.x)
	t.truth(rift.sealed,"replacement finishes the preserved work")

func test_expedition_waits_for_carried_harvest_to_be_delivered(t):
	var sim=expedition(t)
	if sim==null:return
	sim.frontier.city_level=2
	sim.clock.survived=1
	sim.world.people.clear()
	var worker=engineer(sim,sim.world.sites.hall+20)
	var cargo=sim.frontier.nodes.filter(func(n):return n.kind=="tree")[0]
	cargo.collected=true
	cargo.carried=true
	cargo.worker=0
	cargo.marked=true
	var wood: int=sim.frontier.wood
	order_rift(sim,0)
	sim.advance(0.02,30)
	t.equal(sim.mission.rifts[0].worker,-1,"engineer finishes carrying before departing")
	t.truth(cargo.carried and cargo.worker==0,"expedition never discards carried resources")
	for tick in range(60):sim.advance(1.0/60,30)
	t.truth(cargo.delivered and sim.frontier.wood==wood+cargo.wood,"harvest reaches storage exactly once")
	t.equal(sim.mission.rifts[0].worker,0,"engineer then takes the paid expedition")

func test_sealed_sources_still_require_remaining_enemies_and_defeat_wins_ties(t):
	var sim=expedition(t)
	if sim==null:return
	sim.world.people.clear()
	for rift in sim.mission.rifts:rift.sealed=true
	var enemy=sim._spawn_raider()
	enemy.x=sim.world.sites.hall+20
	sim.raiders.append(enemy)
	sim.advance(0.02,5000)
	t.equal(sim.mission.outcome,"active","sealed gates do not remove surviving attackers")
	sim.mission.core_hp=1
	sim.advance(0.61,5000)
	t.equal(sim.mission.outcome,"defeat","remaining attacker can still destroy the core")
	var tied=expedition(t)
	if tied==null:return
	for rift in tied.mission.rifts:rift.sealed=true
	tied.hero.hp=0
	tied.advance(0.02,30)
	t.equal(tied.mission.outcome,"defeat","knight death takes priority over simultaneous completion")

func test_warden_stats_are_editable_through_campaign_rules(t):
	var sim=ready_campaign(t,{"warden_health":130,"warden_damage":24})
	if sim==null:return
	sim.frontier.city_level=2
	sim.clock.survived=1
	sim.world.people.clear()
	var rift: Dictionary=sim.mission.rifts[0]
	engineer(sim,rift.x+28)
	order_rift(sim,0)
	sim.advance(0.02,rift.x)
	t.truth(sim.raiders.all(func(r):return r.fighter.hp==130 and r.fighter.stats.damage==24),"rift guards use supplied balance tuning")
