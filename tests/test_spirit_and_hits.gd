extends RefCounted
func test_spirit_follows_ignored_advice_without_moving_the_target(t):
 var path="res://presentation/spirit_motion.gd"
 t.truth(ResourceLoader.exists(path),"spirit motion exists")
 if not ResourceLoader.exists(path):return
 var motion=load(path).new()
 var hint={"x":900.0,"y":430.0}
 var safe=Rect2(0,0,960,540)
 var first=motion.sample(hint,Vector2(300,420),300,safe,0.0)
 t.equal(first.direction,1.0,"spirit points toward a target to the right")
 var followed=motion.sample(hint,Vector2(80,400),-500,safe,0.2)
 t.truth(followed.position.distance_to(Vector2(80,400))<180,"ignoring advice keeps the spirit beside the knight")
 t.equal(hint.x,900.0,"following never moves the suggested world target")
 t.equal(motion.sample(hint,Vector2(80,400),-500,safe,0.2),followed,"pause freezes companion motion")
 t.equal(motion.sample({"x":-900.0,"y":430.0},Vector2(500,400),100,safe,0.4).direction,-1.0,"crossing a target reverses pointing")
 t.equal(motion.sample({},Vector2.ZERO,0,safe,0.5).visible,false,"completed advice dismisses the spirit")
func test_hits_require_lost_health_or_shield_and_recover(t):
 var path="res://presentation/hit_reaction.gd"
 t.truth(ResourceLoader.exists(path),"hit reaction exists")
 if not ResourceLoader.exists(path):return
 var reaction=load(path).new()
 t.truth(not reaction.observe(100,20,0,1).active,"first observation cannot invent damage")
 var blocked=reaction.observe(100,10,0,1)
 t.equal(blocked.kind,"shield","shield absorption has its own reaction")
 t.truth(blocked.offset.length()>0,"blocking visibly braces the body")
 reaction.observe(100,10,0.5,1)
 var hurt=reaction.observe(85,0,0,-1)
 t.equal(hurt.kind,"hurt","lost life selects bodily recoil")
 t.truth(hurt.rotation<0 and hurt.flash>0,"impact leans away and flashes")
 t.equal(reaction.observe(85,0,0,1),hurt,"paused redraw preserves impact direction and pose")
 t.truth(not reaction.observe(85,0,0.5,1).active,"reaction settles completely")
 t.truth(not reaction.observe(100,20,0,1).active,"healing or equipment upgrades cannot trigger hurt")
func test_knight_dash_is_not_mistaken_for_damage(t):
 var view=load("res://presentation/knight_visual.gd").new()
 var pose={"alive":true,"facing":1,"moving":false,"invulnerable":false,"hp":100,"shield":0}
 view.present(pose,0)
 pose.invulnerable=true;pose.dashing=true
 view.present(pose,0.05)
 t.truth(not view.get("hurt_active"),"dash invulnerability does not trigger recoil")
 pose.dashing=false;pose.hp=80
 view.present(pose,0.01)
 t.equal(view.get("hurt_active"),true,"real health loss overrides idle with recoil")
 t.truth(absf(view.rotation)>0.05,"knight physically leans when hurt")
 view.reset_pose()
 t.truth(not view.get("hurt_active"),"restart clears injury presentation")
 view.free()
func test_residents_and_enemies_react_to_real_damage_only(t):
 var path="res://presentation/campaign_hit_feedback.gd"
 t.truth(ResourceLoader.exists(path),"campaign hit feedback exists")
 if not ResourceLoader.exists(path):return
 var feedback=load(path).new()
 var sim=load("res://application/campaign_session.gd").new()
 sim.world.people[0].role="guard"
 var enemy=sim._spawn_raider();sim.raiders.append(enemy)
 feedback.present(sim)
 sim.world.barrier=1;sim.world.hit_person(0)
 feedback.present(sim)
 t.truth(not feedback.resident_pose(0).active,"ward absorption cannot play resident injury")
 sim.world.hit_person(0)
 feedback.present(sim)
 t.truth(feedback.resident_pose(0).active,"real resident hit recoils")
 t.equal(feedback.resident_pose(0).role,"guard","job silhouette stays visible during recoil before becoming wanderer")
 enemy.fighter.take_damage(5);feedback.present(sim)
 t.truth(feedback.enemy_pose(enemy).active,"enemy health loss recoils")
 var held=feedback.enemy_pose(enemy)
 feedback.present(sim)
 t.equal(feedback.enemy_pose(enemy),held,"paused world freezes enemy reaction")
 sim.workforce.elapsed+=0.5;feedback.present(sim)
 t.truth(not feedback.enemy_pose(enemy).active,"enemy returns to normal after recovery")
 enemy.fighter.invulnerability_remaining=0;enemy.fighter.take_damage(999)
 sim.raiders.clear();feedback.present(sim)
 t.equal(feedback.fallen.size(),1,"fatal hit retains a brief falling silhouette")
 sim.workforce.elapsed+=0.6;feedback.present(sim)
 t.equal(feedback.fallen.size(),0,"defeated silhouettes expire")
 var next=load("res://application/campaign_session.gd").new()
 feedback.present(next)
 t.truth(not feedback.resident_pose(0).active,"new run clears all old injury memory")
func test_spirit_points_back_at_a_reached_target(t):
 var motion=load("res://presentation/spirit_motion.gd").new()
 var pose=motion.sample({"x":30.0,"y":430.0},Vector2(300,420),30,Rect2(0,0,960,540),0)
 t.truth((pose.position.x-300)*pose.direction<0,"at camp the hovering spirit points toward camp, not away from it")

func test_spirit_leaves_the_targets_interaction_column_clear(t):
 var motion=load("res://presentation/spirit_motion.gd").new()
 var pose=motion.sample({"x":130.0,"y":430.0},Vector2(300,420),30,Rect2(0,0,960,540),0)
 t.truth(absf(pose.position.x-400)>64 and pose.direction>0,"companion stays clear of the nearby target health and payment icons")
