extends RefCounted
## Plain combat data. No scene, input, file, or rendering dependencies.
var max_hp: int = 100
var damage: int = 25
var attack_range: float = 64.0
var vertical_range: float = 42.0
var attack_duration: float = 0.34
var attack_cooldown: float = 0.45
var max_stamina: float = 100.0
var stamina_regen: float = 25.0
var dash_cost: float = 30.0
var dash_duration: float = 0.20
var dash_invulnerability: float = 0.25
var hurt_invulnerability: float = 0.35

# Player-only combo; enemies retain independent single swings.
var combo_enabled: bool = false
var combo_buffer_seconds: float = 0.30
var combo_grace_seconds: float = 0.18
var combo_chain_progress: float = 0.88
var combo_return_duration: float = 0.82
var combo_finisher_duration: float = 1.25
var combo_finisher_damage: float = 1.6

# Player movement is rooted during a swing; followups provide authored travel.
var attack_movement_locked: bool = false
var combo_return_step: float = 22.0
var combo_finisher_step: float = 32.0

var attack_cost: float = 0.0
var jump_cost: float = 0.0
