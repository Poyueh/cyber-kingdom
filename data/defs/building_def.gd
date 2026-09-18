extends Resource
class_name BuildingDef
## One buildable site. Costs and gates live here, not in session code.

@export var id: StringName = &""
## Translation key. Never compare gameplay against this; compare against id.
@export var name_key: String = ""
@export_range(1,12,1) var crystal_cost: int = 1
@export_range(1,3,1) var max_level: int = 1
@export var build_seconds: float = 3.0
## Sites that must already exist before this one can be ordered.
@export var requires: Array[StringName] = []
## Granted while the site stands, tagged with this building as the source.
@export var grants: Array[Modifier] = []
