extends RefCounted
func test_demotion_is_distinct_from_blocking_and_recruitment(t):
 var feedback=load("res://presentation/campaign_hit_feedback.gd").new()
 var sim=load("res://application/campaign_session.gd").new()
 sim.world.people[0].role="guard";feedback.present(sim)
 sim.world.barrier=1;sim.world.hit_person(0);feedback.present(sim)
 t.truth(not feedback.resident_pose(0).get("demoted",false),"blocked strike never shows lost occupation")
 sim.world.hit_person(0);feedback.present(sim)
 t.truth(feedback.resident_pose(0).get("demoted",false),"real loss of occupation has a separate readable cue")
 var held=feedback.resident_pose(0);feedback.present(sim)
 t.equal(feedback.resident_pose(0),held,"paused redraw freezes lost tool and role transition")
 sim.workforce.elapsed+=0.7;feedback.present(sim)
 t.truth(feedback.resident_pose(0).get("demoted",false),"identity transition lasts longer than a normal hit")
 sim.workforce.elapsed+=1.2;feedback.present(sim)
 t.truth(not feedback.resident_pose(0).get("demoted",false),"identity cue settles")
 sim.world.people[0].role="citizen";feedback.present(sim)
 t.truth(not feedback.resident_pose(0).get("demoted",false),"recruitment does not look like losing occupation")
func test_terminal_feedback_finishes_without_advancing_the_campaign(t):
 var feedback=load("res://presentation/campaign_hit_feedback.gd").new()
 var sim=load("res://application/campaign_session.gd").new()
 var enemy=sim._spawn_raider();sim.raiders.append(enemy);feedback.present(sim)
 enemy.fighter.take_damage(99999);sim.raiders.clear();feedback.present(sim)
 t.truth(feedback.has_method("advance_terminal"),"terminal presentation can finish while simulation is stopped")
 if not feedback.has_method("advance_terminal"):return
 var clock=sim.workforce.elapsed
 feedback.advance_terminal(0.5)
 t.equal(feedback.fallen.size(),1,"fatal silhouette remains long enough to read")
 feedback.advance_terminal(1.2)
 t.truth(feedback.fallen.is_empty(),"terminal silhouette eventually dissolves")
 t.equal(sim.workforce.elapsed,clock,"terminal animation never advances economy or raids")
func test_hero_death_falls_and_holds_instead_of_vanishing(t):
 var view=load("res://presentation/knight_visual.gd").new()
 var pose={"alive":true,"hp":100,"facing":1,"moving":false,"invulnerable":false}
 view.present(pose,0)
 pose.alive=false;pose.hp=0;view.present(pose,0.1)
 var first=view.rotation
 view.present(pose,0.5)
 t.truth(view.visible and absf(view.rotation)>absf(first),"dead knight visibly falls and stays on ground")
 var angle=view.rotation;view.present(pose,0)
 t.equal(view.rotation,angle,"paused death pose remains still")
 view.reset_pose();pose.alive=true;pose.hp=100;view.present(pose,0)
 t.truth(view.visible and is_zero_approx(view.rotation),"restart clears corpse pose")
 view.free()
