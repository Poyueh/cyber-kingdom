extends RefCounted
const Stats = preload("res://domain/combat_stats.gd")

var stats: Stats
var shield: int = 0
var shield_absorbed: int = 0
var hp: int
var stamina: float
var facing: int = 1
var attack_facing: int = 1
var attack_remaining: float = 0.0
var cooldown_remaining: float = 0.0
var dash_remaining: float = 0.0
var invulnerability_remaining: float = 0.0
var _hit_targets: Dictionary = {}

func _init(configuration: Stats) -> void:
	stats = configuration
	hp = stats.max_hp
	stamina = stats.max_stamina

func is_alive() -> bool:
	return hp > 0

func start_attack() -> bool:
	if not is_alive() or attack_remaining > 0.0 or cooldown_remaining > 0.0 or dash_remaining > 0.0:
		return false
	attack_facing = facing
	attack_remaining = stats.attack_duration
	cooldown_remaining = stats.attack_cooldown
	_hit_targets.clear()
	return true

func start_dash() -> bool:
	if not is_alive() or dash_remaining > 0.0 or stamina < stats.dash_cost:
		return false
	stamina -= stats.dash_cost
	dash_remaining = stats.dash_duration
	invulnerability_remaining = maxf(invulnerability_remaining, stats.dash_invulnerability)
	# A dodge cancels the current sword swing, preventing an invisible attack.
	attack_remaining = 0.0
	return true

func strike(target: RefCounted, signed_distance: float) -> bool:
	if not is_alive() or not is_attack_active():
		return false
	if signed_distance * attack_facing < 0.0 or absf(signed_distance) > stats.attack_range:
		return false
	var target_id: int = target.get_instance_id()
	if _hit_targets.has(target_id):
		return false
	if not target.take_damage(stats.damage):
		return false
	_hit_targets[target_id] = true
	return true

func take_damage(amount: int) -> bool:
	if amount <= 0 or not is_alive() or invulnerability_remaining > 0.0:
		return false
	var absorbed := mini(maxi(0, shield), amount)
	shield = maxi(0, shield - absorbed)
	shield_absorbed += absorbed
	hp = maxi(0, hp - (amount - absorbed))
	invulnerability_remaining = stats.hurt_invulnerability
	return true

func advance(seconds: float) -> void:
	if seconds <= 0.0 or not is_finite(seconds):
		return
	attack_remaining = maxf(0.0, attack_remaining - seconds)
	cooldown_remaining = maxf(0.0, cooldown_remaining - seconds)
	dash_remaining = maxf(0.0, dash_remaining - seconds)
	invulnerability_remaining = maxf(0.0, invulnerability_remaining - seconds)
	if is_alive():
		stamina = minf(stats.max_stamina, stamina + stats.stamina_regen * seconds)

func attack_progress() -> float:
	if attack_remaining <= 0.0 or stats.attack_duration <= 0.0:
		return 1.0
	return clampf(1.0 - attack_remaining / stats.attack_duration, 0.0, 1.0)

func is_attack_active() -> bool:
	var progress := attack_progress()
	return progress >= 0.4 and progress < 0.75

func dash_progress() -> float:
	if dash_remaining <= 0.0 or stats.dash_duration <= 0.0:
		return 1.0
	return clampf(1.0 - dash_remaining / stats.dash_duration, 0.0, 1.0)
