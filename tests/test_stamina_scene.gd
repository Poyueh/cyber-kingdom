extends "res://tests/test_scene.gd"
func run_scene() -> void:
	var game=load("res://scenes/frontier.tscn").instantiate()
	root.add_child(game);await frames(12)
	game.sim.hero.stats.stamina_regen=0
	game.sim.hero.stamina=0
	game.paused=false
	for code in [KEY_J,KEY_L,KEY_SPACE]:
		key(code,true);await frames(2);key(code,false);await frames(2)
	check(game.sim.hero.attack_remaining==0 and game.sim.hero.dash_remaining==0 and game.knight.is_on_floor(),"empty stamina blocks real attack, dash and jump input")
	game.sim.hero.stamina=50
	key(KEY_SPACE,true);await frames(2);key(KEY_SPACE,false)
	check(game.knight.velocity.y<0 and game.sim.hero.stamina==32,"successful physical jump consumes its cost once")
	key(KEY_SPACE,true);await frames(2);key(KEY_SPACE,false)
	check(game.sim.hero.stamina==32,"airborne repeat cannot consume jump stamina")
	check(game.hud.dashboard.values.stamina==32,"HUD reads remaining stamina from the live fighter")
	game.queue_free();await process_frame
	print("Stamina scene assertions: %d; failures: %d" % [assertions,failures])
	quit(0 if failures==0 else 1)
