extends RefCounted
const Fighter = preload("res://domain/combatant.gd")
const Stats = preload("res://domain/combat_stats.gd")

func test_one_swing_hits_each_target_once(t) -> void:
	var hero = Fighter.new(Stats.new())
	var enemy = Fighter.new(Stats.new())
	t.truth(hero.start_attack(), "first swing starts")
	hero.advance(0.10)
	t.truth(hero.strike(enemy, 25.0), "front target receives hit")
	t.equal(enemy.hp, 75, "damage applied")
	t.equal(hero.strike(enemy, 25.0), false, "same swing cannot hit twice")
	t.equal(enemy.hp, 75, "duplicate hit does not change health")

func test_range_and_facing_do_not_consume_a_valid_hit(t) -> void:
	var hero = Fighter.new(Stats.new())
	var enemy = Fighter.new(Stats.new())
	hero.start_attack()
	hero.advance(0.10)
	t.equal(hero.strike(enemy, 200.0), false, "far target missed")
	t.equal(hero.strike(enemy, -25.0), false, "target behind missed")
	t.truth(hero.strike(enemy, 25.0), "target entering front arc can be hit")

func test_attack_window_and_cooldown(t) -> void:
	var hero = Fighter.new(Stats.new())
	var enemy = Fighter.new(Stats.new())
	hero.start_attack()
	hero.advance(0.3)
	t.equal(hero.strike(enemy, 25.0), false, "expired sword cannot deal damage")
	t.equal(hero.start_attack(), false, "cooldown still active")
	hero.advance(0.2)
	t.truth(hero.start_attack(), "next swing starts after cooldown")

func test_dash_spends_stamina_and_protects_health(t) -> void:
	var hero = Fighter.new(Stats.new())
	t.truth(hero.start_dash(), "dash starts")
	t.equal(hero.stamina, 70.0, "dash spends stamina")
	t.equal(hero.take_damage(40), false, "dash is invulnerable")
	hero.advance(0.3)
	t.truth(hero.take_damage(40), "damage after dash accepted")
	t.equal(hero.hp, 60, "health changed")
	hero.stamina = 0
	t.equal(hero.start_dash(), false, "not enough stamina")

func test_death_and_invalid_damage(t) -> void:
	var hero = Fighter.new(Stats.new())
	t.equal(hero.take_damage(-50), false, "negative damage rejected")
	t.equal(hero.hp, 100, "negative damage cannot heal")
	hero.take_damage(999)
	t.equal(hero.hp, 0, "health clamped at zero")
	t.equal(hero.start_attack(), false, "dead fighter cannot attack")
	t.equal(hero.start_dash(), false, "dead fighter cannot dash")

func test_negative_time_cannot_rewind_combat(t) -> void:
	var hero = Fighter.new(Stats.new())
	hero.start_attack()
	hero.advance(-5)
	t.equal(hero.start_attack(), false, "negative time ignored")

func test_sword_only_damages_during_downward_cut(t) -> void:
	var hero = Fighter.new(Stats.new())
	var enemy = Fighter.new(Stats.new())
	hero.start_attack()
	t.equal(hero.strike(enemy, 25.0), false, "windup cannot damage")
	hero.advance(0.10)
	t.truth(hero.strike(enemy, 25.0), "extended blade damages in active phase")
	hero.advance(0.08)
	var late_target = Fighter.new(Stats.new())
	t.equal(hero.strike(late_target, 25.0), false, "recovery cannot damage new targets")

func test_turning_during_swing_cannot_move_damage_behind_hero(t) -> void:
	var hero = Fighter.new(Stats.new())
	hero.start_attack()
	hero.facing = -1
	hero.advance(0.10)
	t.equal(hero.strike(Fighter.new(Stats.new()), -25.0), false, "swing keeps its original direction")
	t.truth(hero.strike(Fighter.new(Stats.new()), 25.0), "blade and damage still face right")

func test_short_cooldown_cannot_restart_an_unfinished_swing(t) -> void:
	var stats = Stats.new()
	stats.attack_duration = 1.0
	stats.attack_cooldown = 0.1
	var hero = Fighter.new(stats)
	hero.start_attack()
	hero.advance(0.2)
	t.equal(hero.start_attack(), false, "cooldown ending cannot interrupt an unfinished sword animation")

func test_dash_cancels_damage_in_every_swing_phase(t) -> void:
	for elapsed in [0.02, 0.12, 0.18]:
		var hero = Fighter.new(Stats.new())
		hero.start_attack()
		hero.advance(elapsed)
		t.truth(hero.start_dash(), "dash can cancel the current swing")
		t.equal(hero.attack_progress(), 1.0, "cancelled swing reports complete to presentation")
		t.equal(hero.strike(Fighter.new(Stats.new()), 25.0), false, "cancelled swing cannot damage")

func test_overhead_anticipation_cannot_damage_before_downward_cut(t) -> void:
	var hero = Fighter.new(Stats.new())
	var enemy = Fighter.new(Stats.new())
	hero.start_attack()
	hero.advance(0.07)
	t.equal(hero.strike(enemy, 25.0), false, "raised sword is still anticipation")
	hero.advance(0.03)
	t.truth(hero.strike(enemy, 25.0), "downward cut makes contact")
