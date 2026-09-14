extends SceneTree
func _initialize() -> void:
	var Sim=preload("res://application/campaign_session.gd")
	for seed in [742601,1,7,42]:
		var old=Sim.new({"seed":seed})
		var expanded=Sim.new({"seed":seed,"economy":{"outer_regions_per_side":3}})
		print(JSON.stringify({"seed":seed,"old_width":old.frontier.right_boundary-old.frontier.left_boundary,"new_width":expanded.frontier.right_boundary-expanded.frontier.left_boundary,"left":expanded.frontier.left_boundary,"right":expanded.frontier.right_boundary,"regions":expanded.frontier.regions.size(),"nodes":expanded.frontier.nodes.size(),"old_nodes":old.frontier.nodes.size()}))
	quit()
