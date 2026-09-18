extends RefCounted
const StatBlock=preload("res://domain/stats/stat_block.gd")
const Stat=preload("res://domain/stats/stat_id.gd")

func _block() -> StatBlock:
	var block=StatBlock.new()
	block.set_base(Stat.DAMAGE,100.0)
	return block

func test_order_is_add_then_multiply(t) -> void:
	var block=_block()
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.MULT,2.0,&"a"))
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.ADD,50.0,&"b"))
	t.equal(block.value_of(Stat.DAMAGE),300.0,"additions land before multipliers regardless of order")

func test_override_replaces_the_whole_result(t) -> void:
	var block=_block()
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.ADD,50.0,&"a"))
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.OVERRIDE,7.0,&"b"))
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.MULT,9.0,&"c"))
	t.equal(block.value_of(Stat.DAMAGE),7.0,"an override ignores the adds and multiplies")

func test_the_last_override_wins(t) -> void:
	var block=_block()
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.OVERRIDE,7.0,&"a"))
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.OVERRIDE,9.0,&"b"))
	t.equal(block.value_of(Stat.DAMAGE),9.0,"the newest override decides")

func test_other_stats_are_untouched(t) -> void:
	var block=_block()
	block.set_base(Stat.MAX_HP,40.0)
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.ADD,900.0,&"a"))
	t.equal(block.value_of(Stat.MAX_HP),40.0,"a damage bonus does not touch health")

func test_removal_works_on_the_source_label(t) -> void:
	var block=_block()
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.ADD,10.0,&"weather:rain"))
	block.apply(Modifier.make(Stat.MAX_HP,Modifier.Op.ADD,10.0,&"weather:rain"))
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.ADD,10.0,&"building:barracks"))
	t.equal(block.remove_source(&"weather:rain"),2,"one source can hold several adjustments")
	t.equal(block.value_of(Stat.DAMAGE),110.0,"the other source survives")
	t.equal(block.remove_source(&"nobody"),0,"removing an absent source changes nothing")

func test_the_same_source_can_stack(t) -> void:
	var block=_block()
	for repeat in range(3):block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.ADD,5.0,&"stack"))
	t.equal(block.value_of(Stat.DAMAGE),115.0,"repeated grants from one source all count")
	t.equal(block.remove_source(&"stack"),3,"removing the source takes all of them back")

func test_expiry_is_exclusive_at_its_own_tick(t) -> void:
	var block=_block()
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.ADD,10.0,&"brief",120))
	block.expire_at(119)
	t.equal(block.value_of(Stat.DAMAGE),110.0,"a bonus still counts on the tick before it ends")
	block.expire_at(120)
	t.equal(block.value_of(Stat.DAMAGE),100.0,"a bonus is gone on the tick it expires")

func test_permanent_modifiers_never_expire(t) -> void:
	var block=_block()
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.ADD,10.0,&"forever"))
	block.expire_at(999999)
	t.equal(block.value_of(Stat.DAMAGE),110.0,"an open-ended bonus outlives any tick")

func test_breakdown_explains_the_number(t) -> void:
	var block=_block()
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.ADD,10.0,&"weather:rain"))
	block.apply(Modifier.make(Stat.MAX_HP,Modifier.Op.ADD,10.0,&"elsewhere"))
	var rows: Array[Dictionary]=block.breakdown(Stat.DAMAGE)
	t.equal(rows.size(),2,"the breakdown lists the base and each contribution for that stat")
	t.equal(rows[0].value,100.0,"the base comes first")
	t.equal(rows[1].source,&"weather:rain","every contribution names its source")

func test_capture_survives_a_checkpoint_round_trip(t) -> void:
	var block=_block()
	block.apply(Modifier.make(Stat.DAMAGE,Modifier.Op.MULT,1.5,&"weather:rain",400))
	block.apply(Modifier.make(Stat.MAX_HP,Modifier.Op.ADD,25.0,&"building:barracks"))
	var restored=StatBlock.new()
	t.truth(restored.restore(JSON.parse_string(JSON.stringify(block.capture()))),"a stored block is accepted back")
	t.equal(restored.value_of(Stat.DAMAGE),block.value_of(Stat.DAMAGE),"restored values match")
	t.equal(restored.sources(),block.sources(),"restored sources match")
	restored.expire_at(400)
	t.equal(restored.value_of(Stat.DAMAGE),100.0,"restored expiry still works")

func test_restore_refuses_a_damaged_block(t) -> void:
	var block=_block()
	t.truth(not block.restore({}),"an empty payload is refused")
	t.truth(not block.restore({"base":{},"modifiers":[{"stat":"damage"}]}),"an incomplete adjustment is refused")
	t.truth(not block.restore({"base":{},"modifiers":[{"stat":"damage","op":99,"value":1.0,"source":"x","expires_tick":-1}]}),"an unknown operation is refused")
	t.equal(block.value_of(Stat.DAMAGE),100.0,"a refused restore leaves the block alone")
