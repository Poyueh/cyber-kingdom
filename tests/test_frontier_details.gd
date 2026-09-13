extends RefCounted
const Details=preload("res://presentation/frontier_details.gd")
const Frontier=preload("res://domain/frontier.gd")
func test_scenery_is_varied_reproducible_and_never_changes_harvests(t):
	var map=Frontier.new(42)
	var before=map.layout_signature()
	var first=Details.layout(42,map.regions)
	t.equal(first,Details.layout(42,map.regions),"same map reload retains all decorative placements")
	t.truth(first!=Details.layout(7,map.regions),"new seed rearranges scenery")
	var kinds={}
	for detail in first:
		kinds[detail.kind]=true
		var region=map.regions[detail.region]
		t.truth(detail.x>region.x and detail.x<region.x+region.width,"scenery stays in its own biome")
	t.truth(kinds.size()>=4,"map combines distinct scenic silhouettes")
	t.equal(map.layout_signature(),before,"cosmetics do not mutate harvest layout")
