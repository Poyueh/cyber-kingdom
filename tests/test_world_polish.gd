extends RefCounted
func test_top_equipment_unlocks_mount_without_consuming_shield(t):
 var growth=load("res://domain/knight_growth.gd").new()
 t.truth(growth.has_method("can_ride"),"top-tier riding rule exists")
 if not growth.has_method("can_ride"):return
 growth.capacitor_level=2
 t.truth(not growth.can_ride(3,3),"weapon alone cannot unlock mount")
 growth.capacitor_level=3
 t.truth(not growth.can_ride(2,3),"armor alone cannot unlock mount")
 t.truth(growth.can_ride(3,3),"both maximum equipment tiers unlock riding")
 t.equal(growth.capacity(),60,"riding does not consume shield capacity")
func test_exploration_reveal_advances_smoothly_and_freezes_with_time(t):
 var path="res://presentation/exploration_reveal.gd"
 t.truth(ResourceLoader.exists(path),"exploration reveal has a shared transition clock")
 if not ResourceLoader.exists(path):return
 var reveal=load(path).new()
 var regions=[{"discovered":false},{"discovered":true}]
 reveal.observe(regions,10)
 t.equal(reveal.amount(0),0.0,"unknown objects remain hidden")
 t.equal(reveal.amount(1),1.0,"restored explored regions remain visible")
 regions[0].discovered=true;reveal.observe(regions,11)
 t.equal(reveal.amount(0),0.0,"discovery cannot flash objects fully visible")
 reveal.observe(regions,11.8);var halfway: float=reveal.amount(0)
 t.truth(halfway>0 and halfway<1,"objects fade in progressively")
 reveal.observe(regions,11.8);t.equal(reveal.amount(0),halfway,"pause freezes transition")
 reveal.observe(regions,13);t.equal(reveal.amount(0),1.0,"exploration finishes revealing")
func test_repeating_tiles_cover_camera_edges_and_keep_world_phase(t):
 var path="res://presentation/scenery_tiles.gd"
 t.truth(ResourceLoader.exists(path),"seamless tile layout exists")
 if not ResourceLoader.exists(path):return
 var tiles=load(path)
 for left in [-2401.0,-1.0,0.0,3839.9,3840.1]:
  var spans: Array=tiles.layout(Rect2(left,0,1240,430),960,0.25)
  t.truth(spans[0].x<=left and spans.back().x+960>=left+1240,"tiles cover both sides at every wrap")
  for i in range(1,spans.size()):
   t.truth(is_equal_approx(spans[i].x,spans[i-1].x+960),"neighbor tiles leave no gaps")
   t.truth(spans[i].flip!=spans[i-1].flip,"alternating ends meet the same source edge")
