extends RefCounted
const Frontier=preload("res://domain/frontier.gd")
const Campaign=preload("res://application/campaign_session.gd")
const Snapshot=preload("res://application/campaign_snapshot.gd")

func test_outer_regions_extend_both_sides_without_replacing_the_opening(t) -> void:
	for seed in [1,7,42]:
		var old=Frontier.new(seed)
		var larger=Frontier.new(seed,{"outer_regions_per_side":3})
		t.truth(larger.left_boundary<old.left_boundary-1700 and larger.right_boundary>old.right_boundary+1700,"both directions contain substantial additional exploration")
		for i in range(old.regions.size()):
			t.equal(larger.regions[i],old.regions[i],"opening geography and random stream stay stable")
		var old_nodes: int=old.nodes.size()
		for i in range(old_nodes):
			t.equal([larger.nodes[i].kind,larger.nodes[i].x],[old.nodes[i].kind,old.nodes[i].x],"nearby resource positions are retained")
		var outer_types: Dictionary={-1:[],1:[]}
		for i in range(old.regions.size(),larger.regions.size()):
			var region: Dictionary=larger.regions[i]
			outer_types[-1 if region.x<0 else 1].append(region.kind)
			t.truth(larger.nodes.any(func(n):return n.region==i),"every added region contains harvest or treasure")
			t.truth(not region.discovered,"outer rewards begin hidden")
		for side in outer_types:
			t.truth(["forest","quarry","ruins"].all(func(kind):return kind in outer_types[side]),"each outer route offers all three resource environments")
		t.equal(larger.layout_signature(),Frontier.new(seed,{"outer_regions_per_side":3}).layout_signature(),"new map remains seed reproducible")

func test_expanded_campaign_seals_beyond_resources_and_survives_save_restore(t) -> void:
	var config={"seed":42,"economy":{"outer_regions_per_side":3}}
	var sim=Campaign.new(config)
	var old=Campaign.new({"seed":42})
	t.truth(sim.mission.rifts[0].x<old.mission.rifts[0].x-1700 and sim.mission.rifts[1].x>old.mission.rifts[1].x+1700,"expeditions reach the new map extremities")
	var region: Dictionary=sim.frontier.regions.back()
	sim.frontier.reveal(region.x+region.width/2)
	var save=Snapshot.new()
	var restored=save.restore(save.capture(sim,config,{"x":30.0,"y":430.0,"vx":0.0,"vy":0.0}))
	t.truth(not restored.is_empty(),"expanded campaign checkpoint restores")
	if not restored.is_empty():
		t.equal(restored.session.frontier.layout_signature(),sim.frontier.layout_signature(),"save retains expanded resources")
		t.truth(restored.session.frontier.regions.back().discovered,"outer exploration discovery survives reload")
	var legacy=save.restore(save.capture(old,{"seed":42},{"x":30.0,"y":430.0,"vx":0.0,"vy":0.0}))
	t.truth(not legacy.is_empty() and legacy.session.frontier.regions.size()==6,"legacy configuration retains its original smaller map")

func test_more_exploration_camps_still_respect_population_limit(t) -> void:
	var sim=Campaign.new({"seed":1,"economy":{"outer_regions_per_side":3}})
	t.equal(sim.world.people.size(),14,"expanded map starts with twelve camp wanderers and two near the fire")
	sim.clock.is_night=true
	sim.clock.remaining=0.01
	sim.advance(0.02,30)
	t.equal(sim.world.people.size(),24,"dawn replenishes only up to existing population ceiling")
	sim.clock.is_night=true
	sim.clock.remaining=0.01
	sim.advance(0.02,30)
	t.equal(sim.world.people.size(),24,"more distant camps cannot overflow the population ceiling")
