extends RefCounted
## A fixed reserve is split, never duplicated, between knight and refuge.
var total: int
var shield_per_crystal: int
var residents: int
var knight_crystals: int = 0

func _init(reserve: int, shield_value: int, population: int) -> void:
	total = maxi(0, reserve)
	shield_per_crystal = maxi(0, shield_value)
	residents = maxi(0, population)

func choose(amount: int) -> bool:
	if amount < 0 or amount > total:
		return false
	knight_crystals = amount
	return true

func preview() -> Dictionary:
	var refuge := total - knight_crystals
	return {"total": total, "knight_crystals": knight_crystals, "refuge_crystals": refuge,
		"knight_shield": knight_crystals * shield_per_crystal,
		"protected": mini(residents, refuge), "wounded": maxi(0, residents - refuge), "residents": residents}
