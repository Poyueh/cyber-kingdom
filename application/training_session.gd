extends RefCounted
const Fighter = preload("res://domain/combatant.gd")
const Stats = preload("res://domain/combat_stats.gd")
const ProgressStore = preload("res://application/ports/progress_store.gd")

var hero: Fighter
var enemy: Fighter
var scrap: int = 0
var save_pending: bool = false
var enemy_windup_remaining: float = 0.0
var hit_stop_seconds: float = 0.025
var _hit_stop_remaining: float = 0.0
var _hero_stats: Stats
var _enemy_stats: Stats
var _store: ProgressStore
var _reward: int
var _reward_claimed: bool = false

func _init(hero_stats: Stats, enemy_stats: Stats, store: ProgressStore, reward: int) -> void:
	_hero_stats = hero_stats
	_enemy_stats = enemy_stats
	_store = store
	_reward = maxi(0, reward)
	scrap = maxi(0, _store.load_scrap())
	restart_encounter()

func restart_encounter() -> void:
	hero = Fighter.new(_hero_stats)
	enemy = Fighter.new(_enemy_stats)
	_reward_claimed = false
	enemy_windup_remaining = 0.0
	_hit_stop_remaining = 0.0
	# Unsaved progress belongs to the session, not to an individual encounter.
	if save_pending:
		retry_save()

## Returns time available to gameplay; callers must use it for physics and visuals.
func advance(seconds: float) -> float:
	if seconds <= 0.0 or not is_finite(seconds):
		return 0.0
	var held := minf(seconds, _hit_stop_remaining)
	_hit_stop_remaining = maxf(0.0, _hit_stop_remaining - held)
	var gameplay_seconds := seconds - held
	hero.advance(gameplay_seconds)
	enemy.advance(gameplay_seconds)
	return gameplay_seconds

func resolve_sword(horizontal_distance: float, vertical_distance: float) -> bool:
	if absf(vertical_distance) > hero.stats.vertical_range:
		return false
	var landed := hero.strike(enemy, horizontal_distance)
	if landed:
		_begin_impact()
	if not enemy.is_alive() and not _reward_claimed:
		_reward_claimed = true
		scrap += _reward
		retry_save()
	return landed

func resolve_enemy_sword(horizontal_distance: float, vertical_distance: float) -> bool:
	if absf(vertical_distance) > enemy.stats.vertical_range:
		return false
	var landed := enemy.strike(hero, horizontal_distance)
	if landed:
		_begin_impact()
	return landed

func _begin_impact() -> void:
	if is_finite(hit_stop_seconds):
		_hit_stop_remaining = maxf(_hit_stop_remaining, clampf(hit_stop_seconds, 0.0, 0.15))

func retry_save() -> bool:
	save_pending = not _store.save_scrap(scrap)
	return not save_pending

## Returns movement intent; Node physics and positions remain in presentation.
func update_enemy_decision(seconds: float, distance_to_hero: float, vertical_distance: float) -> float:
	if not enemy.is_alive() or not hero.is_alive():
		return 0.0
	if enemy_windup_remaining > 0.0:
		enemy_windup_remaining = maxf(0.0, enemy_windup_remaining - maxf(0.0, seconds))
		if enemy_windup_remaining == 0.0:
			enemy.start_attack()
		return 0.0
	if absf(distance_to_hero) > 280.0:
		return 0.0
	enemy.facing = 1 if distance_to_hero >= 0 else -1
	if absf(distance_to_hero) > enemy.stats.attack_range - 8.0:
		return float(enemy.facing)
	if absf(vertical_distance) <= enemy.stats.vertical_range and enemy.cooldown_remaining <= 0.0:
		enemy_windup_remaining = 0.6
	return 0.0
