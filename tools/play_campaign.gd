extends SceneTree
## Native physics/input playthrough. Only map seed is overridden before scene creation.
## Read-only planning may inspect discovered locations; never grants resources or buildings.
var scene
var elapsed:=0.0
var frame:=0
var run_seed:=1
var route:="knight"
var combat_profile:="reactive"
var output:="/tmp/campaign-playthrough.json"
var limit:=1800.0
var goal: Dictionary={}
var events: Array=[]
var samples: Array=[]
var next_sample:=0.0
var last_total:=12
var generated:=0
var spent:=0
var received_damage:=0
var minimum_core_hp:=0
var previous_hp:=100
var previous_roles: Array=[]
var losses:=0
var stall:=0.0
var last_x:=30.0
func _initialize() -> void:
	ProjectSettings.set_setting("campaign/persistence_enabled",false)
	var args=OS.get_cmdline_user_args()
	if args.size()>0:run_seed=int(args[0])
	if args.size()>1:route=args[1]
	if args.size()>2:output=args[2]
	if args.size()>3:limit=float(args[3])
	if args.size()>4:combat_profile=args[4]
	call_deferred("start")
func start() -> void:
	scene=load("res://scenes/frontier.tscn").instantiate()
	scene.tuning=scene.tuning.duplicate()
	scene.tuning.map_seed=run_seed
	root.add_child(scene)
	minimum_core_hp=scene.sim.mission.core_hp
	physics_frame.connect(tick)
func snapshot() -> Dictionary:
	var sim=scene.sim
	var roles: Dictionary={}
	for person in sim.world.people:roles[person.role]=int(roles.get(person.role,0))+1
	var walls: Dictionary={}
	for id in sim.world.walls:
		if sim.world.walls[id].level>0:walls[id]={"level":sim.world.walls[id].level,"hp":sim.world.walls[id].hp}
	return {"seconds":snappedf(elapsed,0.1),"day":sim.clock.day,"night":sim.clock.is_night,"x":snappedf(scene.knight.position.x,1),"y":snappedf(scene.knight.position.y,1),"grounded":scene.knight.is_on_floor(),"context":scene.sim.context(scene.knight.position.x).id,"hp":sim.hero.hp,"shield":sim.hero.shield,"core":sim.mission.core_hp,
		"crystals":sim.pouch.amount,"ground":sim.pouch.ground_total(),"wood":sim.frontier.wood,"food":sim.frontier.food,"stone":sim.frontier.stone,"herbs":sim.frontier.herbs,"scrap":sim.world.scrap,
		"city":sim.frontier.city_level,"sword":sim.frontier.drill_level,"capacitor":sim.growth.capacitor_level,"roles":roles,"walls":walls,"sealed":sim.mission.rifts.filter(func(r):return r.sealed).size()}
