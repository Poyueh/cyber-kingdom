class_name ActorTuning
extends Resource
## Edit a .tres in the Inspector. Runtime fighters receive a separate rules copy.
@export_group("Combat")
@export_range(1, 10000, 1) var max_hp: int = 100
@export_range(1, 1000, 1) var damage: int = 25
@export_range(1.0, 300.0) var attack_range: float = 64.0
@export_range(0.05, 2.0) var attack_duration: float = 0.22
@export_range(0.05, 3.0) var attack_cooldown: float = 0.45
@export_group("Movement")
@export_range(1.0, 1000.0) var move_speed: float = 190.0
@export_range(1.0, 1000.0) var jump_speed: float = 420.0
@export_range(1.0, 2000.0) var dash_speed: float = 540.0
@export_range(1.0, 3000.0) var gravity: float = 1100.0
