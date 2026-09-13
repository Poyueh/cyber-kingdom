extends RefCounted
## Closed, versioned state graph. No script paths or object construction come from a save.
const Campaign=preload("res://application/campaign_session.gd")
const Rules=preload("res://application/campaign_checkpoint_rules.gd")
const VERSION:=2
const SESSION_SKIP=["raiders","effects","opened_chests"]
const FIGHTER_SKIP=["_hit_targets","_queued_attack_seconds","_pending_attack_travel"]
var last_error:=""

func _plain(value, depth: int=0) -> bool:
	if depth>20:return false
	match typeof(value):
		TYPE_NIL,TYPE_BOOL:return true
		TYPE_INT,TYPE_FLOAT:return is_finite(float(value)) and absf(float(value))<=1000000000000.0
		TYPE_STRING,TYPE_STRING_NAME:return str(value).length()<=2048
		TYPE_ARRAY:
			if value.size()>10000:return false
			for item in value:
				if not _plain(item,depth+1):return false
			return true
		TYPE_DICTIONARY:
			if value.size()>10000:return false
			for key in value:
				if not (key is String or key is StringName) or not _plain(key,depth+1) or not _plain(value[key],depth+1):return false
			return true
	return false

func _fields(object, skip: Array=[]) -> Dictionary:
	var result: Dictionary={}
	for property in object.get_property_list():
		var key: String=property.name
		if not (property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) or key in skip:continue
		var value=object.get(key)
		if typeof(value)==TYPE_OBJECT:continue
		# Every remaining script field must have an explicitly supported plain shape.
		result[key]=value.duplicate(true) if value is Array or value is Dictionary else value
	return result

func _fighter(actor) -> Dictionary:
	return {"stats":_fields(actor.stats),"state":_fields(actor,FIGHTER_SKIP)}

func capture(sim, config: Dictionary, body: Dictionary) -> Dictionary:
	var rules:=config.duplicate(true)
	rules.seed=sim.map_seed
	var nodes: Array=[]
	for node in sim.frontier.nodes:nodes.append(_fields(node))
	var enemies: Array=[]
	var hit_indices: Array=[]
	for index in range(sim.raiders.size()):
		var enemy: Dictionary=sim.raiders[index]
		var state:=enemy.duplicate()
		state.erase("fighter")
		enemies.append({"state":state.duplicate(true),"fighter":_fighter(enemy.fighter)})
		if sim.hero._hit_targets.has(enemy.fighter.get_instance_id()):hit_indices.append(index)
	var opened: Dictionary={}
	for key in sim.opened_chests:opened[str(key)]=sim.opened_chests[key]
	return {"version":VERSION,"config":rules,"body":body.duplicate(true),
		"session":_fields(sim,SESSION_SKIP),"world":_fields(sim.world,["wall"]),
		"frontier":_fields(sim.frontier,["nodes"]),"nodes":nodes,"clock":_fields(sim.clock),
		"mission":_fields(sim.mission),"growth":_fields(sim.growth),"ecology":_fields(sim.ecology),
		"pouch":_fields(sim.pouch,["pickups"]),"workforce":_fields(sim.workforce,["deliveries"]),
		"hero":_fighter(sim.hero),"raiders":enemies,"hero_hits":hit_indices,"opened":opened}

func _normalize(value):
	if value is StringName:return str(value)
	if value is float and floorf(value)==value:return int(value)
	if value is Array:
		var result: Array=[]
		for item in value:result.append(_normalize(item))
		return result
	if value is Dictionary:
		var result: Dictionary={}
		for key in value:result[str(key)]=_normalize(value[key])
		return result
	return value

func _copy_fields(object, saved, skip: Array=[]) -> bool:
	if not saved is Dictionary:return false
	var template:=_fields(object,skip)
	if saved.size()!=template.size():return false
	for key in template:
		if not saved.has(key):return false
		var value=saved[key]
		match typeof(template[key]):
			TYPE_INT:
				if not value is int:return false
			TYPE_FLOAT:
				if not (value is int or value is float):return false
			_:
				if typeof(value)!=typeof(template[key]):return false
		if value is Array and template[key].is_typed():
			for item in value:
				if typeof(item)!=template[key].get_typed_builtin():return false
	for key in template:
		if template[key] is Array:
			# Preserve typed arrays such as Array[Dictionary].
			object.get(key).assign(saved[key].duplicate(true))
		else:object.set(key,saved[key].duplicate(true) if saved[key] is Dictionary else saved[key])
	return true

