extends "res://data/settlement_tuning.gd"
## A fixed seed makes a playtest reproducible. N chooses the next seed.
@export var map_seed: int = 742601
@export_group("Production")
@export_range(1,60,1) var farm_cycle: float = 12.0
@export_range(1,10,1) var farm_yield: int = 2
@export_group("Knight training")
@export_range(1,20,1) var training_food: int = 2
@export_range(1,25,1) var training_damage: int = 5
@export_range(1,10,1) var training_limit: int = 3

func economy_rules() -> Dictionary:
	return {"farm_cycle":farm_cycle,"farm_yield":farm_yield,"training_food":training_food,
		"training_damage":training_damage,"training_limit":training_limit}
