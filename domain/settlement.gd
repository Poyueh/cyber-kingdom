extends RefCounted
## Resource and identity rules. Locations are plain world-unit numbers.
var scrap: int
var crystals: int
var people: Array[Dictionary] = []
var supplies: Array[Dictionary] = []
var tools := {"hammer": 0, "blade": 0}
var sites := {"forge":350.0, "workshop":520.0, "armory":710.0, "beacon":890.0, "wall":1100.0, "horn":1360.0}
var wall := {"level":0, "hp":0, "pending":false, "progress":0.0, "repair":false}
var barrier: int = 0
var shield_value: int

func _init(config: Dictionary = {}) -> void:
	scrap = maxi(0, int(config.get("scrap",14)))
	crystals = maxi(0,int(config.get("crystals",3)))
	shield_value = maxi(1,int(config.get("shield_value",20)))
	for index in range(3):
		people.append({"x":150.0+index*55, "role":"wanderer", "hurt":0.0, "cooldown":0.0})

func drop_supply(x: float) -> bool:
	if scrap < 1:
		return false
	scrap -= 1
	supplies.append({"x":x, "taken":false, "age":0.0})
	return true

func collect_supply(person_index: int, supply_index: int) -> bool:
	if person_index < 0 or person_index >= people.size() or supply_index < 0 or supply_index >= supplies.size():
		return false
	var person: Dictionary = people[person_index]
	var supply: Dictionary = supplies[supply_index]
	if person.role != "wanderer" or person.hurt > 0 or supply.taken or absf(person.x-supply.x)>12:
		return false
	supply.taken = true
	person.role = "citizen"
	return true

func buy_tool(kind: String) -> bool:
	if not tools.has(kind) or scrap < 2 or tools[kind] >= 3:
		return false
	scrap -= 2
	tools[kind] += 1
	return true

func claim_tool(index: int, kind: String) -> bool:
	if index < 0 or index >= people.size() or not tools.has(kind) or tools[kind] <= 0:
		return false
	var person: Dictionary = people[index]
	var location: float = sites.workshop if kind == "hammer" else sites.armory
	if person.role != "citizen" or absf(person.x-location)>12:
		return false
	tools[kind] -= 1
	person.role = "engineer" if kind == "hammer" else "guard"
	return true

func wall_cost() -> int:
	return 2 if wall.level > 0 and wall.hp < wall.level*40 else (3 if wall.level == 0 else 4)

func order_wall() -> bool:
	var repair: bool = wall.level > 0 and wall.hp < wall.level*40
	if wall.pending or (wall.level >= 2 and not repair) or scrap < wall_cost():
		return false
	scrap -= wall_cost()
	wall.pending = true
	wall.repair = repair
	wall.progress = 0.0
	return true

func work_wall(index: int, seconds: float) -> bool:
	if seconds <= 0 or not is_finite(seconds) or not wall.pending:
		return false
	var person: Dictionary = people[index]
	if person.role != "engineer" or absf(person.x-sites.wall)>20:
		return false
	wall.progress += seconds
	if wall.progress >= 3.0:
		if not wall.repair:
			wall.level += 1
		wall.hp = wall.level*40
		wall.pending = false
	return true

func take_knight_crystal() -> int:
	if crystals <= 0:
		return 0
	crystals -= 1
	return shield_value

func power_refuge() -> bool:
	if crystals <= 0:
		return false
	crystals -= 1
	barrier += 1
	return true

func hit_person(index: int) -> bool:
	if index < 0 or index >= people.size() or people[index].role == "wanderer":
		return false
	if barrier > 0:
		barrier -= 1
		return false
	people[index].role = "wanderer"
	people[index].hurt = 2.0
	return true

func hit_wall(amount: int) -> bool:
	if wall.hp <= 0 or amount <= 0:
		return false
	wall.hp = maxi(0,wall.hp-amount)
	return true
