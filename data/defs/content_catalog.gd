extends Resource
class_name ContentCatalog
## The single entry point to authored content. Adding a building or a raider
## should mean adding a resource, not editing session code.

@export var buildings: Array[BuildingDef] = []
@export var harvests: Array[HarvestDef] = []
@export var enemies: Array[EnemyDef] = []

func building(id: StringName) -> BuildingDef:
	return _find(buildings,id) as BuildingDef

func harvest(id: StringName) -> HarvestDef:
	return _find(harvests,id) as HarvestDef

func enemy(id: StringName) -> EnemyDef:
	return _find(enemies,id) as EnemyDef

func _find(entries: Array, id: StringName) -> Resource:
	for entry in entries:
		if entry!=null and entry.id==id:
			return entry
	return null

## Run at startup and in tests. An empty result means the catalog is usable.
func validate() -> Array[String]:
	var problems: Array[String]=[]
	var known: Array[StringName]=[]
	for group in [["building",buildings],["harvest",harvests],["enemy",enemies]]:
		var label: String=group[0]
		var seen: Array[StringName]=[]
		for index in range(group[1].size()):
			var entry: Resource=group[1][index]
			if entry==null:
				problems.append("%s[%d] is empty" % [label,index])
				continue
			if entry.id.is_empty():
				problems.append("%s[%d] has no id" % [label,index])
				continue
			if seen.has(entry.id):
				problems.append("%s id '%s' is used twice" % [label,entry.id])
			seen.append(entry.id)
			known.append(entry.id)
	for entry in buildings:
		if entry==null:
			continue
		for requirement in entry.requires:
			if not known.has(requirement):
				problems.append("building '%s' requires unknown '%s'" % [entry.id,requirement])
		for modifier in entry.grants:
			if modifier==null or modifier.stat.is_empty():
				problems.append("building '%s' grants a modifier without a stat" % entry.id)
	return problems
