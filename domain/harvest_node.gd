extends RefCounted
var kind: String
var x: float
var y: float = 430.0
var hp: int = 75
var wood: int = 0
var food: int = 0
var crystals: int = 0
var scrap: int = 0
var collected := false
var region: int
func take_damage(amount: int) -> bool:
	if amount <= 0 or hp <= 0:
		return false
	hp = maxi(0,hp-amount)
	return true
