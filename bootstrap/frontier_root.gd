extends "res://bootstrap/settlement_root.gd"
const FrontierSession = preload("res://application/campaign_session.gd")
const Platform = preload("res://scenes/platform.tscn")
var _map_seed: int
var _seed_initialized := false
var _requested_new_map := false
var _terrain: Node2D

func _ready() -> void:
	super._ready()
	hud.new_map_requested.connect(func(): _requested_new_map = true)
	controls.new_map_requested.connect(func(): _requested_new_map = true)

func restart() -> void:
	if not _seed_initialized:
		_map_seed = tuning.map_seed
		_seed_initialized = true
	var config := {"seed":_map_seed,"economy":tuning.economy_rules(),"scrap":tuning.starting_scrap,"crystals":tuning.starting_crystals,
		"first_raid":tuning.first_raid_seconds,"raid_gap":tuning.raid_gap_seconds,
		"person_speed":tuning.resident_speed,"shield_value":tuning.shield_per_crystal}
	config.merge(tuning.campaign_rules(),true)
	sim = FrontierSession.new(config,Mapper.combat_stats(knight_tuning))
	knight.configure(sim.hero,knight_tuning)
	knight.position = Vector2(30,430)
	paused = false
	_requested_interaction = false
	controls.release_all()
	_build_terrain()

func _physics_process(seconds: float) -> void:
	if _requested_new_map:
		_requested_new_map = false
		_map_seed += 1
		restart()
	super._physics_process(seconds)

func _build_terrain() -> void:
	var map = sim.frontier
	var shape := RectangleShape2D.new()
	shape.size = Vector2(map.right_boundary-map.left_boundary,110)
	$Floor/Shape.shape = shape
	$Floor.position.x = (map.left_boundary+map.right_boundary)*0.5
	$LeftWall.position.x = map.left_boundary-10
	$RightWall.position.x = map.right_boundary+10
	$Knight/Camera2D.limit_left = int(map.left_boundary)
	$Knight/Camera2D.limit_right = int(map.right_boundary)
	$Knight/Camera2D.reset_smoothing()
	if is_instance_valid(_terrain):
		remove_child(_terrain)
		_terrain.queue_free()
	_terrain = Node2D.new()
	_terrain.name = "GeneratedTerrain"
	add_child(_terrain)
	for resource in map.nodes:
		if resource.y >= 430: continue
		var platform = Platform.instantiate()
		platform.position = Vector2(resource.x,resource.y+7)
		platform.width = 140
		platform.z_index = 1
		_terrain.add_child(platform)