func tick() -> void:
	var sim=scene.sim
	frame+=1
	elapsed+=1.0/60
	Input.action_release("attack");Input.action_release("dash");Input.action_release("jump")
	Input.action_release("move_left");Input.action_release("move_right")
	scene.hud.interact_button.button_up.emit()
	minimum_core_hp=mini(minimum_core_hp,sim.mission.core_hp)
	var total: int=sim.pouch.amount+sim.pouch.ground_total()
	if total>last_total:generated+=total-last_total
	elif total<last_total:spent+=last_total-total
	last_total=total
	if sim.hero.hp<previous_hp:received_damage+=previous_hp-sim.hero.hp
	previous_hp=sim.hero.hp
	for i in range(mini(previous_roles.size(),sim.world.people.size())):
		if previous_roles[i]!="wanderer" and sim.world.people[i].role=="wanderer":losses+=1
	previous_roles=sim.world.people.map(func(p):return p.role)
	if elapsed>=next_sample:
		var state:=snapshot()
		state["goal"]=goal.get("label","")
		samples.append(state)
		print("PROGRESS ",JSON.stringify(state))
		next_sample+=60
	if not sim.is_running() or elapsed>=limit:
		var result={"seed":run_seed,"route":route,"combat_profile":combat_profile,"shield_absorbed":sim.hero.shield_absorbed,"native_physics":true,"resource_grants":false,"outcome":sim.mission.outcome,"reason":sim.mission.defeat_reason,"final":snapshot(),
			"observed_crystal_increase":generated,"observed_crystal_decrease":spent,"knight_hp_damage":received_damage,"minimum_core_hp":minimum_core_hp,"resident_losses":losses,"events":events,"samples":samples}
		var experiment:=experiment_report()
		if not experiment.is_empty():result["experiment"]=experiment
		var file=FileAccess.open(output,FileAccess.WRITE)
		file.store_string(JSON.stringify(result,"  "))
		print("RESULT ",JSON.stringify(result.final)," outcome=",result.outcome)
		quit()
		return
	if not input_ready():return
	# Immediate threat interrupts errands, using normal move, slash and dodge inputs.
	var enemy: Dictionary={}
	var nearest:=INF
	for candidate in sim.raiders:
		if not candidate.fighter.is_alive():continue
		var distance: float=absf(candidate.x-scene.knight.position.x)
		if distance<nearest and (distance<360 or sim.clock.is_night):
			nearest=distance;enemy=candidate
	if not enemy.is_empty():
		goal={}
		var delta: float=enemy.x-scene.knight.position.x
		move(signf(delta) if absf(delta)>42 else 0)
		# Face the enemy without overriding attack rooting or combo travel.
		if absf(delta)<70:
			move(signf(delta))
			if frame%10==0:Input.action_press("attack")
			if combat_profile=="reactive" and enemy.windup>0 and enemy.windup<0.13 and absf(delta)<70 and sim.hero.stamina>=30 and frame%4==0:
				Input.action_press("dash")
		return
	if goal.is_empty() or done(goal) or stall>10:
		if not goal.is_empty():events.append({"seconds":snappedf(elapsed,0.1),"action":goal.label,"done":done(goal)})
		goal=choose()
		stall=0
	if goal.is_empty():return
	var x: float=goal.x
	if goal.kind=="person":x=sim.world.people[goal.index].x
	if goal.kind=="drop":
		var drops=sim.pouch.drops.filter(func(d):return d.id==goal.index)
		if not drops.is_empty():x=drops[0].x
	var delta: float=x-scene.knight.position.x
	if absf(scene.knight.position.x-last_x)<0.1 and absf(delta)>12:stall+=1.0/60
	else:stall=0
	last_x=scene.knight.position.x
	move(signf(delta) if absf(delta)>5 else 0)
	if goal.get("y",430.0)<400 and scene.knight.is_on_floor() and scene.knight.position.y>400 and absf(delta)<95 and frame%30==0:Input.action_press("jump")
	# Keep walking off raised platforms for ground targets.
	if goal.get("y",430.0)>=400 and scene.knight.position.y<400 and absf(delta)<90:
		move(-1 if delta<=0 else 1)
	if absf(delta)<8 and scene.knight.is_on_floor() and absf(scene.knight.position.y-goal.get("y",430.0))<30 and frame%18==0:
		scene.hud.interact_button.button_down.emit()
func move(direction: float) -> void:
	if direction<0:Input.action_press("move_left")
	elif direction>0:Input.action_press("move_right")
func count_role(role: String) -> int:
	return scene.sim.world.people.filter(func(p):return p.role==role).size()
func done(job: Dictionary) -> bool:
	var sim=scene.sim
	match job.kind:
		"site":
			var choice: Dictionary=sim._campaign_site(job.site)
			return (job.site=="beacon" and sim.world.barrier>=2) or sim.pouch.amount<=0 or not choice.enabled or choice.key!=job.key or (job.has("tool") and sim.world.tools[job.tool]+count_role(sim.world.tool_roles[job.tool])>=job.target)
		"person":return sim.world.people[job.index].role!="wanderer"
		"outpost":return sim.frontier.regions[job.index].outpost_pending or sim.frontier.regions[job.index].outpost_built
		"node":return sim.frontier.nodes[job.index].collected or sim.frontier.nodes[job.index].marked
		"drop":return sim.pouch.amount>=sim.pouch.capacity or not sim.pouch.drops.any(func(d):return d.id==job.index)
		"explore":return sim.frontier.regions[job.index].discovered
		"rift":return sim.mission.rifts[job.index].sealed
	return true
func site_job(site: String, priority: float, target: int=0) -> Dictionary:
	var sim=scene.sim
	var choice: Dictionary=sim._campaign_site(site)
	var reserve:=1 if scene.sim.frontier.city_level>0 and site in ["armory","hunt_tools","farm_tools","forge","drill"] else 0
	if not choice.enabled or sim.pouch.amount<maxi(1,choice.cost-int(sim.investments.get(choice.key,0)))+reserve:return {}
	var job: Dictionary={"kind":"site","site":site,"x":choice.x,"y":430.0,"key":choice.key,"priority":priority,"label":choice.id}
	if sim.TOOL_KINDS.has(site):
		job["tool"]=sim.TOOL_KINDS[site];job["target"]=target
	return job
func offer(jobs: Array, job: Dictionary) -> void:
	if not job.is_empty():jobs.append(job)
