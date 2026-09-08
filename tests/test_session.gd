extends RefCounted
const Session = preload("res://application/training_session.gd")
const Stats = preload("res://domain/combat_stats.gd")
const MemoryStore = preload("res://infrastructure/memory_progress_store.gd")

func test_defeat_rewards_once_and_persists(t) -> void:
	var store = MemoryStore.new()
	var hero_stats = Stats.new()
	hero_stats.damage = 200
	var run = Session.new(hero_stats, Stats.new(), store, 20)
	run.hero.start_attack()
	run.resolve_sword(25.0, 0.0)
	run.resolve_sword(25.0, 0.0)
	t.equal(run.scrap, 20, "one defeat grants one reward")
	t.equal(store.load_scrap(), 20, "reward persisted through port")
	t.equal(store.writes, 1, "no duplicate save")

func test_vertical_miss_and_restart(t) -> void:
	var run = Session.new(Stats.new(), Stats.new(), MemoryStore.new(), 20)
	run.hero.start_attack()
	run.resolve_sword(25.0, 100.0)
	t.equal(run.enemy.hp, 100, "target on another floor missed")
	run.hero.take_damage(999)
	run.restart_encounter()
	t.equal(run.hero.hp, 100, "restart restores fighter")
	t.equal(run.scrap, 0, "restart cannot fabricate rewards")

func test_failed_save_reports_pending_and_can_retry(t) -> void:
	var store = MemoryStore.new()
	store.accept_writes = false
	var stats = Stats.new()
	stats.damage = 200
	var run = Session.new(stats, Stats.new(), store, 20)
	run.hero.start_attack()
	run.resolve_sword(25.0, 0.0)
	t.truth(run.save_pending, "failed write is visible")
	t.equal(run.scrap, 20, "in-memory reward preserved")
	store.accept_writes = true
	t.truth(run.retry_save(), "retry succeeds")
	t.equal(run.save_pending, false, "pending cleared")
	t.equal(store.load_scrap(), 20, "retry does not duplicate reward")

func test_enemy_telegraphs_before_attack(t) -> void:
	var run = Session.new(Stats.new(), Stats.new(), MemoryStore.new(), 20)
	run.update_enemy_decision(0.1, -25.0, 0.0)
	t.equal(run.enemy.attack_remaining, 0.0, "enemy warns before damage")
	t.truth(run.enemy_windup_remaining > 0.0, "warning is visible to presentation")
	run.update_enemy_decision(0.7, -25.0, 0.0)
	run.resolve_enemy_sword(-25.0, 0.0)
	t.equal(run.hero.hp, 75, "announced attack resolves toward hero")
