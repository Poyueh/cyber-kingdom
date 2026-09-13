extends "res://bootstrap/settlement_root.gd"
const FrontierSession = preload("res://application/campaign_session.gd")
const InvestmentHold = preload("res://application/investment_hold.gd")
const CampaignProgress=preload("res://application/campaign_progress.gd")
const CampaignStore=preload("res://infrastructure/json_campaign_store.gd")
@export var campaign_save_path: String="user://campaign_v1.json"
@export_range(1.0,60.0,1.0) var autosave_seconds: float=5.0
@onready var audio=$CampaignAudio
var progress: RefCounted
var _campaign_config: Dictionary={}
var _save_elapsed:=0.0
var investment: RefCounted
const Platform = preload("res://scenes/platform.tscn")
var _map_seed: int
var _seed_initialized := false
var _requested_new_map := false
var _terrain: Node2D
var _requested_throw := false

func _ready() -> void:
	super._ready()
	hud.audio_toggled.connect(func():
		audio.enabled=not audio.enabled
		hud.set_audio_enabled(audio.enabled))
	hud.set_audio_enabled(audio.enabled)
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
	hud.save_requested.connect(save_campaign)
	if not campaign_save_path.is_empty() and ProjectSettings.get_setting("campaign/persistence_enabled",true) and (campaign_save_path!="user://campaign_v1.json" or "--no-campaign-save" not in OS.get_cmdline_user_args()):
		progress=CampaignProgress.new(CampaignStore.new(campaign_save_path))
		var restored: Dictionary=progress.open()
		if not restored.is_empty():
			sim=restored.session
			_campaign_config=restored.config
			_map_seed=sim.map_seed
			knight.configure(sim.hero,knight_tuning)
			knight.position=Vector2(restored.body.x,restored.body.y)
			knight.velocity=Vector2(restored.body.vx,restored.body.vy)
			_build_terrain()
			paused=true
		elif progress.status=="protected":
			paused=true
		else:save_campaign()
		knight.refresh_visual(0.0)
		view.present(sim,knight.position.x)
		hud.present_world(sim,paused,knight.position.x,knight.is_on_floor())
	_present_save()
	audio.observe(0,sim,knight.position.x,true)

func restart() -> void:
	if progress!=null:
		# Explicit restart archives the last run; failed storage cannot discard it.
		if progress.status!="protected" and not save_campaign():return
		if not progress.archive():
			_present_save()
			return
	if not _seed_initialized:
		_map_seed = tuning.map_seed
		_seed_initialized = true
	var config := {"seed":_map_seed,"economy":tuning.economy_rules(),"scrap":tuning.starting_scrap,"crystals":tuning.starting_crystals,
		"first_raid":tuning.first_raid_seconds,"raid_gap":tuning.raid_gap_seconds,
		"person_speed":tuning.resident_speed,"shield_value":tuning.shield_per_crystal}
	config.merge(tuning.campaign_rules(),true)
	_campaign_config=config
	sim = FrontierSession.new(config,Mapper.knight_stats(knight_tuning,combo_tuning))
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
	hud.cancel_touch_gestures()
	_build_terrain()
	if progress!=null:save_campaign()
	if is_instance_valid(audio):audio.observe(0,sim,knight.position.x,true)

func _physics_process(seconds: float) -> void:
	if _requested_new_map:
		_requested_new_map = false
		_map_seed += 1
		restart()
		_map_seed=sim.map_seed
	var was_paused:=paused
	var was_running:=sim.is_running()
	super._physics_process(seconds)
	if paused and not was_paused:hud.cancel_touch_gestures()
	if _requested_throw and not paused:
		sim.throw_crystal(knight.position.x,knight.position.y,sim.hero.facing)
		hud.present_world(sim,paused,knight.position.x,knight.is_on_floor())
	_requested_throw = false
	if paused or not sim.is_running():
		investment.cancel()
		hud.interact_held=false
		_sync_investment_focus()
	if not paused and sim.is_running():_save_elapsed+=seconds
	if (paused and not was_paused) or (was_running and not sim.is_running()) or _save_elapsed>=autosave_seconds:
		save_campaign()
	_present_save()
	audio.observe(seconds,sim,knight.position.x,paused)

func _apply_interaction(command: Dictionary, seconds: float) -> void:
	var held: bool=command.interaction_held or hud.interact_held or _requested_interaction
	investment.step(seconds,held,knight.is_on_floor() and not (command.jump or command.jump_held) and sim.is_running(),sim,knight.position.x)
	_sync_investment_focus()

func _sync_investment_focus() -> void:
	view.focus_key=investment.target_key
	hud.focus_key=investment.target_key
	view.investment_progress=investment.progress()

func _notification(what: int) -> void:
	super._notification(what)
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		_requested_throw = false
		if is_instance_valid(audio):audio.stop()
		if investment!=null: investment.cancel()
		if is_instance_valid(hud): hud.cancel_touch_gestures()
		if progress!=null:save_campaign()
	if what==NOTIFICATION_WM_CLOSE_REQUEST and progress!=null:save_campaign()

func save_campaign() -> bool:
	if progress==null:return true
	_save_elapsed=0.0
	var result: bool=progress.save(sim,_campaign_config,{"x":knight.position.x,"y":knight.position.y,"vx":knight.velocity.x,"vy":knight.velocity.y})
	_present_save()
	return result

func _present_save() -> void:
	if is_instance_valid(hud):hud.present_save(progress.status if progress!=null else "disabled",paused)

func _exit_tree() -> void:
	if progress!=null and is_instance_valid(knight):save_campaign()


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
