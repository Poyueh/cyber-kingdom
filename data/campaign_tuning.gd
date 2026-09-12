extends "res://data/frontier_tuning.gd"
@export_group("Presentation")
@export_range(1.0,1.4,0.05) var camera_zoom: float = 1.15
@export var larger_desktop_window: bool = true
@export_group("Knight backpack")
@export_range(2,30,1) var backpack_capacity: int = 12
@export_range(0,30,1) var initial_crystals: int = 12
@export_group("Hold to invest")
@export_range(0.2,1.5,0.05) var investment_hold_delay: float = 0.5
@export_range(0.1,1,0.05) var investment_interval: float = 0.28
@export_group("Crystal motion")
@export_range(48,220,4) var magnet_radius: float = 112.0
@export_range(100,600,10) var magnet_speed: float = 300.0
@export_range(0.5,4,0.1) var throw_grace: float = 2.0
@export_range(6,14,1) var crystal_radius: float = 9.0
@export_group("Resident stroll")
@export_range(8,50,1) var stroll_speed: float = 24.0
@export_group("Frontier renewal")
@export_range(1,8,1) var tree_timber: int = 4
@export_range(8,40,1) var population_limit: int = 24
@export_range(1,4,1) var camp_waiting_limit: int = 2
@export_group("Knight growth")
@export_range(1,3,1) var capacitor_limit: int = 3
@export_range(0,3,1) var growth_crystal_step: int = 1
@export_range(0,3,1) var growth_scrap_step: int = 1
@export_range(1,6,1) var shield_charge_cost: int = 1
@export_range(0,6,1) var shield_charge_scrap: int = 1
@export_group("Core and expedition")
@export_range(40,600,10) var core_max_hp: int = 180
@export_range(10,180,10) var core_recharge: int = 60
@export_range(2,30,1) var rift_seal_seconds: float = 8.0
@export_range(40,300,10) var warden_health: int = 90
@export_range(5,60,1) var warden_damage: int = 18
@export_group("Defense posts")
@export_range(-1200,-950,10) var left_defense_x: float = -1100.0
@export_group("Resident night safety")
@export_range(0,60,1) var return_margin: float = 15.0
@export_range(1,30,1) var hunter_damage: int = 12
@export_range(50,240,5) var hunter_range: float = 170.0
@export_range(0.4,3,0.1) var hunter_interval: float = 1.2
@export_group("Days and nights")
@export_range(30,600,10) var day_seconds: float = 180.0
@export_range(10,300,5) var night_seconds: float = 60.0
@export_range(1,50,1) var enemy_health_growth: int = 12
@export_range(1,20,1) var enemy_damage_growth: int = 3
@export_group("Crystal slots per interaction")
@export var crystal_prices: Dictionary = {"camp":2,"hall":5,"workshop":2,"armory":3,"farm_tools":2,"hunt_tools":3,"forge":2,"beacon":1,"wall":3,"wall_upgrade":4,"repair":2,"farm":3,"drill":2,"outpost":3,"mark":1,"recruit":1,"core_charge":2,"rift":4}
func campaign_rules() -> Dictionary:
	return {"tree_timber":tree_timber,"population_limit":population_limit,"camp_waiting_limit":camp_waiting_limit,"capacitor_limit":capacitor_limit,"growth_crystal_step":growth_crystal_step,"growth_scrap_step":growth_scrap_step,"shield_charge_cost":shield_charge_cost,"shield_charge_scrap":shield_charge_scrap,"warden_health":warden_health,"warden_damage":warden_damage,"rift_seal_seconds":rift_seal_seconds,"core_max_hp":core_max_hp,"core_recharge":core_recharge,"left_defense_x":left_defense_x,"return_margin":return_margin,"hunter_damage":hunter_damage,"hunter_range":hunter_range,"hunter_interval":hunter_interval,"stroll_speed":stroll_speed,"magnet_radius":magnet_radius,"magnet_speed":magnet_speed,"throw_grace":throw_grace,"capacity":backpack_capacity,"starting_crystals":initial_crystals,"day_seconds":day_seconds,"night_seconds":night_seconds,"enemy_health_growth":enemy_health_growth,"enemy_damage_growth":enemy_damage_growth,"prices":crystal_prices}
