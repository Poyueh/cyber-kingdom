extends RefCounted
const Campaign=preload("res://application/campaign_session.gd")

func test_invisible_sites_do_not_steal_exploration_targets(t) -> void:
	var sim=Campaign.new()
	var chest
	for node in sim.frontier.nodes:
		if node.kind=="cache" and node.y==430: chest=node;break
	sim.world.sites.heal=chest.x-20
	sim.advance(0.01,chest.x-20,430)
	t.equal(sim.context(chest.x-20).id,"chest","hidden pre-camp healer cannot mask reachable chest")
	t.truth(sim.interact(chest.x-20),"approaching chest opens it without pixel-perfect positioning")
	t.truth(chest.delivered,"the intended treasure is opened")

func test_actionable_target_wins_over_nearer_unavailable_target(t) -> void:
	var sim=Campaign.new()
	sim.frontier.city_level=1
	sim.world.sites.heal=200
	sim.advance(0.01,200,430)
	t.equal(sim.context(200).id,"recruit","full-health healer does not mask a nearby recruit")
	sim.hero.hp-=30
	sim.frontier.herbs=2
	t.equal(sim.context(200).id,"heal","available nearer healer becomes the selected action")

func test_targeted_payment_never_falls_back_to_another_person(t) -> void:
	var sim=Campaign.new()
	if not sim.has_method("context_for_key"):
		t.truth(false,"targeted interaction supports explicit target validation")
		return
	var key: String=sim.context(180).key
	var before: int=sim.pouch.amount
	sim.world.people[0].x=-500
	t.truth(not sim.call("interact",245,key),"lost target does not redirect money to another nearby person")
	t.equal(sim.pouch.amount,before,"invalid selected target does not charge")
	t.equal(sim.world.people[1].role,"wanderer","neighbor cannot receive the stale gesture")

func hold_controller(t):
	var path := "res://application/investment_hold.gd"
	if not ResourceLoader.exists(path):
		t.truth(false,"hold-to-invest controller exists")
		return null
	return load(path).new(0.5,0.28)

func test_holding_fills_one_project_and_stops_at_completion(t) -> void:
	var hold=hold_controller(t)
	if hold==null: return
	var sim=Campaign.new()
	t.truth(hold.step(0.01,true,true,sim,30),"press immediately invests the first crystal")
	t.equal(sim.context(30).paid,1,"initial press fills exactly one slot")
	for tick in range(4): hold.step(0.1,true,true,sim,30)
	t.equal(sim.frontier.city_level,0,"repeat waits for deliberate hold delay")
	for tick in range(20): hold.step(0.1,true,true,sim,30)
	t.equal(sim.frontier.city_level,1,"holding finishes the initial camp")
	t.equal(sim.pouch.amount,10,"long hold stops at project completion")
	# A newly enabled next upgrade must still require a fresh press.
	sim.frontier.wood=100;sim.frontier.food=100;sim.frontier.stone=100
	hold.step(2,true,true,sim,30)
	t.equal(sim.pouch.amount,10,"holding cannot start the next upgrade")
	hold.step(0.01,false,true,sim,30)
	hold.step(0.01,true,true,sim,30)
	t.equal(sim.context(30).paid,1,"release and press explicitly starts a new project")

func test_hold_cancels_on_leaving_and_cannot_resume_on_a_neighbor(t) -> void:
	var hold=hold_controller(t)
	if hold==null: return
	var sim=Campaign.new()
	hold.step(0.01,true,true,sim,30)
	hold.step(1,true,true,sim,180)
	t.equal(sim.pouch.amount,11,"leaving stops the held investment")
	t.equal(sim.world.people[0].role,"wanderer","moving onto a wanderer never redirects a held payment")
	hold.step(1,true,true,sim,30)
	t.equal(sim.frontier.city_level,0,"returning without release does not restart payment")
	hold.step(0.01,false,true,sim,30)
	hold.step(0.01,true,true,sim,30)
	t.equal(sim.frontier.city_level,1,"new press resumes the preserved project slots")

func test_empty_backpack_and_cancel_require_a_fresh_press(t) -> void:
	var hold=hold_controller(t)
	if hold==null: return
	var sim=Campaign.new({"starting_crystals":1})
	hold.step(0.01,true,true,sim,30)
	hold.step(0.6,true,true,sim,30)
	sim.pouch.receive(1,30)
	hold.step(1,true,true,sim,30)
	t.equal(sim.frontier.city_level,0,"newly collected crystal is not spent by an exhausted hold")
	hold.step(0.01,false,true,sim,30)
	hold.step(0.01,true,false,sim,30)
	hold.step(1,true,true,sim,30)
	t.equal(sim.pouch.amount,1,"airborne or paused input cannot become a delayed payment")
	hold.step(0.01,false,true,sim,30)
	hold.step(0.01,true,true,sim,30)
	t.equal(sim.frontier.city_level,1,"fresh valid press can finish after cancellation")

func test_free_interactions_and_tool_orders_never_repeat_while_held(t) -> void:
	var hold=hold_controller(t)
	if hold==null: return
	var sim=Campaign.new()
	sim.frontier.city_level=1
	sim.frontier.food=20
	var at: float=sim.world.sites.trade
	hold.step(0.01,true,true,sim,at)
	for tick in range(20): hold.step(0.2,true,true,sim,at)
	t.equal(sim.frontier.food,16,"free trade executes once per press")
	hold.step(0.01,false,true,sim,at)
	at=sim.world.sites.workshop
	for tick in range(20): hold.step(0.2,true,true,sim,at)
	t.equal(sim.world.tools.hammer,1,"a hold orders exactly one tool even if more stock is allowed")

func test_new_nearer_candidate_does_not_steal_a_held_project(t) -> void:
	var hold=hold_controller(t)
	if hold==null: return
	var sim=Campaign.new()
	sim.frontier.city_level=1
	sim.world.people.clear()
	var at: float=sim.world.sites.workshop
	hold.step(0.01,true,true,sim,at)
	sim.world.people.append({"x":at,"role":"wanderer","hurt":0.0,"cooldown":0.0})
	t.equal(sim.context(at).id,"recruit","a new neighbor is the normal selection without a lock")
	hold.step(0.6,true,true,sim,at)
	t.equal(sim.world.tools.hammer,1,"held project remains the workshop despite a new neighbor")
	t.equal(sim.world.people[0].role,"wanderer","neighbor receives no accidental payment")

func test_damaged_wall_does_not_turn_held_upgrade_into_repair(t) -> void:
	var hold=hold_controller(t)
	if hold==null: return
	var sim=Campaign.new()
	sim.frontier.city_level=1
	sim.frontier.stone=6
	sim.world.wall.merge({"level":1,"hp":40},true)
	var at: float=sim.world.sites.wall
	var original_key: String=sim.context(at).key
	hold.step(0.01,true,true,sim,at)
	sim.world.wall.hp=20
	hold.step(1,true,true,sim,at)
	t.equal(sim.pouch.amount,11,"wall damage cancels the old held upgrade")
	t.equal(sim.investments[original_key],1,"cancelled upgrade preserves its paid slot")
	t.equal(sim.context(at).paid,0,"repair does not inherit the upgrade payment")
