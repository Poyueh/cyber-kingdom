extends RefCounted
## Resident work scheduling: claim a site, reach it, work, carry, deliver.
## Godot physics/rendering stays outside; vertical access follows the visible ladders.
var world
var frontier
var elapsed := 0.0
var deliveries: Array[Dictionary] = []
func _init(settlement, map) -> void:
	world = settlement
	frontier = map

func before_people(seconds: float) -> void:
	elapsed += seconds
	for node in frontier.nodes:
		if node.worker<0: continue
		var person: Dictionary = world.people[node.worker]
		if person.role!="engineer":
			if node.carried:
				node.pickup_x = person.x
				node.pickup_y = person.get("y",430.0)
				node.carried = false
			node.worker = -1
	for person in world.people:
		if person.role!="engineer":
			person["work_state"] = "idle"
			person["y"] = move_toward(person.get("y",430.0),430.0,70*seconds)

func delivery_point(from: float) -> float:
	var destination: float = world.sites.hall
	for region in frontier.regions:
		if region.outpost_built and absf(region.outpost_x-from)<absf(destination-from):
			destination = region.outpost_x
	return destination

func _grounded(person: Dictionary, seconds: float) -> bool:
	if absf(person.get("y",430.0)-430)<0.1: return true
	person["y"] = move_toward(person.get("y",430.0),430.0,70*seconds)
	person["work_state"] = "climb"
	return false

func advance_engineer(index: int, seconds: float) -> float:
	var person: Dictionary = world.people[index]
	person["work_state"] = "idle"
	var job
	for node in frontier.nodes:
		if node.worker==index: job=node; break
	if job!=null and job.carried:
		person.work_state = "haul"
		if not _grounded(person,seconds): return person.x
		var destination := delivery_point(person.x)
		if absf(person.x-destination)<12:
			var reward: Dictionary = frontier.deposit(job)
			if not reward.is_empty():
				world.scrap += reward.scrap
				world.crystals += reward.crystals
				deliveries.append({"x":person.x,"crystals":reward.crystals})
			person.work_state = "idle"
		return destination
	# Paid defences and expansion sites take priority over starting another harvest.
	var construction := -1
	var nearest := INF
	for region_index in range(frontier.regions.size()):
		var region: Dictionary = frontier.regions[region_index]
		if region.outpost_pending and absf(region.outpost_x-person.x)<nearest:
			nearest = absf(region.outpost_x-person.x)
			construction = region_index
	if world.wall.pending or construction>=0:
		if job!=null: job.worker=-1
		if not _grounded(person,seconds): return person.x
		var target: float = world.sites.wall-12 if world.wall.pending else frontier.regions[construction].outpost_x-12
		if absf(target-person.x)<8:
			person.work_state = "work"
			person["direction"] = 1.0
			if world.wall.pending: world.work_wall(index,seconds)
			else: frontier.work_outpost(construction,seconds)
		return target
	if job==null:
		nearest = INF
		for node in frontier.nodes:
			var target: float = node.pickup_x if node.collected else node.x
			if node.marked and not node.delivered and node.worker<0 and absf(target-person.x)<nearest:
				nearest=absf(target-person.x)
				job=node
		if job!=null: job.worker=index
	if job==null:
		if not _grounded(person,seconds): return person.x
		return world.sites.workshop
	var target_x: float = job.pickup_x if job.collected else job.x-22
	var target_y: float = job.pickup_y if job.collected else job.y
	if absf(target_x-person.x)>=8:
		if not _grounded(person,seconds): return person.x
		person.work_state = "walk"
		return target_x
	if absf(person.get("y",430.0)-target_y)>0.1:
		person["y"] = move_toward(person.get("y",430.0),target_y,70*seconds)
		person.work_state = "climb"
		return person.x
	person.work_state = "work"
	person["direction"] = 1.0
	if not job.collected:
		var duration: float = frontier.work_seconds/3 if job.kind=="berries" else frontier.work_seconds
		if not job.advance_work(seconds,duration): return person.x
		frontier.collect(job)
	job.carried = true
	job.pickup_x = person.x
	job.pickup_y = person.get("y",430.0)
	person.work_state = "haul"
	return person.x
