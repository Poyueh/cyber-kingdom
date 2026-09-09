extends RefCounted
const Allocation = preload("res://domain/crystal_allocation.gd")
const Battle = preload("res://application/training_session.gd")
const Stats = preload("res://domain/combat_stats.gd")
const Store = preload("res://application/ports/progress_store.gd")
enum Phase { ALLOCATION, EXPEDITION, RESULT }
var phase: Phase = Phase.ALLOCATION
var battle: Battle
var _allocation: Allocation
var _hero_stats: Stats
var _enemy_stats: Stats
var _store: Store
var _report: Dictionary = {}
var _starting_scrap: int = 0

func _init(hero_stats: Stats, enemy_stats: Stats, store: Store, crystals: int, shield_value: int, residents: int) -> void:
	_hero_stats = hero_stats
	_enemy_stats = enemy_stats
	_store = store
	_allocation = Allocation.new(crystals, shield_value, residents)

func allocate(amount: int) -> bool:
	return phase == Phase.ALLOCATION and _allocation.choose(amount)

func preview() -> Dictionary:
	return _allocation.preview()

func depart() -> bool:
	if phase != Phase.ALLOCATION:
		return false
	battle = Battle.new(_hero_stats, _enemy_stats, _store, 20)
	_starting_scrap = battle.scrap
	battle.hero.shield = _allocation.preview().knight_shield
	phase = Phase.EXPEDITION
	return true

## Settlement snapshots combat once. Later UI reads cannot alter the result.
func finish() -> Dictionary:
	if phase == Phase.ALLOCATION:
		return {}
	if phase == Phase.RESULT:
		return _report.duplicate(true)
	var outcome := "retreat"
	if not battle.hero.is_alive():
		outcome = "defeat"
	elif not battle.enemy.is_alive():
		outcome = "victory"
	_report = _allocation.preview()
	_report.merge({"outcome": outcome, "hero_hp": battle.hero.hp,
		"shield_remaining": battle.hero.shield, "absorbed": battle.hero.shield_absorbed,
		"recovered": battle.scrap - _starting_scrap})
	phase = Phase.RESULT
	return _report.duplicate(true)

func restart() -> bool:
	if phase == Phase.EXPEDITION:
		return false
	_allocation.choose(0)
	battle = null
	_report.clear()
	phase = Phase.ALLOCATION
	return true
