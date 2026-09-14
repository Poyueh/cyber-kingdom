extends RefCounted
## Seeded blueprints are fixed before discovery. Payment never rerolls a site's purpose.
static func generate(frontier, seed_value: int, beacon_x: float) -> Dictionary:
 var result={"beacon":_site("tower",beacon_x,-1,-1)}
 var rng=RandomNumberGenerator.new();rng.seed=seed_value+6187
 var occupied: Array[float]=[]
 for index in range(frontier.nodes.size()):
  var node=frontier.nodes[index]
  if node.kind not in ["tree","crystal","stone"]:continue
  if occupied.any(func(x):return absf(x-node.x)<320):continue
  occupied.append(node.x)
  var kind: String=["wall","tower","farm"][rng.randi_range(0,2)]
  result["cleared:%d"%index]=_site(kind,node.x,node.region,index)
 return result
static func _site(kind: String, x: float, region: int, node: int) -> Dictionary:
 return {"kind":kind,"x":x,"region":region,"node":node,"level":0,"pending":false,"progress":0.0,"cooldown":0.0,"harvest":0.0}
static func cleared(frontier, site: Dictionary) -> bool:
 if site.node<0:return true
 if not frontier.regions[site.region].discovered or not frontier.nodes[site.node].collected:return false
 return not frontier.nodes.any(func(n):return n.kind in ["tree","crystal","stone","cache"] and not n.collected and absf(n.x-site.x)<80)
static func wall_health(level: int) -> int:
 return [0,40,80,160][clampi(level,0,3)]
static func tower_power(level: int, config: Dictionary={}) -> Dictionary:
 var tier:=clampi(level,0,3)
 return {"damage":int(config.get("tower_damage",12))*[0,1,1,3][tier],"interval":[2.0,1.6,0.65,1.1][tier],"range":float(config.get("tower_range",460))+tier*40}
static func separate_outposts(frontier, buildings: Dictionary, world_sites: Dictionary, investments: Dictionary) -> void:
 for index in range(frontier.regions.size()):
  var region: Dictionary=frontier.regions[index]
  if not region.outpost_ready or region.outpost_pending or region.outpost_built or investments.get("outpost:%d"%index,0)>0:continue
  if not buildings.values().any(func(s):return absf(s.x-region.outpost_x)<100):continue
  var best: float=region.outpost_x;var clearance:=0.0
  for step in range(4,int(region.width/20)-3):
   var candidate: float=region.x+step*20
   if frontier.nodes.any(func(n):return n.kind not in ["tree","crystal","stone","cache"] and absf(n.x-candidate)<80):continue
   var space:=INF
   for site in buildings.values():space=minf(space,absf(site.x-candidate))
   for x in world_sites.values():space=minf(space,absf(float(x)-candidate))
   if space>clearance:clearance=space;best=candidate
  if clearance>=100:region.outpost_x=best
