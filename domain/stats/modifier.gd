extends Resource
class_name Modifier
## One labelled adjustment to one stat. The source is what removal works on, so
## a condition that ends can take back exactly what it granted.
enum Op {ADD, MULT, OVERRIDE}

@export var stat: StringName = &""
@export var op: Op = Op.ADD
@export var value: float = 0.0
## Examples: "weather:rain", "building:barracks:2", "effect:frostbite".
@export var source: StringName = &""
## -1 lasts until something removes it by source.
@export var expires_tick: int = -1

static func make(stat_id: StringName, operation: Op, amount: float, origin: StringName, until_tick: int = -1) -> Modifier:
	var modifier := Modifier.new()
	modifier.stat=stat_id
	modifier.op=operation
	modifier.value=amount
	modifier.source=origin
	modifier.expires_tick=until_tick
	return modifier
