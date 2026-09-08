extends RefCounted
const Stats = preload("res://domain/combat_stats.gd")

static func combat_stats(tuning: Resource) -> Stats:
	var stats := Stats.new()
	stats.max_hp = tuning.max_hp
	stats.damage = tuning.damage
	stats.attack_range = tuning.attack_range
	stats.attack_duration = tuning.attack_duration
	stats.attack_cooldown = tuning.attack_cooldown
	return stats