func _restore_fighter(actor, saved) -> bool:
	return saved is Dictionary and saved.has("stats") and saved.has("state") and _copy_fields(actor.stats,saved.stats) and _copy_fields(actor,saved.state,FIGHTER_SKIP)

func _invalid() -> Dictionary:
	last_error="Invalid or unsupported campaign checkpoint; original retained."
	return {}

func restore(raw) -> Dictionary:
	last_error=""
	if not raw is Dictionary or not _plain(raw):return _invalid()
	var data: Dictionary=_normalize(raw)
	var keys=["version","config","body","session","world","frontier","nodes","clock","mission","growth","ecology","pouch","workforce","hero","raiders","hero_hits","opened"]
	if data.size()!=keys.size() or not keys.all(func(k):return data.has(k)):return _invalid()
	if data.version==1 and not _upgrade_v1(data):return _invalid()
	if data.version!=VERSION or not data.config is Dictionary or not data.body is Dictionary:return _invalid()
	if not Rules.config_valid(data.config):return _invalid()
	for key in ["x","y","vx","vy"]:
		if not data.body.has(key) or not (data.body[key] is int or data.body[key] is float):return _invalid()
	if data.body.size()!=4:return _invalid()
	var sim=Campaign.new(data.config)
	if not Rules.valid(data,capture(sim,data.config,data.body)):return _invalid()
	for part in [
		[sim,data.session,SESSION_SKIP],[sim.world,data.world,["wall"]],
		[sim.frontier,data.frontier,["nodes"]],[sim.clock,data.clock,[]],[sim.mission,data.mission,[]],
		[sim.growth,data.growth,[]],[sim.ecology,data.ecology,[]],[sim.pouch,data.pouch,["pickups"]],
		[sim.workforce,data.workforce,["deliveries"]]]:
		if not _copy_fields(part[0],part[1],part[2]):return _invalid()
	if not _restore_fighter(sim.hero,data.hero):return _invalid()
	if not data.nodes is Array or data.nodes.size()!=sim.frontier.nodes.size():return _invalid()
	for i in range(data.nodes.size()):
		if not _copy_fields(sim.frontier.nodes[i],data.nodes[i]):return _invalid()
	if not data.raiders is Array or data.raiders.size()>100:return _invalid()
	for saved in data.raiders:
		if not saved is Dictionary or not saved.get("state") is Dictionary:return _invalid()
		var enemy=sim._spawn_raider()
		if not _restore_fighter(enemy.fighter,saved.get("fighter")):return _invalid()
		var actor=enemy.fighter
		enemy=saved.state.duplicate(true)
		enemy.fighter=actor
		sim.raiders.append(enemy)
	if not data.hero_hits is Array:return _invalid()
	for index in data.hero_hits:
		if not index is int or index<0 or index>=sim.raiders.size():return _invalid()
		sim.hero._hit_targets[sim.raiders[index].fighter.get_instance_id()]=true
	if not data.opened is Dictionary:return _invalid()
	for key in data.opened:
		if not key.is_valid_int() or int(key)<0 or int(key)>=sim.frontier.nodes.size():return _invalid()
		sim.opened_chests[int(key)]=data.opened[key]
	if not sim.world.walls.has("wall"):return _invalid()
	sim.world.wall=sim.world.walls.wall
	return {"session":sim,"config":data.config,"body":data.body}

func _upgrade_v1(data: Dictionary) -> bool:
	# Upgrade only the known old stat shape; unknown fields still fail normal validation.
	if not data.hero is Dictionary or not data.raiders is Array or not data.config is Dictionary:return false
	var fighters: Array=[data.hero]
	for enemy in data.raiders:
		if not enemy is Dictionary or not enemy.get("fighter") is Dictionary:return false
		fighters.append(enemy.fighter)
	for fighter in fighters:
		if not fighter.get("stats") is Dictionary:return false
		if fighter.stats.has("attack_cost") or fighter.stats.has("jump_cost"):return false
		fighter.stats["attack_cost"]=0.0
		fighter.stats["jump_cost"]=0.0
	data.hero.stats.attack_cost=data.config.get("attack_stamina",12.0)
	data.hero.stats.jump_cost=data.config.get("jump_stamina",18.0)
	data.version=VERSION
	return true
