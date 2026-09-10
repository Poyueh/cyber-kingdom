extends RefCounted
## Crystals belong either to the knight or a physical pile, never both.
var capacity: int
var amount: int
var drops: Array[Dictionary] = []
func _init(limit: int = 12, starting: int = 8, start_x: float = 30.0) -> void:
	capacity = maxi(1,limit)
	amount = 0
	receive(maxi(0,starting),start_x,430)
func spend() -> bool:
	if amount<=0: return false
	amount -= 1
	return true
func receive(count: int, x: float, y: float = 430.0) -> void:
	if count<=0: return
	var stored := mini(count,capacity-amount)
	amount += stored
	drop(count-stored,x,y)
func drop(count: int, x: float, y: float = 430.0) -> void:
	if count<=0: return
	for pile in drops:
		if absf(pile.x-x)<10 and absf(pile.y-y)<10:
			pile.amount += count
			return
	drops.append({"x":x,"y":y,"amount":count})
func pick_up(x: float, y: float) -> void:
	for pile in drops:
		if absf(pile.x-x)>=28 or absf(pile.y-y)>=45: continue
		var stored := mini(pile.amount,capacity-amount)
		amount += stored
		pile.amount -= stored
	drops = drops.filter(func(pile): return pile.amount>0)
func ground_total() -> int:
	var total := 0
	for pile in drops: total += pile.amount
	return total
