extends "res://tools/preview_refuge.gd"
## Staged visual fixtures, not a default-budget playthrough.
const Helpers=preload("res://tests/test_campaign_objective.gd")
func at(x: float) -> void:
	scene.knight.position=Vector2(x,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	scene.paused=false
	scene._physics_process(1.0/60)
func capture() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	scene=load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	root.size=Vector2i(1440,810)
	await frames(8)
	scene.set_physics_process(false)
	scene.paused=false
	await picture("camp-core")
	await invest();await invest()
	scene.sim.mission.damage_core(60)
	await picture("core-recharge")
	scene.sim.mission.damage_core(500)
	scene._physics_process(1.0/60)
	await picture("core-loss")
	scene.restart()
	scene.sim.world.people.clear()
	var sim=scene.sim
	var gate: Dictionary=sim.mission.rifts[0]
	await at(gate.x)
	await picture("rift-locked")
	sim.frontier.city_level=2
	sim.clock.survived=1
	var helpers=Helpers.new()
	var worker=helpers.engineer(sim,gate.x+80)
	for i in range(4):await invest()
	for tick in range(60):
		await physics_frame
		scene._physics_process(1.0/60)
	await picture("rift-wardens")
	helpers.clear_wardens_with_sword(sim,gate.x)
	for frame in range(84):
		scene.paused=false
		for tick in range(6):
			await physics_frame
			scene._physics_process(1.0/60)
		await picture("seal-%03d" % frame)
	assert(gate.sealed)
	var other: Dictionary=sim.mission.rifts[1]
	worker.x=other.x-28
	await at(other.x)
	for i in range(4):await invest()
	scene._physics_process(1.0/60)
	helpers.clear_wardens_with_sword(sim,other.x)
	for tick in range(500):
		await physics_frame
		scene._physics_process(1.0/60)
	assert(sim.mission.outcome=="victory")
	await picture("victory")
	print("PASS: native mission visuals: core recharge/loss, prerequisites, guardians, 8-second seal, victory")
	scene.queue_free()
	await process_frame
	quit()
