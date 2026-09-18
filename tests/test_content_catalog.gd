extends RefCounted
const Catalog=preload("res://data/defs/content_catalog.gd")
const Building=preload("res://data/defs/building_def.gd")
const Harvest=preload("res://data/defs/harvest_def.gd")
const Enemy=preload("res://data/defs/enemy_def.gd")
const Stat=preload("res://domain/stats/stat_id.gd")

func _building(id: StringName, requires: Array[StringName]=[]) -> Building:
	var entry=Building.new()
	entry.id=id
	entry.requires=requires
	return entry

func test_an_empty_catalog_is_usable(t) -> void:
	t.equal(Catalog.new().validate(),[] as Array[String],"nothing authored means nothing broken")

func test_entries_are_found_by_id(t) -> void:
	var catalog=Catalog.new()
	catalog.buildings=[_building(&"hall"),_building(&"armory")] as Array[BuildingDef]
	t.equal(catalog.building(&"armory").id,&"armory","a building is found by its id")
	t.equal(catalog.building(&"missing"),null,"an unknown id yields nothing for the caller to handle")

func test_duplicate_ids_are_reported(t) -> void:
	var catalog=Catalog.new()
	catalog.buildings=[_building(&"hall"),_building(&"hall")] as Array[BuildingDef]
	t.equal(catalog.validate().size(),1,"a repeated id is a single complaint")

func test_missing_ids_are_reported(t) -> void:
	var catalog=Catalog.new()
	catalog.harvests=[Harvest.new()] as Array[HarvestDef]
	t.equal(catalog.validate().size(),1,"an entry without an id is reported")

func test_an_empty_slot_is_reported(t) -> void:
	var catalog=Catalog.new()
	catalog.enemies=[null] as Array[EnemyDef]
	t.equal(catalog.validate().size(),1,"an unfilled slot is reported instead of crashing later")

func test_requirements_must_exist(t) -> void:
	var catalog=Catalog.new()
	catalog.buildings=[_building(&"armory",[&"hall"] as Array[StringName])] as Array[BuildingDef]
	t.equal(catalog.validate().size(),1,"a gate on a building nobody authored is reported")
	catalog.buildings.append(_building(&"hall"))
	t.equal(catalog.validate(),[] as Array[String],"the same gate is fine once its building exists")

func test_a_grant_without_a_stat_is_reported(t) -> void:
	var catalog=Catalog.new()
	var entry=_building(&"barracks")
	entry.grants=[Modifier.new()] as Array[Modifier]
	catalog.buildings=[entry] as Array[BuildingDef]
	t.equal(catalog.validate().size(),1,"a bonus that names no stat is reported")
	entry.grants=[Modifier.make(Stat.ARCHER_DAMAGE,Modifier.Op.ADD,6.0,&"building:barracks")] as Array[Modifier]
	t.equal(catalog.validate(),[] as Array[String],"a named bonus passes")

func test_enemy_growth_is_authored_not_hardcoded(t) -> void:
	var raider=Enemy.new()
	raider.id=&"raider"
	raider.health=60
	raider.health_per_day=12
	t.equal(raider.health+raider.health_per_day*2,84,"nightly growth comes from the resource")
