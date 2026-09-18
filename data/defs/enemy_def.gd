extends Resource
class_name EnemyDef
## One raider archetype. Nightly growth is expressed here rather than as a
## literal inside the spawn code.
@export var id: StringName = &""
@export var name_key: String = ""
@export_range(1,6000,1) var health: int = 60
@export_range(1,200,1) var damage: int = 15
@export_range(0,1000,1) var health_per_day: int = 12
@export_range(0,50,1) var damage_per_day: int = 3
@export_range(0,200,1) var wall_damage: int = 20