func choose() -> Dictionary:
	var sim=scene.sim
	var jobs: Array=[]
	var x: float=scene.knight.position.x
	if sim.frontier.city_level==0:return site_job("hall",10000)
	var people_count: int=sim.world.people.size()-count_role("wanderer")
	var desired: Dictionary={"engineer":2 if route=="residents" or sim.growth.capacitor_level>=1 else 1,"guard":2,"hunter":2 if route=="residents" else 1,"farmer":1}
	var required:=0
	for n in desired.values():required+=n
	for i in range(sim.world.people.size()):
		var p=sim.world.people[i]
		if people_count<required and p.role=="wanderer" and p.hurt<=0 and sim.person_visible(p) and sim.pouch.amount>0:
			offer(jobs,{"kind":"person","index":i,"x":p.x,"priority":100 if count_role("engineer")==0 else 45,"label":"recruit"})
	var tool_order:=["workshop","hunt_tools","armory","farm_tools"]
	for site in tool_order:
		var tool: String=sim.TOOL_KINDS[site]
		var role: String=sim.world.tool_roles[tool]
		if sim.world.tools[tool]+count_role(role)<desired[role] and (count_role("citizen")>0 or count_role(role)==0):
			offer(jobs,site_job(site,95 if site=="workshop" and count_role("engineer")==0 else (65 if site=="hunt_tools" else 50),desired[role]))
	for id in ["wall","wall_left"]:
		if sim.world.walls[id].level==0 or sim.world.walls[id].hp<30:offer(jobs,site_job(id,65))
	if sim.mission.core_hp<120:offer(jobs,site_job("hall",180))
	if sim.hero.hp<70:offer(jobs,site_job("heal",140))
	if sim.frontier.city_level>=2 and sim.world.barrier<2:offer(jobs,site_job("beacon",120))
	if route=="knight" or count_role("guard")>=2:
		if sim.growth.capacitor_level<mini(2,sim.frontier.city_level) or sim.hero.shield<sim.growth.capacity():offer(jobs,site_job("forge",80 if route=="knight" else 40))
		if sim.frontier.drill_level<mini(2,sim.frontier.city_level):offer(jobs,site_job("drill",75 if route=="knight" else 38))
	if not sim.frontier.farm_active:offer(jobs,site_job("farm",75))
	if sim.frontier.city_level<2:offer(jobs,site_job("hall",90))
	if sim.frontier.food>=8 and sim.pouch.amount<=8:offer(jobs,site_job("trade",110))
	for i in range(sim.frontier.nodes.size()):
		var n=sim.frontier.nodes[i]
		if n.collected or n.marked or not sim.frontier.regions[n.region].discovered:continue
		var priority:=0.0
		if n.kind=="cache" and sim.pouch.amount<=8:priority=115
		elif n.kind=="crystal" and sim.pouch.amount>0:priority=50
		elif n.kind=="tree" and sim.frontier.wood<10 and not sim.ecology.clearing_last_tree(n):priority=85
		elif n.kind=="stone" and sim.frontier.stone<3:priority=55
		elif n.kind=="berries" and sim.frontier.food<6:priority=80
		elif n.kind=="herbs" and sim.frontier.herbs<4:priority=35
		if priority>0 and (n.kind=="cache" or sim.pouch.amount>0):
			offer(jobs,{"kind":"node","index":i,"x":n.x,"y":n.y,"priority":priority,"label":n.kind})
	if sim.pouch.amount<sim.pouch.capacity:
		for d in sim.pouch.drops:
			if d.grace<=0:offer(jobs,{"kind":"drop","index":d.id,"x":d.x,"y":d.y,"priority":145 if sim.pouch.amount<3 else 60,"label":"collect"})
	for i in range(sim.frontier.regions.size()):
		var r=sim.frontier.regions[i]
		if sim.frontier.expansion_cleared(i) and r.outpost_ready and not r.outpost_pending and not r.outpost_built and sim.pouch.amount>=4 and sim.frontier.nodes.any(func(n):return n.region==i and n.marked and not n.delivered):
			offer(jobs,{"kind":"outpost","index":i,"x":r.outpost_x,"priority":60,"label":"outpost"})
		if not r.discovered:offer(jobs,{"kind":"explore","index":i,"x":r.x+r.width*0.5,"priority":55,"label":"explore"})
	for job in extra_jobs():offer(jobs,job)
	if allow_rifts() and sim.frontier.city_level>=2 and sim.clock.survived>=1 and count_role("engineer")>0 and (sim.frontier.drill_level>=1 or count_role("guard")>=2):
		for i in range(sim.mission.rifts.size()):
			var r=sim.mission.rifts[i]
			if not r.sealed and (r.ordered or (sim.pouch.amount>=4 and sim.world.barrier>=2)):offer(jobs,{"kind":"rift","index":i,"x":r.x,"priority":110,"label":"rift"})
	if jobs.is_empty():return {}
	jobs.sort_custom(func(a,b):return a.priority-absf(a.x-x)/30.0>b.priority-absf(b.x-x)/30.0)
	return jobs[0]

func extra_jobs() -> Array:
	return []

func allow_rifts() -> bool:
	return true

func input_ready() -> bool:
	return true

func experiment_report() -> Dictionary:
	return {}
