extends RefCounted
## Base values plus a list of labelled adjustments. Conditional bonuses belong
## here rather than multiplied into a value at the place that happens to need it.

var _base: Dictionary={}
var _modifiers: Array[Modifier]=[]

func set_base(stat: StringName, value: float) -> void:
	_base[stat]=value

func base_of(stat: StringName) -> float:
	return float(_base.get(stat,0.0))

func apply(modifier: Modifier) -> void:
	if modifier==null or modifier.stat.is_empty():
		return
	_modifiers.append(modifier)

## Removal works on the source label, never on matching numbers back up.
func remove_source(source: StringName) -> int:
	var before: int=_modifiers.size()
	var kept: Array[Modifier]=[]
	for modifier in _modifiers:
		if modifier.source!=source:
			kept.append(modifier)
	_modifiers=kept
	return before-_modifiers.size()

func expire_at(tick: int) -> void:
	var kept: Array[Modifier]=[]
	for modifier in _modifiers:
		if modifier.expires_tick<0 or modifier.expires_tick>tick:
			kept.append(modifier)
	_modifiers=kept

## (base + every ADD) * every MULT, and then OVERRIDE replaces the result.
func value_of(stat: StringName) -> float:
	var total: float=base_of(stat)
	var product: float=1.0
	var overridden: bool=false
	var override_value: float=0.0
	for modifier in _modifiers:
		if modifier.stat!=stat:
			continue
		match modifier.op:
			Modifier.Op.ADD:
				total+=modifier.value
			Modifier.Op.MULT:
				product*=modifier.value
			Modifier.Op.OVERRIDE:
				overridden=true
				override_value=modifier.value
	return override_value if overridden else total*product

## Feeds the "why is this number what it is" panel.
func breakdown(stat: StringName) -> Array[Dictionary]:
	var rows: Array[Dictionary]=[{"source":&"base","op":Modifier.Op.ADD,"value":base_of(stat)}]
	for modifier in _modifiers:
		if modifier.stat==stat:
			rows.append({"source":modifier.source,"op":modifier.op,"value":modifier.value})
	return rows

func sources() -> Array[StringName]:
	var found: Array[StringName]=[]
	for modifier in _modifiers:
		if not found.has(modifier.source):
			found.append(modifier.source)
	return found

func capture() -> Dictionary:
	var saved: Array=[]
	for modifier in _modifiers:
		saved.append({"stat":str(modifier.stat),"op":int(modifier.op),"value":modifier.value,
			"source":str(modifier.source),"expires_tick":modifier.expires_tick})
	var base: Dictionary={}
	for stat in _base:
		base[str(stat)]=float(_base[stat])
	return {"base":base,"modifiers":saved}

## JSON has one numeric type, so stored whole numbers may arrive as floats.
static func _whole(value) -> bool:
	return value is int or (value is float and is_finite(value) and floorf(value)==value)

func restore(data: Dictionary) -> bool:
	if not data.get("base") is Dictionary or not data.get("modifiers") is Array:
		return false
	for row in data.modifiers:
		if not row is Dictionary:
			return false
		for key in ["stat","op","value","source","expires_tick"]:
			if not row.has(key):
				return false
		if not row.stat is String or not row.source is String:
			return false
		if not _whole(row.op) or int(row.op)<0 or int(row.op)>int(Modifier.Op.OVERRIDE):
			return false
		if not (row.value is int or row.value is float) or not _whole(row.expires_tick):
			return false
	_base.clear()
	for stat in data.base:
		_base[StringName(stat)]=float(data.base[stat])
	_modifiers.clear()
	for row in data.modifiers:
		_modifiers.append(Modifier.make(StringName(row.stat),int(row.op),float(row.value),StringName(row.source),int(row.expires_tick)))
	return true
