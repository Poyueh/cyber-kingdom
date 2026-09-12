extends SceneTree
## Deterministic combat probe, not a substitute for a player completing the demo.
const Campaign=preload("res://application/campaign_session.gd")
func _initialize() -> void:
	var results: Array=[]
	for day in [1,3,5]:
		for formation in [[1,0,1],[0,1,1],[1,1,1],[2,0,2],[0,2,2],[2,2,2]]:
			results.append(measure(day,formation[0],formation[1],formation[2]))
	print(JSON.stringify({"probe":"bilateral-stationary-defense-no-knight","step":1.0/60,"results":results},"  "))
	quit()
func measure(day: int, guards: int, hunters: int, wall_level: int) -> Dictionary:
	var sim=Campaign.new()
	sim.world.people.clear()
	sim.frontier.city_level=1
	for defense in sim.world.walls.values():
		defense.merge({"level":wall_level,"hp":wall_level*40},true)
		assert(defense.hp==wall_level*40,"Probe requires built walls")
	for i in range(guards+hunters):
		sim.world.people.append({"role":"guard" if i<guards else "hunter","x":1035.0-i*20,"hurt":0.0,"cooldown":0.0,"region":-1})
	sim._assign_defense_posts()
	for i in range(sim.world.people.size()):
		sim.world.people[i].x=sim._defense_position(i,65.0 if sim.world.people[i].role=="guard" else 90.0)
	sim.clock.day=day
	sim.clock.remaining=0.01
	var elapsed:=0.0
	while elapsed<120.0 and sim.clock.day==day:
		sim.advance(1.0/60,-5000)
		elapsed+=1.0/60
	var survivors:=0
	for person in sim.world.people:
		if person.role!="wanderer": survivors+=1
	return {"day":day,"guards":guards,"hunters":hunters,"wall_level":wall_level,
		"wall_hp":{"left":sim.world.walls.wall_left.hp,"right":sim.world.wall.hp},"remaining_defenders":survivors,"initial_defenders":guards+hunters,
		"seconds":snappedf(elapsed,0.1),"reached_dawn":sim.clock.day>day,
		"outcome":"held" if sim.world.walls.values().all(func(w):return w.hp>0) and survivors==guards+hunters and sim.clock.day>day else ("lost" if survivors==0 else "breached")}
