extends RefCounted
const Campaign=preload("res://application/campaign_session.gd")
func test_invasion_emerges_at_the_two_gates(t) -> void:
	var sim=Campaign.new({"seed":42,"economy":{"outer_regions_per_side":3}})
	sim.clock.remaining=0.01
	sim.advance(0.02,30)
	t.truth(absf(sim.raiders[0].x-sim.mission.rifts[1].x)<5,"right wave emerges inside the rightmost gate")
	for i in range(155):sim.advance(1.0/60,30)
	var left=sim.raiders.filter(func(e):return e.side==-1)
	t.truth(not left.is_empty() and absf(left[0].x-sim.mission.rifts[0].x)<15,"left wave emerges inside the leftmost gate")
	sim.mission.rifts[0].sealed=true
	sim.raiders.clear();sim._spawn_remaining=0;sim.clock.is_night=false;sim.clock.remaining=0.01
	sim.advance(0.02,30)
	for i in range(400):sim.advance(1.0/60,30)
	t.truth(sim.raiders.all(func(e):return e.side==1),"sealed gate cannot emit a later wave")

func test_expansion_is_hidden_until_the_region_is_cleared(t) -> void:
	var sim=Campaign.new({"seed":1})
	sim.frontier.city_level=2
	var region=sim.frontier.regions.find(sim.frontier.regions.filter(func(r):return r.kind=="quarry")[0])
	var id="frontier_wall:%d" % region
	sim.frontier.regions[region].discovered=true
	sim.frontier.regions[region].outpost_ready=true
	sim.frontier.regions[region].outpost_x=sim.frontier.regions[region].x+120
	t.truth(not sim.defenses.visible(id),"standing minerals conceal expansion ground")
	for n in sim.frontier.nodes:
		if n.region==region:n.marked=true
	t.truth(not sim.defenses.visible(id),"a work order alone does not clear ground")
	for n in sim.frontier.nodes:
		if n.region==region:n.collected=true
	t.truth(sim.defenses.visible(id),"actual resident clearing exposes the ground footprint")
	sim.advance(0.01,30) # Settle the newly cleared plot and its separate depot location.
	t.truth(sim.context(sim.frontier.regions[region].outpost_x).id=="outpost","cleared region exposes payable outpost")
