extends "res://tools/play_campaign.gd"
## Paired strategy study: baseline vs first outer wall on each side before sealing.
var expand:=true
var wall_events: Array=[]
var return_events: Array=[]
var prior_walls: Dictionary={}
var prior_positions: Array=[]
var prior_sheltering: Array=[]
var return_walk:=0.0
func _initialize() -> void:
 var args=OS.get_cmdline_user_args()
 if args.size()>5:expand=args[5]!="baseline"
 super._initialize()
func tick() -> void:
 var sim=scene.sim
 for id in sim.defenses.plots:
  var wall: Dictionary=sim.world.walls[id]
  var previous: int=prior_walls.get(id,0)
  if wall.level>previous:wall_events.append({"seconds":snappedf(elapsed,0.1),"id":id,"level":wall.level})
  prior_walls[id]=wall.level
 for i in range(sim.world.people.size()):
  var p: Dictionary=sim.world.people[i]
  var sheltering: bool=p.get("sheltering",false) and p.role in ["engineer","citizen","farmer"]
  if i<prior_positions.size() and sheltering:
   return_walk+=absf(p.x-prior_positions[i])
  if sheltering and (i>=prior_sheltering.size() or not prior_sheltering[i]):
   var fallback: float=sim.world.sites.hall+(i%5-2)*22.0
   var target: float=sim.defenses.shelter(p.x,fallback)
   return_events.append({"seconds":snappedf(elapsed,0.1),"person":i,"from":p.x,"target":target,"local":target!=fallback,"shorter_by":absf(p.x-fallback)-absf(p.x-target)})
 prior_positions=sim.world.people.map(func(p):return float(p.x))
 prior_sheltering=sim.world.people.map(func(p):return bool(p.get("sheltering",false)))
 super.tick()
func snapshot() -> Dictionary:
 var result=super.snapshot()
 result["expansion_mode"]="expand" if expand else "baseline"
 result["outposts"]=scene.sim.frontier.outpost_count()
 result["construction_events"]=wall_events.duplicate(true)
 result["shelter_events"]=return_events.duplicate(true)
 result["return_walk"]=snappedf(return_walk,1.0)
 return result
func allow_rifts() -> bool:
 return not expand or ["frontier_wall:0","frontier_wall:3"].all(func(id):return scene.sim.world.walls[id].level>0)
func extra_jobs() -> Array:
 var sim=scene.sim
 var jobs: Array=[]
 if not expand or sim.frontier.city_level<2:return jobs
 for index in [0,3]:
  var region: Dictionary=sim.frontier.regions[index]
  var id: String="frontier_wall:%d"%index
  if not region.discovered:continue
  if sim.world.walls[id].level>0:
   if sim.world.walls[id].hp<30:offer(jobs,site_job(id,100))
   continue
  if not region.outpost_ready:
   var resources=sim.frontier.nodes.filter(func(n):return n.region==index and n.kind!="cache")
   if not resources.any(func(n):return n.marked or n.collected):
    for n in resources:
     if sim.pouch.amount>0:offer(jobs,{"kind":"node","index":sim.frontier.nodes.find(n),"x":n.x,"y":n.y,"priority":100,"label":"expansion_delivery"})
  elif not region.outpost_built and not region.outpost_pending and sim.pouch.amount>=3:
   offer(jobs,{"kind":"outpost","index":index,"x":region.outpost_x,"priority":100,"label":"expansion_outpost"})
  for n in sim.frontier.nodes:
   if n.kind=="tree" and not n.marked and not n.collected and sim.frontier.regions[n.region].discovered and absf(n.x-sim.world.sites[id])<sim.defenses.clearance and sim.pouch.amount>0:
    offer(jobs,{"kind":"node","index":sim.frontier.nodes.find(n),"x":n.x,"y":n.y,"priority":100,"label":"wall_clearance"})
  offer(jobs,site_job(id,100))
 return jobs
