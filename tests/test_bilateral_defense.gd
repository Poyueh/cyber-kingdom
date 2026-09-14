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

func test_two_wall_investments_and_construction_are_independent(t):
	var sim=camp()
	var left=sim.context(-1100)
	t.equal(left.id,"wall_left","left edge offers its own visible construction")
	if left.id!="wall_left":return
	sim.interact(-1100)
	sim.interact(1100)
	t.equal(sim.context(-1100).paid,1,"left payment stays at left")
	t.equal(sim.context(1100).paid,1,"right has a separate payment")
	sim.interact(-1100);sim.interact(-1100)
	t.truth(sim.world.walls.wall_left.pending and not sim.world.wall.pending,"only completed left slots schedule construction")
	add_person(sim,"engineer",-1088)
	for i in range(200):sim.advance(1.0/60,30)
	t.equal(sim.world.walls.wall_left.hp,40,"resident builds the paid left wall")
	t.equal(sim.world.wall.hp,0,"left work cannot build the other wall")
	t.equal(sim.context(1100).paid,1,"construction leaves opposite payment untouched")
	sim.world.walls.wall_left.hp=0
	sim.interact(-1100);sim.interact(-1100)
	for i in range(200):sim.advance(1.0/60,30)
	t.equal(sim.world.walls.wall_left.level,1,"repair preserves left wall tier")
	t.equal(sim.world.walls.wall_left.hp,40,"resident restores destroyed left wall")

func test_night_attackers_arrive_from_both_sides(t):
	var sim=camp()
	add_person(sim,"citizen",30)
	sim.clock.remaining=0.01
	sim.advance(0.02,30)
	for i in range(310):sim.advance(1.0/60,30)
	t.truth(sim.raiders.any(func(r):return r.x<0),"night includes attackers from the left")
	t.truth(sim.raiders.any(func(r):return r.x>1100),"night still includes right attackers")

func test_wall_blocks_close_attack_against_knight(t):
	var sim=camp()
	sim.world.wall.merge({"level":1,"hp":40},true)
	var enemy=sim._spawn_raider()
	enemy.x=1120.0
	sim.raiders.append(enemy)
	var hp: int=sim.hero.hp
	sim.advance(0.02,1090)
	sim.advance(0.61,1090)
	t.equal(sim.hero.hp,hp,"enemy cannot reach a knight through intact wall")
	t.equal(sim.world.wall.hp,20,"intervening wall receives the attack")

func test_defenders_split_posts_and_keep_their_assignments(t):
	var sim=camp()
	if not sim.world.sites.has("wall_left"):
		t.truth(false,"campaign must provide a left defense post")
		return
	sim.world.wall.merge({"level":1,"hp":40},true)
	sim.world.walls.wall_left.merge({"level":1,"hp":40},true)
	var first=add_person(sim,"guard",710)
	var second=add_person(sim,"guard",710)
	for i in range(2000):sim.advance(1.0/60,30)
	t.truth(first.x>500 and second.x< -500,"two guards autonomously cover separate sides")
	var first_post: float=first.x
	var second_post: float=second.x
	for i in range(60):sim.advance(1.0/60,30)
	t.truth(first.x>500 and absf(first.x-first_post)<80,"right guard patrol stays on assigned side")
	t.truth(second.x< -500 and absf(second.x-second_post)<80,"left patrol stays on assigned side")
	t.truth(second.direction in [-1.0,1.0],"patrolling guard faces its current step")

func test_newly_completed_wall_intercepts_a_queued_strike(t):
	var sim=camp()
	if not sim.world.sites.has("wall_left"):return
	var worker=add_person(sim,"citizen",-1095)
	var enemy=sim._spawn_raider()
	enemy.x=-1106.0
	enemy["side"]=-1
	sim.raiders.append(enemy)
	sim.advance(0.02,30)
	t.truth(enemy.windup>0,"enemy begins a real strike against the exposed resident")
	# The enemy was already preparing to hit the exposed resident.
	sim.world.walls.wall_left.merge({"level":1,"hp":40},true)
	sim.advance(0.61,30)
	t.equal(worker.role,"citizen","a wall completed during windup protects the resident")
	t.equal(sim.world.walls.wall_left.hp,20,"queued swing lands on newly completed wall")

func test_pressure_preview_matches_spawned_sides_and_clears_at_dawn(t):
	var sim=camp()
	if not sim.has_method("raid_pressure"):return
	sim.clock.remaining=29
	t.equal(sim.raid_pressure(),{"left":1,"right":2},"first dusk previews the actual three attackers")
	add_person(sim,"citizen",30)
	sim.clock.remaining=0.01
	sim.advance(0.02,30)
	t.equal(sim.raid_pressure(),{"left":1,"right":2},"spawn moves an attacker from pending to active without double count")
	for enemy in sim.raiders:enemy.fighter.hp=0
	sim.advance(0.02,30)
	t.equal(sim.raid_pressure(),{"left":1,"right":1},"killed attacker is removed from directional pressure")
	sim.raiders.clear()
	sim._spawn_remaining=0
	sim.clock.remaining=0.01
	sim.advance(0.02,30)
	t.equal(sim.raid_pressure(),{"left":0,"right":0},"dawn clears both warning badges")

func test_generated_resources_leave_space_for_both_defense_sites(t):
	for seed_value in [1,7,42]:
		var sim=Campaign.new({"seed":seed_value})
		t.truth(sim.frontier.nodes.all(func(n):return absf(n.x-sim.world.sites.wall_left)>120),"left wall does not overlap random trees or treasure")

func test_legacy_encounter_left_retreat_does_not_create_false_loot(t):
	# Campaign now attacks the core; the older standalone encounter retains withdrawal.
	var sim=load("res://application/settlement_session.gd").new({"first_raid":1000.0,"scrap":0})
	var enemy=sim._spawn_raider()
	enemy.x=-1580
	enemy["side"]=-1
	enemy["exit_x"]=-1650.0
	sim.raiders.append(enemy)
	for i in range(100):sim.advance(0.1,30)
	t.truth(enemy.get("escaped",false),"legacy left attacker can retreat through its own exit")
	t.equal(sim.raiders.size(),0,"retreat completes in the legacy encounter")
	t.equal(sim.world.scrap,0,"departure does not create scrap")
	t.equal(sim.loot.size(),0,"departure does not leave false kill rewards")

func test_kingdom_milestone_requires_both_defenses(t):
	var sim=camp()
	sim.frontier.city_level=3
	sim.clock.survived=3
	for i in range(3):add_person(sim,"citizen",30+i*20)
	sim.world.wall.merge({"level":2,"hp":80},true)
	t.truth(not sim.kingdom_established(),"one upgraded side cannot complete bilateral defense milestone")
	sim.world.walls.wall_left.merge({"level":2,"hp":80},true)
	t.truth(sim.kingdom_established(),"both upgraded intact sides satisfy defense requirement")
