extends "res://data/frontier_tuning.gd"
@export_group("Knight backpack")
@export_range(2,30,1) var backpack_capacity: int = 12
@export_range(0,30,1) var initial_crystals: int = 12
@export_group("Days and nights")
@export_range(30,600,10) var day_seconds: float = 180.0
@export_range(10,300,5) var night_seconds: float = 60.0
@export_range(1,50,1) var enemy_health_growth: int = 12
@export_range(1,20,1) var enemy_damage_growth: int = 3
@export_group("Crystal slots per interaction")
@export var crystal_prices: Dictionary = {"camp":2,"hall":5,"workshop":2,"armory":3,"farm_tools":2,"hunt_tools":3,"forge":2,"beacon":1,"wall":3,"wall_upgrade":4,"repair":2,"farm":3,"drill":2,"outpost":3,"mark":1,"recruit":1}
func campaign_rules() -> Dictionary:
	return {"capacity":backpack_capacity,"starting_crystals":initial_crystals,"day_seconds":day_seconds,"night_seconds":night_seconds,"enemy_health_growth":enemy_health_growth,"enemy_damage_growth":enemy_damage_growth,"prices":crystal_prices}
