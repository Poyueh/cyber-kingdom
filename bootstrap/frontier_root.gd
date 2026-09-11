extends "res://bootstrap/settlement_root.gd"
const FrontierSession = preload("res://application/campaign_session.gd")
const InvestmentHold = preload("res://application/investment_hold.gd")
var investment: RefCounted
const Platform = preload("res://scenes/platform.tscn")
var _map_seed: int
var _seed_initialized := false
var _requested_new_map := false
var _terrain: Node2D
var _requested_throw := false

func _ready() -> void:
	super._ready()
	view.crystal_radius=tuning.crystal_radius
	hud.throw_requested.connect(func(): _requested_throw = true)
	controls.throw_requested.connect(func(): _requested_throw = true)
	$Knight/Camera2D.zoom=Vector2.ONE*tuning.camera_zoom
	if tuning.larger_desktop_window and DisplayServer.get_name()!= "headless" and not OS.has_feature("mobile"):
		var window:=get_window()
		var usable:=DisplayServer.screen_get_usable_rect()
		window.size=Vector2i(mini(1440,usable.size.x-60),mini(810,usable.size.y-60))
		window.position=usable.position+(usable.size-window.size)/2
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
	investment=InvestmentHold.new(tuning.investment_hold_delay,tuning.investment_interval)
	investment.cancel()
	hud.interact_held=false
	_sync_investment_focus()
	paused = false
	_requested_interaction = false
	_requested_throw = false
	controls.release_all()
	_build_terrain()

func _physics_process(seconds: float) -> void:
	if _requested_new_map:
		_requested_new_map = false
		_map_seed += 1
		restart()
	super._physics_process(seconds)
	if _requested_throw and not paused:
		sim.throw_crystal(knight.position.x,knight.position.y,sim.hero.facing)
		hud.present_world(sim,paused,knight.position.x,knight.is_on_floor())
	_requested_throw = false
	if paused or not sim.hero.is_alive():
		investment.cancel()
		hud.interact_held=false
		_sync_investment_focus()

func _apply_interaction(command: Dictionary, seconds: float) -> void:
	var held: bool=command.interaction_held or hud.interact_held or _requested_interaction
	investment.step(seconds,held,knight.is_on_floor() and not (command.jump or command.jump_held) and sim.hero.is_alive(),sim,knight.position.x)
	_sync_investment_focus()

func _sync_investment_focus() -> void:
	view.focus_key=investment.target_key
	hud.focus_key=investment.target_key
	view.investment_progress=investment.progress()

func _notification(what: int) -> void:
	super._notification(what)
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		_requested_throw = false
		if investment!=null: investment.cancel()
		if is_instance_valid(hud): hud.interact_held=false

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
