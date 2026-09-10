extends RefCounted
## Seeded, passable region templates and finite harvests, independent of scenes.
const Harvest = preload("res://domain/harvest_node.gd")
var regions: Array[Dictionary] = []
var nodes: Array[RefCounted] = []
var animals: Array[Dictionary] = []
var left_boundary := -700.0
var right_boundary := 1800.0
var wood: int = 0
var food: int = 0
var city_level: int = 1
var farm_active := false
var farm_progress := 0.0
var drill_level: int = 0

var farm_cycle := 12.0
var farm_yield := 2
var training_food := 2
var training_damage := 5
var training_limit := 3

func _init(map_seed: int, rules: Dictionary = {}) -> void:
	farm_cycle = maxf(0.1,float(rules.get("farm_cycle",12.0)))
	farm_yield = maxi(1,int(rules.get("farm_yield",2)))
	training_food = maxi(1,int(rules.get("training_food",2)))
	training_damage = maxi(1,int(rules.get("training_damage",5)))
	training_limit = maxi(1,int(rules.get("training_limit",3)))
	var rng := RandomNumberGenerator.new()
	rng.seed = map_seed
	var types := ["forest","forest","quarry","quarry","ruins","ruins"]
	for index in range(types.size()-1,0,-1):
		var swap := rng.randi_range(0,index)
		var kind: String = types[index]
		types[index] = types[swap]
		types[swap] = kind
	for index in range(types.size()):
		var width := float(rng.randi_range(4,6)*100)
		var x := right_boundary
		if index < 3:
			left_boundary -= width
			x = left_boundary
		else:
			right_boundary += width
		regions.append({"kind":types[index],"x":x,"width":width,"discovered":false})
		match types[index]:
			"forest":
				for tree in range(4):
					_add(index,"tree",x+50+tree*(width-100)/3.0+rng.randf_range(-10,10),430,3,0,1 if tree == 0 else 0,0)
				_add(index,"berries",x+width*0.5,430,0,2,0,0)
				for animal in range(2):
					animals.append({"x":x+90+animal*(width-180),"region":index,"alive":true})
			"quarry":
				_add(index,"crystal",x+width*0.3,430,0,0,2,0)
				_add(index,"crystal",x+width*0.7,430,0,0,2,0)
			"ruins":
				_add(index,"cache",x+width*0.35,366,0,0,0,4)
				_add(index,"cache",x+width*0.75,430,0,0,0,4)

func _add(region_index: int, kind: String, x: float, y: float, timber: int, rations: int, crystal: int, salvage: int) -> void:
	var node := Harvest.new()
	node.region = region_index
	node.kind = kind
	node.x = x
	node.y = y
	node.wood = timber
	node.food = rations
	node.crystals = crystal
	node.scrap = salvage
	if kind == "berries": node.hp = 25
	nodes.append(node)

func layout_signature() -> String:
	var layout: Array = []
	for node in nodes: layout.append([node.kind,node.x,node.y,node.wood,node.food,node.crystals,node.scrap])
	return str(layout)

func reveal(x: float) -> void:
	for region in regions:
		if x >= region.x-100 and x <= region.x+region.width+100: region.discovered = true

func discovered_count() -> int:
	var count := 0
	for region in regions:
		if region.discovered: count += 1
	return count

func collect(node: RefCounted) -> Dictionary:
	if not nodes.has(node) or node.hp > 0 or node.collected:
		return {}
	node.collected = true
	wood += node.wood
	food += node.food
	return {"crystals":node.crystals,"scrap":node.scrap}

func plant() -> bool:
	if farm_active or wood < 2 or food < 1: return false
	wood -= 2
	food -= 1
	farm_active = true
	return true

func advance_farm(seconds: float, workers: int) -> void:
	if not farm_active or workers <= 0 or seconds <= 0 or not is_finite(seconds): return
	farm_progress += seconds*workers
	while farm_progress >= farm_cycle:
		farm_progress -= farm_cycle
		food += farm_yield # Net surplus after retaining seed for the next crop.

func city_cost() -> Dictionary:
	return {"wood":8,"food":4,"scrap":4} if city_level == 1 else {"wood":12,"food":6,"scrap":8}

func upgrade_city(available_scrap: int) -> int:
	var cost := city_cost()
	if city_level >= 3 or wood < cost.wood or food < cost.food or available_scrap < cost.scrap: return 0
	wood -= cost.wood
	food -= cost.food
	city_level += 1
	return cost.scrap
