extends Resource
class_name HarvestDef
## One kind of gatherable node and what the frontier pays for clearing it.
@export var id: StringName = &""
@export var name_key: String = ""
@export_range(1,12,1) var crystals: int = 4
@export var work_seconds: float = 75.0
## True for chests, which the knight opens instead of marking for a resident.
@export var opened_by_knight: bool = false
