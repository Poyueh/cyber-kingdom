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

static func knight_stats(tuning: Resource, combo: Resource) -> Stats:
	var stats := combat_stats(tuning)
	stats.attack_movement_locked = true
	stats.combo_return_step = combo.return_step_distance
	stats.combo_finisher_step = combo.finisher_step_distance
	stats.combo_enabled = combo.enabled
	stats.combo_buffer_seconds = combo.input_buffer_seconds
	stats.combo_grace_seconds = combo.followup_grace_seconds
	stats.combo_chain_progress = combo.chain_progress
	stats.combo_return_duration = combo.return_duration_scale
	stats.combo_finisher_duration = combo.finisher_duration_scale
	stats.combo_finisher_damage = combo.finisher_damage_scale
	return stats

static func enemy_stats(tuning: Resource) -> Stats:
	var stats := combat_stats(tuning)
	# Individual swing IDs already prevent repeat overlap; allow the next cut.
	stats.hurt_invulnerability = 0.12
	return stats
