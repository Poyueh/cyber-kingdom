extends RefCounted
## Ordered territorial construction. Existing wall identities and inner walls persist.
var world
var frontier
var plots: Dictionary={}
var clearance: float
func _init(settlement, map, config: Dictionary={}) -> void:
	world=settlement
	frontier=map
	clearance=clampf(float(config.get("wall_clearance",80.0)),40,120)
	var previous: Dictionary={-1:"wall_left",1:"wall"}
	for index in range(frontier.regions.size()):
		var region: Dictionary=frontier.regions[index]
		var side:=1 if region.x>world.sites.hall else -1
		var id: String="frontier_wall:%d" % index
		var x: float=region.x+(region.width if side>0 else 0.0)
		world.add_wall(id,x)
		plots[id]={"region":index,"side":side,"previous":previous[side]}
		previous[side]=id

func visible(id: String) -> bool:
	return not plots.has(id) or frontier.regions[plots[id].region].discovered

func prerequisites(id: String) -> Array[Dictionary]:
	var result: Array[Dictionary]=[]
	if not plots.has(id) or world.walls[id].level>0:return result
	var plot: Dictionary=plots[id]
	if frontier.city_level<2:result.append({"icon":"camp","value":2})
	if not frontier.regions[plot.region].outpost_built:result.append({"icon":"outpost","value":1})
	if world.walls[plot.previous].hp<=0:result.append({"icon":"wall","value":1})
	var trees:=0
	for node in frontier.nodes:
		if node.kind=="tree" and not node.collected and absf(node.x-world.sites[id])<clearance:trees+=1
	if trees>0:result.append({"icon":"tree","value":trees})
	return result

func active_post(side: int) -> String:
	var result: String="wall" if side>0 else "wall_left"
	for id in plots:
		if plots[id].side==side and world.walls[id].hp>0 and side*world.sites[id]>side*world.sites[result]:
			result=id
	return result

func spawn_x(side: int) -> float:
	var at: float=world.sites.wall if side>0 else world.sites.wall_left
	for id in plots:
		if plots[id].side==side and world.walls[id].level>0 and side*world.sites[id]>side*at:at=world.sites[id]
	return clampf(at+side*480.0,frontier.left_boundary+30,frontier.right_boundary-30)

func shelter(from_x: float, fallback: float) -> float:
	var left: String=active_post(-1)
	var right: String=active_post(1)
	var home:=fallback
	for region in frontier.regions:
		if not region.outpost_built:continue
		var at: float=region.outpost_x
		var side:=1 if at>world.sites.hall else -1
		var post: String=right if side>0 else left
		if world.walls[post].hp<=0 or side*at>side*world.sites[post]-120:continue
		if absf(at-from_x)<absf(home-from_x):home=at
	return home
