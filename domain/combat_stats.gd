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
