extends "res://tools/play_campaign.gd"
## End-to-end save/reopen using the same physical-input player and standard economy.
const Codec=preload("res://application/campaign_snapshot.gd")
const Rules=preload("res://application/campaign_checkpoint_rules.gd")
var next_checkpoint:=120.0
var resumes:=0
var cycling:=false
var checkpoint_path: String
func start() -> void:
	ProjectSettings.set_setting("campaign/persistence_enabled",true)
	checkpoint_path=output+".checkpoint.json"
	assert(not FileAccess.file_exists(checkpoint_path),"Use a new output path for an isolated run.")
	scene=load("res://scenes/frontier.tscn").instantiate()
	scene.campaign_save_path=checkpoint_path
	scene.tuning=scene.tuning.duplicate()
	scene.tuning.map_seed=run_seed
	root.add_child(scene)
	physics_frame.connect(tick)
func tick() -> void:
	if cycling:return
	if elapsed>=next_checkpoint and scene.sim.is_running():
		cycling=true
		call_deferred("reopen")
		return
	super.tick()
func reopen() -> void:
	scene._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	assert(scene.progress.status=="saved",scene.progress.last_error)
	var codec=Codec.new()
	var body={"x":scene.knight.position.x,"y":scene.knight.position.y,"vx":scene.knight.velocity.x,"vy":scene.knight.velocity.y}
	var before=codec.capture(scene.sim,scene._campaign_config,body)
	scene.queue_free()
	await process_frame
	scene=load("res://scenes/frontier.tscn").instantiate()
	scene.campaign_save_path=checkpoint_path
	root.add_child(scene)
	for i in range(3):await physics_frame
	assert(scene.paused and scene.progress.status=="saved","Reopen must restore and pause.")
	body={"x":scene.knight.position.x,"y":scene.knight.position.y,"vx":scene.knight.velocity.x,"vy":scene.knight.velocity.y}
	assert(Rules.same(before,codec.capture(scene.sim,scene._campaign_config,body)),"Reopen changed campaign state.")
	resumes+=1
	print("CHECKPOINT_RESUMED ",resumes," at ",elapsed)
	next_checkpoint+=120
	scene.paused=false
	cycling=false
