extends RefCounted
## Capacitor capacity persists within a run; consumed charge never raises its tier.
var capacitor_level := 0
var capacitor_limit: int
var shield_per_cell: int
var crystal_step: int
var scrap_step: int
var charge_cost: int
var charge_scrap: int
func _init(config: Dictionary = {}, cell_size: int = 20) -> void:
	capacitor_limit=clampi(int(config.get("capacitor_limit",3)),1,3)
	shield_per_cell=maxi(1,cell_size)
	crystal_step=maxi(0,int(config.get("growth_crystal_step",1)))
	scrap_step=maxi(0,int(config.get("growth_scrap_step",1)))
	charge_cost=clampi(int(config.get("shield_charge_cost",1)),1,12)
	charge_scrap=maxi(0,int(config.get("shield_charge_scrap",1)))
func capacity() -> int:
	return capacitor_level*shield_per_cell
func can_install(city_level: int) -> bool:
	return capacitor_level<capacitor_limit and capacitor_level<city_level
func install(city_level: int) -> int:
	if not can_install(city_level):return capacity()
	capacitor_level+=1
	return capacity()
func recharge(current: int) -> int:
	return mini(capacity(),maxi(0,current)+shield_per_cell)
func crystal_cost(base: int, level: int) -> int:
	return clampi(base+level*crystal_step,1,12)
func capacitor_scrap() -> int:
	return 2+capacitor_level*scrap_step
func lesson_food(base: int, level: int) -> int:
	return base*(level+1)
