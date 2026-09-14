extends RefCounted
const Campaign=preload("res://application/campaign_session.gd")
func engineer(sim,x):
 sim.world.people.clear();sim.world.people.append({"role":"engineer","x":float(x),"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1})
func test_night_builds_inside_defenses_but_does_not_leave_for_outer_order(t):
 var sim=Campaign.new();sim.frontier.city_level=2
 for id in ["wall","wall_left"]:sim.world.walls[id].merge({"level":1,"hp":40},true)
 engineer(sim,sim.world.sites.wall-12)
 sim.world.wall.pending=true;sim.clock.is_night=true;sim.clock.remaining=100
 for i in range(40):sim.advance(0.1,30)
 t.equal(sim.world.wall.level,2,"engineer can finish safe wall upgrade at night")
 var outside=sim.world.walls["frontier_wall:3"];outside.pending=true
 for i in range(40):sim.advance(0.1,30)
 t.equal(outside.progress,0.0,"night worker does not leave the defensive perimeter")
func test_tower_needs_construction_and_three_tiers_have_real_firepower(t):
 var sim=Campaign.new();sim.frontier.city_level=3
 t.truth(sim.has_method("building_context"),"tower has explicit construction and upgrade rules")
 if not sim.has_method("building_context"):return
 engineer(sim,sim.world.sites.beacon)
 for level in range(1,4):
  sim.pouch.amount=12
  var choice=sim.context(sim.world.sites.beacon)
  for i in range(choice.cost):sim.interact(choice.x,choice.key)
  t.equal(sim.buildings.beacon.level,level-1,"paying alone never builds a tower instantly")
  for i in range(50):sim.advance(0.1,30)
  t.equal(sim.buildings.beacon.level,level,"engineer completes tower tier")
  var enemy=sim._spawn_raider();enemy.x=sim.world.sites.beacon+100;enemy.fighter.hp=enemy.fighter.stats.max_hp
  sim.raiders.append(enemy);sim.buildings.beacon.cooldown=0
  var hp=enemy.fighter.hp;sim.advance(0.02,30)
  t.truth(enemy.fighter.hp<hp,"completed tower actually damages invaders")
  t.truth(sim.effects.any(func(e):return e.kind==("tower_laser" if level==3 else "tower_arrow")),"weapon tier has a matching visible shot")
  sim.raiders.clear()
 t.truth(not sim.context(sim.world.sites.beacon).enabled,"maximum tower tier stops taking crystals")
func test_cleared_plots_are_seeded_varied_and_do_not_reroll_on_load(t):
 var sim=Campaign.new({"seed":42});sim.frontier.city_level=1
 t.truth(sim.has_method("building_context"),"cleared ground can become functional buildings")
 if not sim.has_method("building_context"):return
 var kinds={}
 for id in sim.buildings:
  var site=sim.buildings[id]
  if site.node<0:continue
  kinds[site.kind]=true
  t.truth(not sim.building_visible(id),"standing resources hide the future plot")
  sim.frontier.regions[site.region].discovered=true
  for node in sim.frontier.nodes:
   if absf(node.x-site.x)<90:node.collected=true
  t.truth(sim.building_visible(id),"cleared footprint reveals its seeded building icon")
 t.equal(kinds.size(),3,"clearing includes wall tower and farm possibilities")
 var codec=load("res://application/campaign_snapshot.gd").new()
 var restored=codec.restore(codec.capture(sim,{"seed":42},{"x":30.0,"y":430.0,"vx":0.0,"vy":0.0}))
 t.truth(not restored.is_empty(),"plots save and restore")
 if not restored.is_empty():t.truth(load("res://application/campaign_checkpoint_rules.gd").same(restored.session.buildings,sim.buildings),"loading cannot reroll a cleared plot")
func test_fortress_is_a_third_paid_tier_with_more_health(t):
 var sim=Campaign.new();sim.frontier.city_level=3
 sim.world.wall.merge({"level":2,"hp":80},true);engineer(sim,1088)
 var choice=sim.context(1100)
 t.truth(choice.enabled,"stone wall can be upgraded to fortress")
 for i in range(choice.cost):sim.interact(1100,choice.key)
 for i in range(50):sim.advance(0.1,30)
 t.equal(sim.world.wall.level,3,"engineer builds fortress tier")
 t.truth(sim.world.wall.hp>80,"fortress endures more damage than stone")
func test_expanded_field_requires_farmer_and_produces_at_its_own_location(t):
 var sim=Campaign.new({"seed":42});sim.frontier.city_level=1
 var field: Dictionary={}
 for site in sim.buildings.values():
  if site.kind=="farm":field=site;break
 t.truth(not field.is_empty(),"seed contains a farm plot")
 if field.is_empty():return
 field.level=1
 sim.world.people.clear()
 sim._advance_farm(24,0)
 t.equal(sim.pouch.ground_total(),0,"unattended field produces nothing")
 sim.world.people.append({"role":"farmer","x":field.x,"hurt":0.0,"cooldown":0.0,"region":-1})
 for i in range(130):sim._advance_people(0.1)
 t.truth(sim.pouch.ground_total()>=2,"farmer actually cultivates the expanded field")
 t.truth(sim.pouch.drops.all(func(g):return absf(g.x-field.x)<30),"harvest appears beside the worked field")
func test_v5_keeps_wall_damage_and_old_civilian_protection(t):
 var codec=load("res://application/campaign_snapshot.gd").new()
 var raw=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/campaign-v5.json"))
 var original=raw.duplicate(true);var loaded=codec.restore(raw)
 t.truth(not loaded.is_empty(),"genuine v5 checkpoint upgrades")
 t.equal(raw,original,"original checkpoint is never modified")
 if loaded.is_empty():return
 t.equal(loaded.session.world.barrier,2,"previously purchased civilian protection remains")
 t.equal(loaded.session.buildings.beacon.level,1,"existing tower becomes an operational first tier")
 t.equal(loaded.session.world.wall.hp,35,"migration does not magically repair walls")
 t.equal(loaded.session.context(1100).paid,1,"partially funded repair is retained")
func test_tower_second_tier_fires_more_often_and_pause_time_does_not_fire(t):
 var counts=[]
 for tier in [1,2]:
  var sim=Campaign.new();sim.buildings.beacon.level=tier
  var enemy=sim._spawn_raider();enemy.x=990;enemy.fighter.stats.max_hp=10000;enemy.fighter.hp=10000;enemy.fighter.stats.hurt_invulnerability=0
  sim.raiders.append(enemy)
  sim.advance(0,30);t.equal(enemy.fighter.hp,10000,"zero simulation time does not shoot")
  for i in range(200):sim._advance_towers(0.01)
  counts.append(10000-enemy.fighter.hp)
 t.truth(counts[1]>counts[0],"rapid crossbow deals more volleys over equal time")
func test_night_work_stops_when_the_outer_wall_breaks(t):
 var sim=Campaign.new();sim.frontier.city_level=3
 for id in ["wall","wall_left"]:sim.world.walls[id].merge({"level":1,"hp":40},true)
 engineer(sim,890);sim.buildings.beacon.pending=true
 sim.clock.is_night=true;sim.clock.remaining=100
 sim.advance(0.1,30);var progress=sim.buildings.beacon.progress
 t.truth(progress>0,"protected night construction starts")
 sim.world.wall.hp=0
 sim.advance(0.1,30)
 t.equal(sim.buildings.beacon.progress,progress,"lost defense pauses exposed tower construction")
 t.truth(sim.world.people[0].x<890,"exposed worker retreats toward the core")
func test_outpost_and_cleared_plot_remain_separate_payment_targets(t):
 var sim=Campaign.new({"seed":42});sim.frontier.city_level=2
 for site in sim.buildings.values():
  if site.node<0:continue
  var region=sim.frontier.regions[site.region]
  region.discovered=true;region.outpost_ready=true;region.outpost_x=site.x
  for node in sim.frontier.nodes:
   if node.region==site.region:node.collected=true
  sim._advance_people(0.01)
  t.truth(absf(region.outpost_x-site.x)>=100,"depot is separated from seeded blueprint")
  t.equal(sim.context(region.outpost_x).id,"outpost","depot investment remains reachable")
  break
